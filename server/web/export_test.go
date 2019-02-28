package main

import (
	"github.com/iii-ishida/workrec/server/auth"
)

var mockUserIDGetter auth.UserIDGetter

func init() {
	newAuth = func() auth.Auth {
		return auth.New(auth.Dependency{UserIDGetter: mockUserIDGetter})
	}
}

func SetMockUserIDGetter(m auth.UserIDGetter) {
	mockUserIDGetter = m
}
