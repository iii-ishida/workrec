package util

import "os"

// ProjectID returns the GCP Project ID.
func ProjectID() string {
	return os.Getenv("GOOGLE_CLOUD_PROJECT")
}

// ClientOrigin returns the origin for client.
func ClientOrigin() string {
	origin := os.Getenv("CLIENT_ORIGIN")
	if origin != "" {
		return origin
	}
	return "https://" + ProjectID() + ".appspot.com"
}

// APIOrigin returns the origin for api.
func APIOrigin() string {
	origin := os.Getenv("API_ORIGIN")
	if origin != "" {
		return origin
	}
	return "https://api-dot-" + ProjectID() + ".appspot.com"
}
