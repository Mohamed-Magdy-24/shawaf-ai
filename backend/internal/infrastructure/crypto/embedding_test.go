package crypto

import (
	"math"
	"testing"
)

func TestEmbeddingGenerationAndNormalization(t *testing.T) {
	seed := []byte("employee_test_seed_image_bytes")
	rawBytes := GenerateNormalizedEmbedding512(seed)

	if len(rawBytes) != 512*4 {
		t.Fatalf("expected 2048 bytes, got %d", len(rawBytes))
	}

	floats := Float32sFromBytes(rawBytes)
	if len(floats) != 512 {
		t.Fatalf("expected 512 floats, got %d", len(floats))
	}

	var sumSq float64
	for _, f := range floats {
		sumSq += float64(f) * float64(f)
	}

	norm := math.Sqrt(sumSq)
	if math.Abs(norm-1.0) > 1e-4 {
		t.Fatalf("expected L2 norm 1.0, got %f", norm)
	}

	// Self-similarity must be ~1.0
	simSelf := CosineSimilarity(floats, floats)
	if math.Abs(float64(simSelf)-1.0) > 1e-4 {
		t.Fatalf("expected self similarity ~1.0, got %f", simSelf)
	}

	// Different seed should have much lower similarity
	diffBytes := GenerateNormalizedEmbedding512([]byte("different_employee_bytes"))
	diffFloats := Float32sFromBytes(diffBytes)
	simDiff := CosineSimilarity(floats, diffFloats)
	if simDiff > 0.45 {
		t.Fatalf("expected different embeddings to have similarity < 0.45, got %f", simDiff)
	}
}
