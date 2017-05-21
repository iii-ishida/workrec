package repo

import (
	"net/http"

	"golang.org/x/net/context"

	"google.golang.org/appengine"
	"google.golang.org/appengine/datastore"
)

const (
	_KindTopic = "Topic"
)

type appengineRepo struct {
	ctx context.Context
}

// AppengineRepo is an Appengine implementation of Repo.
var AppengineRepo = appengineRepo{}

type topic struct {
	Name          string
	Subscriptions []string `datastore:",noindex"`
}

func (r appengineRepo) WithRequest(req *http.Request) Repo {
	return appengineRepo{ctx: appengine.NewContext(req)}
}

func (r appengineRepo) DeleteTopic(topicName string) error {
	k := r.newTopicKey(topicName)
	return datastore.Delete(r.ctx, k)
}

func (r appengineRepo) GetSubscriptions(topicName string) ([]string, error) {
	if topicName == "" {
		return []string{}, nil
	}

	k := r.newTopicKey(topicName)
	var t topic
	if err := datastore.Get(r.ctx, k, &t); err != nil {
		if err == datastore.ErrNoSuchEntity {
			return []string{}, nil
		}

		return []string{}, err
	}
	return t.Subscriptions, nil
}

func (r appengineRepo) SaveSubscriptions(topicName string, subscriptions []string) error {
	k := r.newTopicKey(topicName)
	t := topic{Name: topicName, Subscriptions: subscriptions}

	if _, err := datastore.Put(r.ctx, k, &t); err != nil {
		return err
	}
	return nil
}

func (r appengineRepo) newTopicKey(topic string) *datastore.Key {
	return datastore.NewKey(r.ctx, _KindTopic, topic, 0, nil)
}
