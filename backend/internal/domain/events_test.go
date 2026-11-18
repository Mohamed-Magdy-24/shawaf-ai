package domain

import (
	"testing"
	"time"
)

func TestNewSafetyIncident_Validation(t *testing.T) {
	now := time.Now().UTC()

	// 1. Missing Site ID
	_, err := NewSafetyIncident("evt-1", "", "cam-1", "zone-1", "entry.detected", SeverityWarning, now, "yolox", "1.0", 0.9, nil, "snap.jpg")
	if err != ErrInvalidSiteID {
		t.Fatalf("expected ErrInvalidSiteID, got %v", err)
	}

	// 2. Missing Camera ID
	_, err = NewSafetyIncident("evt-1", "site_bnf", "", "zone-1", "entry.detected", SeverityWarning, now, "yolox", "1.0", 0.9, nil, "snap.jpg")
	if err != ErrInvalidCameraID {
		t.Fatalf("expected ErrInvalidCameraID, got %v", err)
	}

	// 3. Invalid Severity
	_, err = NewSafetyIncident("evt-1", "site_bnf", "cam-1", "zone-1", "entry.detected", "INVALID_SEV", now, "yolox", "1.0", 0.9, nil, "snap.jpg")
	if err != ErrInvalidSeverity {
		t.Fatalf("expected ErrInvalidSeverity, got %v", err)
	}

	// 4. Valid Incident creation (starts in StatusNew)
	inc, err := NewSafetyIncident("evt-1", "site_bnf", "cam-1", "zone-1", "entry.detected", SeverityCritical, now, "yolox", "1.0", 0.95, []BoundingBox{
		{X1: 10, Y1: 10, X2: 50, Y2: 50, Label: "PERSON", Confidence: 0.95},
	}, "site_bnf/2026/11/18/evt-1.jpg")
	if err != nil {
		t.Fatalf("expected nil error, got %v", err)
	}
	if inc.Status != StatusNew {
		t.Fatalf("expected status NEW, got %s", inc.Status)
	}
}

func TestSafetyIncident_WorkflowTransitions(t *testing.T) {
	now := time.Now().UTC()
	inc, err := NewSafetyIncident("evt-2", "site_bnf", "cam-1", "zone-1", "entry.detected", SeverityWarning, now, "yolox", "1.0", 0.9, nil, "snap.jpg")
	if err != nil {
		t.Fatalf("failed to create incident: %v", err)
	}

	// 1. NEW -> ACKNOWLEDGED
	if err := inc.Acknowledge("operator_1"); err != nil {
		t.Fatalf("expected successful acknowledge, got %v", err)
	}
	if inc.Status != StatusAcknowledged || inc.AcknowledgedBy != "operator_1" || inc.AcknowledgedAt == nil {
		t.Fatalf("acknowledge fields not populated correctly: %+v", inc)
	}

	// Double acknowledge should fail
	if err := inc.Acknowledge("operator_2"); err != ErrInvalidStateTransition {
		t.Fatalf("expected ErrInvalidStateTransition on second acknowledge, got %v", err)
	}

	// 2. ACKNOWLEDGED -> RESOLVED
	if err := inc.Resolve("operator_1"); err != nil {
		t.Fatalf("expected successful resolve, got %v", err)
	}
	if inc.Status != StatusResolved || inc.ResolvedBy != "operator_1" || inc.ResolvedAt == nil {
		t.Fatalf("resolve fields not populated correctly: %+v", inc)
	}

	// Cannot acknowledge a resolved incident
	if err := inc.Acknowledge("operator_1"); err != ErrInvalidStateTransition {
		t.Fatalf("expected ErrInvalidStateTransition, got %v", err)
	}
}

func TestSafetyIncident_DismissWorkflow(t *testing.T) {
	now := time.Now().UTC()
	inc, _ := NewSafetyIncident("evt-3", "site_bnf", "cam-1", "zone-1", "entry.detected", SeverityInfo, now, "yolox", "1.0", 0.8, nil, "snap.jpg")

	// Missing reason must fail
	if err := inc.Dismiss("operator_1", ""); err != ErrDismissalReasonRequired {
		t.Fatalf("expected ErrDismissalReasonRequired, got %v", err)
	}

	// Valid dismissal with reason
	if err := inc.Dismiss("operator_1", "Authorized maintenance crew drill"); err != nil {
		t.Fatalf("expected successful dismissal, got %v", err)
	}
	if inc.Status != StatusDismissed || inc.DismissalReason != "Authorized maintenance crew drill" {
		t.Fatalf("dismissal fields not set properly: %+v", inc)
	}
}
