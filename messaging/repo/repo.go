package repo

import "net/http"

// Repo is a repository for Topic.
type Repo interface {
	WithRequest(*http.Request) Repo

	DeleteTopic(topicName string) error
	GetSubscriptions(topicName string) ([]string, error)
	SaveSubscriptions(topicName string, subscriptions []string) error
}
