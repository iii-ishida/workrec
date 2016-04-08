package work

type WorkCollection []Work

func (workCollection WorkCollection) Ordered() WorkCollection {
	return workCollection
}
