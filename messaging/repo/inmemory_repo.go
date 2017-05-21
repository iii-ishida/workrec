package repo

import "net/http"

var subscriptions = map[string][]string{}

type inmemoryRepo struct{}

// InmemoryRepo is a Inmemory implementation of Repo.
var InmemoryRepo = inmemoryRepo{}

func (r inmemoryRepo) WithRequest(_ *http.Request) Repo {
	return r
}

func (inmemoryRepo) Reset() {
	subscriptions = map[string][]string{}
}

func (inmemoryRepo) DeleteTopic(topicName string) error {
	delete(subscriptions, topicName)
	return nil
}

func (inmemoryRepo) GetSubscriptions(topicName string) ([]string, error) {
	return subscriptions[topicName], nil
}

func (inmemoryRepo) SaveSubscriptions(topicName string, _subscriptions []string) error {
	subscriptions[topicName] = _subscriptions
	return nil
}
