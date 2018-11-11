package util

import "os"

// GetProjectID returns the GCP Project ID.
func GetProjectID() string {
	return os.Getenv("GOOGLE_CLOUD_PROJECT")
}
