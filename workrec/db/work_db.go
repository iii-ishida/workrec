package db

import (
	"strconv"
	"sync"
)

var (
	currentId     = 0
	currentIdLock sync.RWMutex
)

func NextWorkID() string {
	currentIdLock.Lock()
	defer currentIdLock.Unlock()

	currentId += 1

	return strconv.Itoa(currentId)
}
