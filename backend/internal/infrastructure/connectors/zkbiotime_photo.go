package connectors

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain/ports"
)

// ZkBioTimePhotoAdapter connects to ZKBioTime terminal export API (SPK-01)
type ZkBioTimePhotoAdapter struct {
	baseURL    string
	apiToken   string
	httpClient *http.Client
}

// NewZkBioTimePhotoAdapter creates a new ZKBioTime photo fetcher
func NewZkBioTimePhotoAdapter(baseURL, apiToken string) *ZkBioTimePhotoAdapter {
	return &ZkBioTimePhotoAdapter{
		baseURL:  baseURL,
		apiToken: apiToken,
		httpClient: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}

func (z *ZkBioTimePhotoAdapter) FetchVerifiedFacePhoto(ctx context.Context, siteID, employeeID string) (*ports.BiometricFacePhoto, error) {
	if z.baseURL == "" {
		return nil, fmt.Errorf("zkbiotime: terminal endpoint not configured")
	}

	reqURL := fmt.Sprintf("%s/api/v1/employees/%s/photo", z.baseURL, employeeID)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, reqURL, nil)
	if err != nil {
		return nil, err
	}
	if z.apiToken != "" {
		req.Header.Set("Authorization", "Token "+z.apiToken)
	}

	resp, err := z.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("zkbiotime fetch failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("zkbiotime returned status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	h := sha256.Sum256(body)
	shaStr := hex.EncodeToString(h[:])

	return &ports.BiometricFacePhoto{
		EmployeeID: employeeID,
		PhotoBytes: body,
		SHA256:     shaStr,
		MimeType:   resp.Header.Get("Content-Type"),
	}, nil
}

var _ ports.BiometricPhotoFetcher = (*ZkBioTimePhotoAdapter)(nil)
