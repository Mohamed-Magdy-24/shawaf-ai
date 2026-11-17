package httpapi

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"sync"
	"time"
)

type sitesCacheEntry struct {
	payload   []byte
	timestamp time.Time
}

var (
	sitesCacheMu sync.RWMutex
	cachedSites  sitesCacheEntry
)

func (s *Server) handleSites(w http.ResponseWriter, r *http.Request) {
	sitesCacheMu.RLock()
	if len(cachedSites.payload) > 0 && time.Since(cachedSites.timestamp) < 2*time.Second {
		data := cachedSites.payload
		sitesCacheMu.RUnlock()
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write(data)
		return
	}
	sitesCacheMu.RUnlock()

	query := `SELECT id, name, location, code, timezone, is_active FROM sites ORDER BY name`
	rows, err := s.db.QueryContext(r.Context(), query)
	if err != nil {
		// Fallback query if columns are minimal
		rows, err = s.db.QueryContext(r.Context(), `SELECT id, name, location FROM sites ORDER BY name`)
		if err != nil {
			http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		var sites []map[string]interface{}
		for rows.Next() {
			var id, name, loc string
			if err := rows.Scan(&id, &name, &loc); err == nil {
				code := "BNF"
				if strings.Contains(name, "RNF") {
					code = "RNF"
				}
				sites = append(sites, map[string]interface{}{
					"id":        id,
					"code":      code,
					"name":      name,
					"timezone":  "Africa/Cairo",
					"is_active": true,
				})
			}
		}
		res := map[string]interface{}{
			"data":  sites,
			"meta":  map[string]interface{}{"total": len(sites)},
			"sites": sites,
		}
		if raw, err := json.Marshal(res); err == nil {
			sitesCacheMu.Lock()
			cachedSites = sitesCacheEntry{payload: raw, timestamp: time.Now()}
			sitesCacheMu.Unlock()
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
			w.Write(raw)
			return
		}
		s.writeJSON(w, http.StatusOK, res)
		return
	}
	defer rows.Close()

	var sites []map[string]interface{}
	for rows.Next() {
		var id, name, loc, code, tz string
		var active bool
		if err := rows.Scan(&id, &name, &loc, &code, &tz, &active); err == nil {
			sites = append(sites, map[string]interface{}{
				"id":        id,
				"code":      code,
				"name":      name,
				"timezone":  tz,
				"is_active": active,
			})
		}
	}
	res := map[string]interface{}{
		"data":  sites,
		"meta":  map[string]interface{}{"total": len(sites)},
		"sites": sites,
	}
	if raw, err := json.Marshal(res); err == nil {
		sitesCacheMu.Lock()
		cachedSites = sitesCacheEntry{payload: raw, timestamp: time.Now()}
		sitesCacheMu.Unlock()
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write(raw)
		return
	}
	s.writeJSON(w, http.StatusOK, res)
}

func (s *Server) handleZones(w http.ResponseWriter, r *http.Request) {
	siteID := r.URL.Query().Get("site_id")
	if siteID == "" {
		s.writeError(w, http.StatusBadRequest, "INVALID_ARGUMENT", "site_id parameter required", nil)
		return
	}

	query := `SELECT zone_id, site_id, camera_id, name, polygon_geojson, risk_type FROM zones WHERE site_id = $1`
	rows, err := s.db.QueryContext(r.Context(), query, siteID)
	if err != nil {
		s.writeError(w, http.StatusInternalServerError, "INTERNAL_ERROR", fmt.Sprintf("%v", err), nil)
		return
	}
	defer rows.Close()

	var zones []map[string]interface{}
	for rows.Next() {
		var zid, sid, cid, name, poly, risk string
		if err := rows.Scan(&zid, &sid, &cid, &name, &poly, &risk); err == nil {
			zones = append(zones, map[string]interface{}{
				"id":        zid,
				"site_id":   sid,
				"camera_id": cid,
				"name":      name,
				"zone_type": risk,
				"polygon":   json.RawMessage(poly),
				"severity":  "SEV1",
				"is_active": true,
			})
		}
	}
	s.writeDataList(w, http.StatusOK, "zones", zones, map[string]interface{}{"site_id": siteID, "total": len(zones)})
}
