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

func (s *Server) handleEmployeesImportTemplate(w http.ResponseWriter, r *http.Request, siteID string) {
	w.Header().Set("Content-Type", "text/csv")
	w.Header().Set("Content-Disposition", `attachment; filename="shawaf_employee_import_template.csv"`)
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte("employee_id,full_name,department,role\nEMP-101,Ahmed Ali,OPERATIONS,OPERATOR\nEMP-102,Tarek Mostafa,SECURITY,OFFICER\n"))
}

func (s *Server) handleSiteEmployeesImport(w http.ResponseWriter, r *http.Request, siteID string, action string) {
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

	type ParsedRow struct {
		RowNumber  int    `json:"row_number"`
		EmployeeID string `json:"employee_id"`
		FullName   string `json:"full_name"`
		Department string `json:"department"`
		Role       string `json:"role"`
	}

	type InvalidRow struct {
		RowNumber int    `json:"row_number"`
		Field     string `json:"field"`
		Reason    string `json:"reason"`
	}

	var rows []ParsedRow
	var headers []string

	// Attempt JSON array decode first
	var jsonRecords []struct {
		EmployeeID string `json:"employee_id"`
		FullName   string `json:"full_name"`
		Department string `json:"department"`
		Role       string `json:"role"`
	}

	if err := json.Unmarshal(bodyBytes, &jsonRecords); err == nil && len(jsonRecords) > 0 {
		headers = []string{"employee_id", "full_name", "department", "role"}
		for i, rec := range jsonRecords {
			dept := rec.Department
			if dept == "" {
				dept = "OPERATIONS"
			}
			role := rec.Role
			if role == "" {
				role = "WORKER"
			}
			rows = append(rows, ParsedRow{
				RowNumber:  i + 1,
				EmployeeID: strings.TrimSpace(rec.EmployeeID),
				FullName:   strings.TrimSpace(rec.FullName),
				Department: dept,
				Role:       role,
			})
		}
	} else {
		// Attempt CSV parsing
		reader := csv.NewReader(strings.NewReader(string(bodyBytes)))
		records, err := reader.ReadAll()
		if err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"failed to parse payload: %v"}`, err), http.StatusBadRequest)
			return
		}
		if len(records) > 0 {
			headers = records[0]
			for i, record := range records[1:] {
				if len(record) == 0 {
					continue
				}
				empID := strings.TrimSpace(record[0])
				fullName := ""
				if len(record) > 1 {
					fullName = strings.TrimSpace(record[1])
				}
				dept := "OPERATIONS"
				if len(record) > 2 && strings.TrimSpace(record[2]) != "" {
					dept = strings.TrimSpace(record[2])
				}
				role := "WORKER"
				if len(record) > 3 && strings.TrimSpace(record[3]) != "" {
					role = strings.TrimSpace(record[3])
				}
				rows = append(rows, ParsedRow{
					RowNumber:  i + 2,
					EmployeeID: empID,
					FullName:   fullName,
					Department: dept,
					Role:       role,
				})
			}
		}
	}

	// Fetch existing DB employees for conflict checking
	existingMap := make(map[string]bool)
	if existingEmps, err := s.employeePort.GetEmployees(r.Context(), siteID); err == nil {
		for _, e := range existingEmps {
			existingMap[e.EmployeeID] = true
		}
	}

	seenIDs := make(map[string]bool)
	var invalidRows []InvalidRow
	var validRows []ParsedRow
	duplicateInFile := 0
	conflictInDB := 0

	for _, row := range rows {
		if row.EmployeeID == "" {
			invalidRows = append(invalidRows, InvalidRow{
				RowNumber: row.RowNumber,
				Field:     "employee_id",
				Reason:    "MISSING_REQUIRED",
			})
			continue
		}
		if row.FullName == "" {
			invalidRows = append(invalidRows, InvalidRow{
				RowNumber: row.RowNumber,
				Field:     "full_name",
				Reason:    "MISSING_REQUIRED",
			})
			continue
		}
		if seenIDs[row.EmployeeID] {
			duplicateInFile++
			invalidRows = append(invalidRows, InvalidRow{
				RowNumber: row.RowNumber,
				Field:     "employee_id",
				Reason:    "DUPLICATE_IN_FILE",
			})
			continue
		}
		seenIDs[row.EmployeeID] = true

		if existingMap[row.EmployeeID] {
			conflictInDB++
			continue
		}
		validRows = append(validRows, row)
	}

	if action == "preview" {
		sampleLimit := 5
		if len(rows) < sampleLimit {
			sampleLimit = len(rows)
		}
		sampleRows := rows[:sampleLimit]

		s.writeJSON(w, http.StatusOK, map[string]interface{}{
			"data": map[string]interface{}{
				"detected_headers": headers,
				"sample_rows":      sampleRows,
				"validation_summary": map[string]interface{}{
					"total_rows":              len(rows),
					"valid_new_count":         len(validRows),
					"duplicate_in_file_count": duplicateInFile,
					"conflict_in_db_count":    conflictInDB,
					"invalid_rows":            invalidRows,
				},
			},
		})
		return
	}

	// Commit action
	created := 0
	failed := 0
	for _, row := range validRows {
		seed := []byte(fmt.Sprintf("%s:%s", siteID, row.EmployeeID))
		embBytes := crypto.GenerateNormalizedEmbedding512(seed)
		h := sha256.Sum256(seed)
		emp := &ports.Employee{
			SiteID:     siteID,
			EmployeeID: row.EmployeeID,
			FullName:   row.FullName,
			Department: row.Department,
			SourceType: "CSV_IMPORT",
			IsActive:   true,
		}
		if err := s.employeePort.RegisterEmployee(r.Context(), emp, embBytes, hex.EncodeToString(h[:])); err != nil {
			failed++
		} else {
			created++
		}
	}

	s.writeJSON(w, http.StatusOK, map[string]interface{}{
		"data": map[string]interface{}{
			"created":            created,
			"skipped_conflicts": conflictInDB,
			"failed":             failed + len(invalidRows),
		},
		"imported": created,
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
