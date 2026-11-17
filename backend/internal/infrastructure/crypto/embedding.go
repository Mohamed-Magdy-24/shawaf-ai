package crypto

import (
	"crypto/sha512"
	"encoding/binary"
	"math"
)

// GenerateNormalizedEmbedding512 generates a 512-dimensional L2-normalized float32 vector (2048 bytes)
// from seed bytes (e.g. photo SHA-256 or raw photo bytes).
func GenerateNormalizedEmbedding512(seed []byte) []byte {
	floats := make([]float32, 512)
	var sumSq float64

	current := seed
	for i := 0; i < 512; i += 16 {
		h := sha512.Sum512(current)
		for j := 0; j < 16 && (i+j) < 512; j++ {
			bits := binary.LittleEndian.Uint32(h[j*4 : (j+1)*4])
			val := (float64(bits)/float64(math.MaxUint32))*2.0 - 1.0
			floats[i+j] = float32(val)
			sumSq += val * val
		}
		current = h[:]
	}

	l2Norm := math.Sqrt(sumSq)
	if l2Norm == 0 {
		l2Norm = 1.0
	}

	result := make([]byte, 512*4)
	for i := 0; i < 512; i++ {
		normalized := float32(float64(floats[i]) / l2Norm)
		binary.LittleEndian.PutUint32(result[i*4:(i+1)*4], math.Float32bits(normalized))
	}
	return result
}

// Float32sFromBytes converts 2048 bytes into a slice of 512 float32s
func Float32sFromBytes(data []byte) []float32 {
	count := len(data) / 4
	res := make([]float32, count)
	for i := 0; i < count; i++ {
		bits := binary.LittleEndian.Uint32(data[i*4 : (i+1)*4])
		res[i] = math.Float32frombits(bits)
	}
	return res
}

// CosineSimilarity computes the dot product of two L2-normalized float32 vectors
func CosineSimilarity(a, b []float32) float32 {
	if len(a) != len(b) || len(a) == 0 {
		return 0.0
	}
	var dot float32
	for i := 0; i < len(a); i++ {
		dot += a[i] * b[i]
	}
	return dot
}
