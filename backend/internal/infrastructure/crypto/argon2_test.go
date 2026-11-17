package crypto

import (
	"testing"
)

func TestArgon2id_HashAndVerify(t *testing.T) {
	rawPassword := "AdminPassword123!"

	hash, err := HashPassword(rawPassword)
	if err != nil {
		t.Fatalf("failed to hash password: %v", err)
	}
	t.Logf("ADMIN HASH: %s", hash)

	valid, err := VerifyPassword(rawPassword, hash)
	if err != nil {
		t.Fatalf("failed to verify password: %v", err)
	}
	if !valid {
		t.Errorf("expected valid password verification, got false")
	}

	wrongPassword := "WrongPassword123!"
	invalid, err := VerifyPassword(wrongPassword, hash)
	if err != nil {
		t.Fatalf("unexpected error on wrong password: %v", err)
	}
	if invalid {
		t.Errorf("expected wrong password to fail verification, got true")
	}
}
