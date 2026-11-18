package domain

import (
	"errors"
	"fmt"
	"time"
)

// CairoLocationName is the canonical IANA timezone for Egyptian factories (DEC-07)
const CairoLocationName = "Africa/Cairo"

// Standard report domain errors
var (
	ErrInvalidReportDate = errors.New("report date must follow YYYY-MM-DD format")
)

// DailySiteReport represents daily shift safety metrics aggregated at 23:59:59 Africa/Cairo
type DailySiteReport struct {
	SiteID                   string    `json:"site_id"`
	ReportDate               string    `json:"report_date"` // YYYY-MM-DD in Africa/Cairo
	Timezone                 string    `json:"timezone"`    // "Africa/Cairo"
	PeriodStartUTC           time.Time `json:"period_start_utc"`
	PeriodEndUTC             time.Time `json:"period_end_utc"`
	TotalIncidents           int       `json:"total_incidents"`
	CriticalIncidents        int       `json:"critical_incidents"`
	WarningIncidents         int       `json:"warning_incidents"`
	InfoIncidents            int       `json:"info_incidents"`
	AcknowledgedIncidents    int       `json:"acknowledged_incidents"`
	ResolvedIncidents        int       `json:"resolved_incidents"`
	DismissedIncidents       int       `json:"dismissed_incidents"`
	AvgAcknowledgmentSec     float64   `json:"avg_acknowledgment_sec"`
	P95AcknowledgmentSec     float64   `json:"p95_acknowledgment_sec"`
	SafetyCompliancePercent  float64   `json:"safety_compliance_percent"`
	GeneratedAtUTC           time.Time `json:"generated_at_utc"`
}

// GetCairoLocation returns the Africa/Cairo location, falling back to UTC+2 if tzdata is uninstalled
func GetCairoLocation() *time.Location {
	loc, err := time.LoadLocation(CairoLocationName)
	if err != nil {
		// Egypt Standard Time is UTC+2 without DST, or UTC+3 during seasonal DST
		// Fallback to fixed zone UTC+2
		return time.FixedZone(CairoLocationName, 2*3600)
	}
	return loc
}

// CalculateCairoDayBounds converts a YYYY-MM-DD date in Africa/Cairo to exact UTC query bounds
// from 00:00:00.000 to 23:59:59.999999999 local time (DEC-07 cutoff invariant)
func CalculateCairoDayBounds(dateStr string) (time.Time, time.Time, error) {
	loc := GetCairoLocation()
	t, err := time.ParseInLocation("2006-01-02", dateStr, loc)
	if err != nil {
		return time.Time{}, time.Time{}, fmt.Errorf("%w: %v", ErrInvalidReportDate, err)
	}

	startLocal := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, loc)
	endLocal := time.Date(t.Year(), t.Month(), t.Day(), 23, 59, 59, 999999999, loc)

	return startLocal.UTC(), endLocal.UTC(), nil
}
