package publisher

// InmemoryPublisher is a publisher for Inmemory.
type InmemoryPublisher struct {
	Msg   []byte
	Error error
}

// NewInmemoryPublisher returns a new InmemoryPublisher.
func NewInmemoryPublisher() *InmemoryPublisher {
	return &InmemoryPublisher{}
}

// Publish publishes msg.
func (p *InmemoryPublisher) Publish(msg []byte) error {
	p.Msg = msg
	return p.Error
}
