package httpapi

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

func (s *Server) handleSites(w http.ResponseWriter, r *http.Request) {
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
		s.writeJSON(w, http.StatusOK, map[string]interface{}{"sites": sites})
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
	s.writeJSON(w, http.StatusOK, map[string]interface{}{"sites": sites})
}

func (s *Server) handleZones(w http.ResponseWriter, r *http.Request) {
	siteID := r.URL.Query().Get("site_id")
	if siteID == "" {
		http.Error(w, `{"error":"site_id parameter required"}`, http.StatusBadRequest)
		return
	}

	query := `SELECT zone_id, site_id, camera_id, name, polygon_geojson, risk_type FROM zones WHERE site_id = $1`
	rows, err := s.db.QueryContext(r.Context(), query, siteID)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%v"}`, err), http.StatusInternalServerError)
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
	s.writeJSON(w, http.StatusOK, map[string]interface{}{"zones": zones})
}
