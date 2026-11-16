package tests

import (
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// TestCleanArchitecture_DomainPurity asserts that internal/domain has ZERO dependencies on transport frameworks
func TestCleanArchitecture_DomainPurity(t *testing.T) {
	domainDir := filepath.Join("..", "backend", "internal", "domain")
	if _, err := os.Stat(domainDir); os.IsNotExist(err) {
		t.Fatalf("domain directory does not exist: %s", domainDir)
	}

	forbiddenPrefixes := []string{
		"net/http",
		"google.golang.org/grpc",
		"github.com/jackc/pgx",
		"database/sql",
		"github.com/gorilla/websocket",
	}

	fset := token.NewFileSet()
	pkgs, err := parser.ParseDir(fset, domainDir, nil, parser.ImportsOnly)
	if err != nil {
		t.Fatalf("failed to parse domain directory: %v", err)
	}

	for _, pkg := range pkgs {
		for filename, file := range pkg.Files {
			for _, imp := range file.Imports {
				importPath := strings.Trim(imp.Path.Value, `"`)
				for _, forbidden := range forbiddenPrefixes {
					if strings.HasPrefix(importPath, forbidden) {
						t.Errorf("VIOLATION: domain file %s imports forbidden transport/storage package %s", filepath.Base(filename), importPath)
					}
				}
			}
		}
	}
}

// TestADR012_ZeroRawVideo asserts that proto definitions contain no raw byte image buffers
func TestADR012_ZeroRawVideo(t *testing.T) {
	protoFile := filepath.Join("..", "proto", "surveillance", "v1", "events.proto")
	data, err := os.ReadFile(protoFile)
	if err != nil {
		t.Fatalf("failed to read proto file: %v", err)
	}

	content := string(data)
	forbiddenTokens := []string{
		"bytes frame",
		"bytes raw_image",
		"bytes image_buffer",
		"bytes jpeg",
	}

	for _, token := range forbiddenTokens {
		if strings.Contains(content, token) {
			t.Fatalf("ADR-012 VIOLATION: proto file contains forbidden raw video token %s", token)
		}
	}
}
