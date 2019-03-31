package main

import (
	"context"

	"cloud.google.com/go/pubsub"
	"github.com/iii-ishida/workrec/server/publisher"
	"github.com/iii-ishida/workrec/server/util"
)

func main() {
	ctx := context.Background()
	client, _ := pubsub.NewClient(ctx, util.ProjectID())
	client.CreateTopic(ctx, publisher.CloudPublisherTopicID)
}
