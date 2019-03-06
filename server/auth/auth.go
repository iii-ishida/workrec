package auth

import (
	"context"
	"net/http"
	"strings"

	"github.com/iii-ishida/workrec/server/util"
)

type contextKey string

const contextKeyUserID = contextKey("user-id")

// Dependency is a dependency for the auth.
type Dependency struct {
	UserIDGetter
}

// Auth is auth.
type Auth struct {
	dep Dependency
}

// New returns a new Auth.
func New(dep Dependency) Auth {
	return Auth{dep: dep}
}

// Handler handles a request and processes for auth.
func (a Auth) Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		authComponents := strings.Split(authHeader, " ")

		idToken := ""
		if len(authComponents) > 1 {
			idToken = authComponents[1]
		}

		if idToken == "" {
			next.ServeHTTP(w, r)
			return
		}

		userID, err := a.dep.UserIDGetter.GetUserID(idToken)
		if err != nil {
			util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
			return
		}

		ctx := context.WithValue(r.Context(), contextKeyUserID, userID)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// GetUserID returns a userID from the ctx.
func GetUserID(ctx context.Context) string {
	userID, ok := ctx.Value(contextKeyUserID).(string)
	if !ok {
		return ""
	}
	return userID
}

// ContextWithUserID returns a copy of parent in which the userID.
func ContextWithUserID(parent context.Context, userID string) context.Context {
	return context.WithValue(parent, contextKeyUserID, userID)
}
