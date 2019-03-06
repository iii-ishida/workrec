package publisher

// Publisher is a publisher.
type Publisher interface {
	Publish(msg []byte) error
}
