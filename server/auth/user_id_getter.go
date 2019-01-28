package auth

import (
	"context"

	firebase "firebase.google.com/go"
	"google.golang.org/api/option"
)

// UserIDGetter is the interface that for get user id.
type UserIDGetter interface {
	GetUserID(idToken string) (string, error)
}

// FirebaseUserIDGetter is UserIDGetter for Firebase.
type FirebaseUserIDGetter struct{}

// NewFirebaseUserIDGetter returns a new FirebaseUserIDGetter.
func NewFirebaseUserIDGetter() UserIDGetter {
	return FirebaseUserIDGetter{}
}

// GetUserID returns the user id for the given idToken.
func (FirebaseUserIDGetter) GetUserID(idToken string) (string, error) {
	ctx := context.Background()

	opt := option.WithCredentialsFile("./web/serviceAccountKey.json")
	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return "", err
	}

	client, err := app.Auth(ctx)
	if err != nil {
		return "", err
	}

	token, err := client.VerifyIDTokenAndCheckRevoked(ctx, idToken)
	if err != nil {
		return "", err
	}

	return token.UID, nil
}
