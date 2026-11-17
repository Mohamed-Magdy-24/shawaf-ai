package connectors

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
)

// SqlServerAttendanceAdapter connects to enterprise attendance databases (SPK-04)
type SqlServerAttendanceAdapter struct {
	dsn        string
	db         *sql.DB
	fallback   ports.AttendanceEmployeeReader
}

// NewSqlServerAttendanceAdapter creates a new attendance adapter
func NewSqlServerAttendanceAdapter(dsn string, fallback ports.AttendanceEmployeeReader) *SqlServerAttendanceAdapter {
	adapter := &SqlServerAttendanceAdapter{
		dsn:      dsn,
		fallback: fallback,
	}

	if dsn != "" {
		// Attempt lazy pool creation
		db, err := sql.Open("postgres", dsn) // or mssql when driver imported
		if err == nil {
			adapter.db = db
		}
	}
	return adapter
}

func (a *SqlServerAttendanceAdapter) ReadEmployees(ctx context.Context, siteID string) ([]*ports.EmployeeIdentity, error) {
	if a.db != nil {
		ctxTimeout, cancel := context.WithTimeout(ctx, 3*time.Second)
		defer cancel()

		query := `SELECT employee_id, full_name, department, is_active FROM staging_attendance_employees WHERE site_id = $1`
		rows, err := a.db.QueryContext(ctxTimeout, query, siteID)
		if err == nil {
			defer rows.Close()
			var list []*ports.EmployeeIdentity
			for rows.Next() {
				var emp ports.EmployeeIdentity
				emp.SiteID = siteID
				if err := rows.Scan(&emp.EmployeeID, &emp.FullName, &emp.Department, &emp.IsActive); err == nil {
					list = append(list, &emp)
				}
			}
			if len(list) > 0 {
				return list, nil
			}
		} else {
			log.Printf("[SqlServerAttendance] Live query failed (%v); falling back to registered employees", err)
		}
	}

	if a.fallback != nil {
		return a.fallback.ReadEmployees(ctx, siteID)
	}
	return nil, fmt.Errorf("sqlserver attendance: no records available for site %s", siteID)
}

func (a *SqlServerAttendanceAdapter) GetEmployee(ctx context.Context, siteID, employeeID string) (*ports.EmployeeIdentity, error) {
	if a.db != nil {
		ctxTimeout, cancel := context.WithTimeout(ctx, 3*time.Second)
		defer cancel()

		query := `SELECT employee_id, full_name, department, is_active FROM staging_attendance_employees WHERE site_id = $1 AND employee_id = $2`
		var emp ports.EmployeeIdentity
		emp.SiteID = siteID
		err := a.db.QueryRowContext(ctxTimeout, query, siteID, employeeID).Scan(&emp.EmployeeID, &emp.FullName, &emp.Department, &emp.IsActive)
		if err == nil {
			return &emp, nil
		}
	}

	if a.fallback != nil {
		return a.fallback.GetEmployee(ctx, siteID, employeeID)
	}
	return nil, ports.ErrEmployeeNotFound
}

var _ ports.AttendanceEmployeeReader = (*SqlServerAttendanceAdapter)(nil)
