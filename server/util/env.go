package util

import "os"

// GetProjectID returns the GCP Project ID.
func GetProjectID() string {
	return os.Getenv("GOOGLE_CLOUD_PROJECT")
}

// GetClientOrigin returns the origin for client.
func GetClientOrigin() string {
	origin := os.Getenv("CLIENT_ORIGIN")
	if origin != "" {
		return origin
	}
	return "https://" + GetProjectID() + ".appspot.com"
}

// GetAPIOrigin returns the origin for api.
func GetAPIOrigin() string {
	origin := os.Getenv("API_ORIGIN")
	if origin != "" {
		return origin
	}
	return "https://api-dot-" + GetProjectID() + ".appspot.com"
}
