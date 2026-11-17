package crypto

import (
	"testing"
)

func TestAES256GCMEncryptDecrypt(t *testing.T) {
	secret := "test_master_encryption_key_32bytes_sample"
	original := "rtsp_super_secret_password_123!"

	encrypted, err := Encrypt(original, secret)
	if err != nil {
		t.Fatalf("encryption failed: %v", err)
	}

	if encrypted == original {
		t.Fatalf("ciphertext must not equal plaintext")
	}

	decrypted, err := Decrypt(encrypted, secret)
	if err != nil {
		t.Fatalf("decryption failed: %v", err)
	}

	if decrypted != original {
		t.Fatalf("expected decrypted text %q, got %q", original, decrypted)
	}

	// Test wrong key fails
	_, err = Decrypt(encrypted, "wrong_secret_key_value")
	if err == nil {
		t.Fatalf("expected decryption with wrong secret to fail")
	}
}
