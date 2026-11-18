package tests

import (
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// TestCleanArchitectureBoundaries validates architectural boundary separation across backend/internal.
// Strict rules:
// 1. Domain layer must NOT depend on Application, Infrastructure, Presentation, or framework transport/db packages.
// 2. Application layer must NOT depend on Infrastructure or Presentation packages.
func TestCleanArchitectureBoundaries(t *testing.T) {
	// Dynamically locate backend/internal whether run from repo root or tests/
	root := filepath.Join("..", "backend", "internal")
	if _, err := os.Stat(root); os.IsNotExist(err) {
		root = filepath.Join("backend", "internal")
	}
	if _, err := os.Stat(root); os.IsNotExist(err) {
		t.Fatalf("Could not locate backend/internal directory (tried ../backend/internal and backend/internal)")
	}

	// 1. Forbidden imports for domain package
	domainForbidden := []string{
		"application",
		"infrastructure",
		"presentation",
		"database/sql",
		"net/http",
		"google.golang.org/grpc",
		"github.com/gorilla",
		"github.com/gin-gonic",
	}

	// 2. Forbidden imports for application package
	appForbidden := []string{
		"infrastructure",
		"presentation",
	}

	fset := token.NewFileSet()

	// Walk domain package
	domainDir := filepath.Join(root, "domain")
	err := filepath.Walk(domainDir, func(path string, info os.FileInfo, err error) error {
		if err != nil || info.IsDir() || !strings.HasSuffix(path, ".go") {
			return nil
		}

		node, parseErr := parser.ParseFile(fset, path, nil, parser.ImportsOnly)
		if parseErr != nil {
			t.Fatalf("Failed to parse %s: %v", path, parseErr)
		}

		for _, imp := range node.Imports {
			importPath := strings.Trim(imp.Path.Value, `"`)
			for _, forbidden := range domainForbidden {
				if strings.Contains(importPath, forbidden) {
					t.Errorf("[VIOLATION] domain file %s imports forbidden package %s", path, importPath)
				}
			}
		}
		return nil
	})
	if err != nil {
		t.Fatalf("Error walking domain: %v", err)
	}

	// Walk application package
	appDir := filepath.Join(root, "application")
	err = filepath.Walk(appDir, func(path string, info os.FileInfo, err error) error {
		if err != nil || info.IsDir() || !strings.HasSuffix(path, ".go") {
			return nil
		}

		node, parseErr := parser.ParseFile(fset, path, nil, parser.ImportsOnly)
		if parseErr != nil {
			t.Fatalf("Failed to parse %s: %v", path, parseErr)
		}

		for _, imp := range node.Imports {
			importPath := strings.Trim(imp.Path.Value, `"`)
			for _, forbidden := range appForbidden {
				if strings.Contains(importPath, forbidden) {
					t.Errorf("[VIOLATION] application file %s imports forbidden package %s", path, importPath)
				}
			}
		}
		return nil
	})
	if err != nil {
		t.Fatalf("Error walking application: %v", err)
	}
}
