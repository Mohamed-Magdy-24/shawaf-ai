package application

import (
	"context"
	"fmt"
	"sort"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

// ReportIncidentQuery defines the read port for historical incidents
type ReportIncidentQuery interface {
	ListByTimeRange(ctx context.Context, siteID string, startUTC, endUTC time.Time) ([]*domain.SafetyIncident, error)
}

// ReportService coordinates in-app shift/daily reporting and cutoff calculations (DEC-07)
type ReportService struct {
	queryPort ReportIncidentQuery
}

// NewReportService constructs a new ReportService
func NewReportService(queryPort ReportIncidentQuery) *ReportService {
	return &ReportService{queryPort: queryPort}
}

// GenerateDailyReport generates safety incident aggregations for an Egyptian factory site
// strictly bounded by 00:00:00 to 23:59:59 Africa/Cairo local time (DEC-07)
func (s *ReportService) GenerateDailyReport(ctx context.Context, siteID string, dateStr string) (*domain.DailySiteReport, error) {
	if siteID == "" {
		return nil, domain.ErrInvalidSiteID
	}

	startUTC, endUTC, err := domain.CalculateCairoDayBounds(dateStr)
	if err != nil {
		return nil, fmt.Errorf("failed calculating Cairo day bounds: %w", err)
	}

	incidents, err := s.queryPort.ListByTimeRange(ctx, siteID, startUTC, endUTC)
	if err != nil {
		return nil, fmt.Errorf("failed querying incidents for site %s: %w", siteID, err)
	}

	report := &domain.DailySiteReport{
		SiteID:         siteID,
		ReportDate:     dateStr,
		Timezone:       domain.CairoLocationName,
		PeriodStartUTC: startUTC,
		PeriodEndUTC:   endUTC,
		TotalIncidents: len(incidents),
		GeneratedAtUTC: time.Now().UTC(),
	}

	var ackDurations []float64

	for _, inc := range incidents {
		switch inc.Severity {
		case domain.SeverityCritical, domain.SeverityCriticalFire:
			report.CriticalIncidents++
		case domain.SeverityWarning:
			report.WarningIncidents++
		case domain.SeverityInfo:
			report.InfoIncidents++
		}

		switch inc.Status {
		case domain.StatusAcknowledged:
			report.AcknowledgedIncidents++
		case domain.StatusResolved:
			report.ResolvedIncidents++
		case domain.StatusDismissed:
			report.DismissedIncidents++
		}

		if inc.AcknowledgedAt != nil && !inc.AcknowledgedAt.IsZero() {
			diff := inc.AcknowledgedAt.Sub(inc.OccurredAtUTC).Seconds()
			if diff >= 0 {
				ackDurations = append(ackDurations, diff)
			}
		}
	}

	// Calculate latency percentiles
	if len(ackDurations) > 0 {
		sort.Float64s(ackDurations)
		var totalSec float64
		for _, d := range ackDurations {
			totalSec += d
		}
		report.AvgAcknowledgmentSec = totalSec / float64(len(ackDurations))
		
		// P95 calculation
		p95Idx := int(float64(len(ackDurations))*0.95)
		if p95Idx >= len(ackDurations) {
			p95Idx = len(ackDurations) - 1
		}
		report.P95AcknowledgmentSec = ackDurations[p95Idx]
	}

	// Calculate Safety Compliance %
	// Baseline: 100% when 0 critical incidents; penalized by critical violations
	if report.TotalIncidents == 0 {
		report.SafetyCompliancePercent = 100.0
	} else {
		penalty := float64(report.CriticalIncidents*15 + report.WarningIncidents*3)
		score := 100.0 - penalty
		if score < 0 {
			score = 0
		}
		report.SafetyCompliancePercent = score
	}

	return report, nil
}
