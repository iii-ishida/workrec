package publisher

import (
	"context"
	"net/http"

	"cloud.google.com/go/pubsub"
	"github.com/iii-ishida/workrec/server/util"
)

const topicID = "workrec"

// CloudPublisher is a publisher for Cloud Pub/Sub.
type CloudPublisher struct {
	ctx context.Context
}

// NewCloudPublisher returns a new CloudPublisher.
func NewCloudPublisher(r *http.Request) CloudPublisher {
	return CloudPublisher{ctx: r.Context()}
}

// Publish publishes msg.
func (p CloudPublisher) Publish(msg []byte) error {
	client, err := pubsub.NewClient(p.ctx, util.ProjectID())
	if err != nil {
		return err
	}
	defer client.Close()

	topic := client.Topic(topicID)
	_, err = topic.Publish(p.ctx, &pubsub.Message{Data: msg}).Get(p.ctx)

	return err
}
