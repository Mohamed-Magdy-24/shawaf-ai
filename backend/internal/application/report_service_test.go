package application_test

import (
	"context"
	"testing"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/application"
	"github.com/industrial-ai/surveillance/backend/internal/domain"
)

type mockReportQuery struct {
	incidents []*domain.SafetyIncident
	lastStart time.Time
	lastEnd   time.Time
}

func (m *mockReportQuery) ListByTimeRange(ctx context.Context, siteID string, startUTC, endUTC time.Time) ([]*domain.SafetyIncident, error) {
	m.lastStart = startUTC
	m.lastEnd = endUTC
	return m.incidents, nil
}

func TestReportService_GenerateDailyReport(t *testing.T) {
	ctx := context.Background()

	t.Run("Cairo day bounds calculation", func(t *testing.T) {
		startUTC, endUTC, err := domain.CalculateCairoDayBounds("2026-11-18")
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Egypt is at least UTC+2
		if endUTC.Before(startUTC) {
			t.Errorf("endUTC (%v) must be after startUTC (%v)", endUTC, startUTC)
		}

		duration := endUTC.Sub(startUTC)
		if duration < 23*time.Hour || duration > 25*time.Hour {
			t.Errorf("expected day duration near 24h, got %v", duration)
		}
	})

	t.Run("Empty report produces 100% compliance", func(t *testing.T) {
		mockQuery := &mockReportQuery{incidents: []*domain.SafetyIncident{}}
		svc := application.NewReportService(mockQuery)

		report, err := svc.GenerateDailyReport(ctx, "BNF", "2026-11-18")
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if report.TotalIncidents != 0 {
			t.Errorf("expected 0 total incidents, got %d", report.TotalIncidents)
		}
		if report.SafetyCompliancePercent != 100.0 {
			t.Errorf("expected 100%% compliance, got %f", report.SafetyCompliancePercent)
		}
		if report.Timezone != "Africa/Cairo" {
			t.Errorf("expected timezone Africa/Cairo, got %s", report.Timezone)
		}
	})

	t.Run("Aggregates incidents and computes acknowledgment metrics", func(t *testing.T) {
		t0 := time.Now().UTC()
		tAck1 := t0.Add(30 * time.Second)
		tAck2 := t0.Add(90 * time.Second)

		incidents := []*domain.SafetyIncident{
			{
				ID:               "inc-1",
				SiteID:           "BNF",
				Severity:         domain.SeverityCritical,
				Status:           domain.StatusResolved,
				OccurredAtUTC:    t0,
				AcknowledgedAtUTC: &tAck1,
			},
			{
				ID:               "inc-2",
				SiteID:           "BNF",
				Severity:         domain.SeverityWarning,
				Status:           domain.StatusAcknowledged,
				OccurredAtUTC:    t0,
				AcknowledgedAtUTC: &tAck2,
			},
			{
				ID:            "inc-3",
				SiteID:        "BNF",
				Severity:      domain.SeverityInfo,
				Status:        domain.StatusDismissed,
				OccurredAtUTC: t0,
			},
		}

		mockQuery := &mockReportQuery{incidents: incidents}
		svc := application.NewReportService(mockQuery)

		report, err := svc.GenerateDailyReport(ctx, "BNF", "2026-11-18")
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if report.TotalIncidents != 3 {
			t.Errorf("expected 3 total incidents, got %d", report.TotalIncidents)
		}
		if report.CriticalIncidents != 1 {
			t.Errorf("expected 1 critical, got %d", report.CriticalIncidents)
		}
		if report.WarningIncidents != 1 {
			t.Errorf("expected 1 warning, got %d", report.WarningIncidents)
		}
		if report.InfoIncidents != 1 {
			t.Errorf("expected 1 info, got %d", report.InfoIncidents)
		}
		if report.ResolvedIncidents != 1 {
			t.Errorf("expected 1 resolved, got %d", report.ResolvedIncidents)
		}
		if report.DismissedIncidents != 1 {
			t.Errorf("expected 1 dismissed, got %d", report.DismissedIncidents)
		}

		// Mean acknowledgment: (30 + 90) / 2 = 60s
		if report.AvgAcknowledgmentSec != 60.0 {
			t.Errorf("expected avg acknowledgment 60s, got %f", report.AvgAcknowledgmentSec)
		}
		// Compliance: 100 - (1*15 + 1*3) = 82%
		if report.SafetyCompliancePercent != 82.0 {
			t.Errorf("expected 82%% compliance, got %f", report.SafetyCompliancePercent)
		}
	})

	t.Run("Rejects empty site ID", func(t *testing.T) {
		svc := application.NewReportService(&mockReportQuery{})
		_, err := svc.GenerateDailyReport(ctx, "", "2026-11-18")
		if err != domain.ErrInvalidSiteID {
			t.Errorf("expected ErrInvalidSiteID, got %v", err)
		}
	})
}
