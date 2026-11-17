package httpapi

import (
	"crypto/sha256"
	"encoding/base64"
	"encoding/csv"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/crypto"
)

type presenceCacheEntry struct {
	presence  []*ports.EmployeePresenceRecord
	timestamp time.Time
}

var (
	presenceCacheMu sync.RWMutex
	presenceCache   = make(map[string]presenceCacheEntry)
)

// InvalidatePresenceCache purges cached presence data for a site
func InvalidatePresenceCache(siteID string) {
	presenceCacheMu.Lock()
	delete(presenceCache, siteID)
	presenceCacheMu.Unlock()
}

func (s *Server) handleSiteEmployees(w http.ResponseWriter, r *http.Request, siteID string) {
	if s.employeePort == nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusServiceUnavailable)
		_ = json.NewEncoder(w).Encode(map[string]interface{}{
			"error":          "FEATURE_BLOCKED_BY_GOVERNANCE",
			"detail":         ports.ErrFeatureBlockedByGovernance.Error(),
			"spk_references": []string{"SPK-01", "SPK-04", "DEC-06"},
		})
		return
	}

	if r.Method == http.MethodGet {
		employees, err := s.employeePort.GetEmployees(r.Context(), siteID)
		if err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
			return
		}
		if employees == nil {
			employees = []*ports.Employee{}
		}
		s.writeJSON(w, http.StatusOK, map[string]interface{}{"employees": employees})
		return
	}

	if r.Method == http.MethodPost {
		var empID, fullName, department, sourceType string
		var photoBytes []byte
		contentType := r.Header.Get("Content-Type")

		if strings.HasPrefix(contentType, "multipart/form-data") {
			if err := r.ParseMultipartForm(10 << 20); err != nil {
				http.Error(w, `{"error":"failed to parse multipart form"}`, http.StatusBadRequest)
				return
			}
			empID = r.FormValue("employee_id")
			fullName = r.FormValue("full_name")
			department = r.FormValue("department")
			sourceType = r.FormValue("source_type")

			file, _, err := r.FormFile("photo")
			if err == nil {
				defer file.Close()
				photoBytes, _ = io.ReadAll(file)
			}
		} else {
			var req struct {
				EmployeeID  string `json:"employee_id"`
				FullName    string `json:"full_name"`
				Department  string `json:"department"`
				SourceType  string `json:"source_type"`
				PhotoBase64 string `json:"photo_base64"`
			}
			if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
				http.Error(w, `{"error":"invalid json body"}`, http.StatusBadRequest)
				return
			}
			empID = req.EmployeeID
			fullName = req.FullName
			department = req.Department
			sourceType = req.SourceType
			if req.PhotoBase64 != "" {
				photoBytes, _ = base64.StdEncoding.DecodeString(req.PhotoBase64)
			}
		}

		if empID == "" || fullName == "" {
			http.Error(w, `{"error":"employee_id and full_name are required"}`, http.StatusBadRequest)
			return
		}

		var photoRelPath string
		var photoSHA string
		var embeddingBytes []byte

		if len(photoBytes) > 0 {
			h := sha256.Sum256(photoBytes)
			photoSHA = hex.EncodeToString(h[:])
			photoRelPath = fmt.Sprintf("evidence/%s/employees/%s.jpg", siteID, empID)

			fullPath := filepath.Join(s.evidenceDir, siteID, "employees", fmt.Sprintf("%s.jpg", empID))
			_ = os.MkdirAll(filepath.Dir(fullPath), 0755)
			_ = os.WriteFile(fullPath, photoBytes, 0644)

			embeddingBytes = crypto.GenerateNormalizedEmbedding512(photoBytes)
		} else {
			syntheticSeed := []byte(fmt.Sprintf("%s:%s", siteID, empID))
			embeddingBytes = crypto.GenerateNormalizedEmbedding512(syntheticSeed)
			h := sha256.Sum256(syntheticSeed)
			photoSHA = hex.EncodeToString(h[:])
		}

		emp := &ports.Employee{
			SiteID:       siteID,
			EmployeeID:   empID,
			FullName:     fullName,
			Department:   department,
			PhotoRelPath: photoRelPath,
			SourceType:   sourceType,
			IsActive:     true,
		}

		if err := s.employeePort.RegisterEmployee(r.Context(), emp, embeddingBytes, photoSHA); err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"failed to register employee: %v"}`, err), http.StatusInternalServerError)
			return
		}

		s.writeJSON(w, http.StatusCreated, map[string]interface{}{
			"ok":       true,
			"employee": emp,
		})
		return
	}

	http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
}

func (s *Server) handleSiteEmployeesImport(w http.ResponseWriter, r *http.Request, siteID string) {
	if s.employeePort == nil {
		http.Error(w, `{"error":"employee registry port not configured"}`, http.StatusServiceUnavailable)
		return
	}
	if r.Method != http.MethodPost {
		http.Error(w, `{"error":"method not allowed"}`, http.StatusMethodNotAllowed)
		return
	}

	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, `{"error":"cannot read payload"}`, http.StatusBadRequest)
		return
	}

	var importedCount int

	var jsonRecords []struct {
		EmployeeID string `json:"employee_id"`
		FullName   string `json:"full_name"`
		Department string `json:"department"`
	}
	if err := json.Unmarshal(bodyBytes, &jsonRecords); err == nil && len(jsonRecords) > 0 {
		for _, rec := range jsonRecords {
			if rec.EmployeeID == "" || rec.FullName == "" {
				continue
			}
			seed := []byte(fmt.Sprintf("%s:%s", siteID, rec.EmployeeID))
			embBytes := crypto.GenerateNormalizedEmbedding512(seed)
			h := sha256.Sum256(seed)
			emp := &ports.Employee{
				SiteID:     siteID,
				EmployeeID: rec.EmployeeID,
				FullName:   rec.FullName,
				Department: rec.Department,
				SourceType: "CSV_IMPORT",
				IsActive:   true,
			}
			if err := s.employeePort.RegisterEmployee(r.Context(), emp, embBytes, hex.EncodeToString(h[:])); err == nil {
				importedCount++
			}
		}
	} else {
		reader := csv.NewReader(strings.NewReader(string(bodyBytes)))
		records, err := reader.ReadAll()
		if err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"failed to parse csv: %v"}`, err), http.StatusBadRequest)
			return
		}
		for i, row := range records {
			if i == 0 && (strings.Contains(strings.ToLower(row[0]), "id") || strings.Contains(strings.ToLower(row[0]), "employee")) {
				continue
			}
			if len(row) < 2 {
				continue
			}
			empID := strings.TrimSpace(row[0])
			fullName := strings.TrimSpace(row[1])
			dept := "OPERATIONS"
			if len(row) >= 3 && strings.TrimSpace(row[2]) != "" {
				dept = strings.TrimSpace(row[2])
			}
			if empID == "" || fullName == "" {
				continue
			}

			seed := []byte(fmt.Sprintf("%s:%s", siteID, empID))
			embBytes := crypto.GenerateNormalizedEmbedding512(seed)
			h := sha256.Sum256(seed)
			emp := &ports.Employee{
				SiteID:     siteID,
				EmployeeID: empID,
				FullName:   fullName,
				Department: dept,
				SourceType: "CSV_IMPORT",
				IsActive:   true,
			}
			if err := s.employeePort.RegisterEmployee(r.Context(), emp, embBytes, hex.EncodeToString(h[:])); err == nil {
				importedCount++
			}
		}
	}

	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"ok":       true,
		"imported": importedCount,
	})
}

func (s *Server) handleSitePresence(w http.ResponseWriter, r *http.Request, siteID string) {
	if s.employeePort == nil {
		http.Error(w, `{"error":"employee registry port not configured"}`, http.StatusServiceUnavailable)
		return
	}

	presenceCacheMu.RLock()
	if cached, ok := presenceCache[siteID]; ok && time.Since(cached.timestamp) < 500*time.Millisecond {
		presenceCacheMu.RUnlock()
		s.writeJSON(w, http.StatusOK, map[string]interface{}{
			"site_id":       siteID,
			"total_present": len(cached.presence),
			"presence":      cached.presence,
		})
		return
	}
	presenceCacheMu.RUnlock()

	presence, err := s.employeePort.GetEmployeePresence(r.Context(), siteID)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
		return
	}
	if presence == nil {
		presence = []*ports.EmployeePresenceRecord{}
	}

	presenceCacheMu.Lock()
	presenceCache[siteID] = presenceCacheEntry{presence: presence, timestamp: time.Now()}
	presenceCacheMu.Unlock()

	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"site_id":       siteID,
		"total_present": len(presence),
		"presence":      presence,
	})
}

func (s *Server) handleSiteEmbeddings(w http.ResponseWriter, r *http.Request, siteID string) {
	if s.employeePort == nil {
		http.Error(w, `{"error":"employee registry port not configured"}`, http.StatusServiceUnavailable)
		return
	}
	embeddings, err := s.employeePort.GetEmployeeEmbeddings(r.Context(), siteID)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
		return
	}
	type ExportedEmbedding struct {
		SiteID       string    `json:"site_id"`
		EmployeeID   string    `json:"employee_id"`
		FullName     string    `json:"full_name"`
		ModelVersion string    `json:"model_version"`
		Embedding    []float32 `json:"embedding"`
		PhotoSHA256  string    `json:"photo_sha256"`
	}
	var out []ExportedEmbedding
	for _, rec := range embeddings {
		floats := crypto.Float32sFromBytes(rec.EmbeddingFp32Bytes)
		out = append(out, ExportedEmbedding{
			SiteID:       rec.SiteID,
			EmployeeID:   rec.EmployeeID,
			FullName:     rec.FullName,
			ModelVersion: rec.ModelVersion,
			Embedding:    floats,
			PhotoSHA256:  rec.PhotoSHA256,
		})
	}
	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"site_id":    siteID,
		"embeddings": out,
	})
}
