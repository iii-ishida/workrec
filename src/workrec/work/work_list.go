package work

import (
	"encoding/json"
	"io"
	"sort"
)

type WorkList []Work

func WorkListFromJSON(r io.Reader) (WorkList, error) {
	var workList WorkList
	decoder := json.NewDecoder(r)
	err := decoder.Decode(&workList)

	return workList, err
}

func (workList WorkList) Equal(another WorkList) bool {
	isEqual := len(workList) == len(another)
	if !isEqual {
		return false
	}

	for i, work := range workList {
		anotherWork := another[i]
		isEqual = work.Equal(anotherWork)
		if !isEqual {
			return false
		}
	}
	return isEqual
}

func (workList WorkList) Ordered() WorkList {
	ordered := make([]Work, len(workList))
	copy(ordered, workList)

	byStartTime().Sort(ordered)
	return ordered
}

func (workList WorkList) Select(ids []string) WorkList {
	idMap := make(map[string]struct{}, len(ids))
	for _, id := range ids {
		idMap[id] = struct{}{}
	}

	selected := WorkList{}
	for _, work := range workList {
		if _, ok := idMap[work.ID]; ok {
			selected = append(selected, work)
		}
	}
	return selected
}

func byStartTime() by {
	return func(work1, work2 *Work) bool {
		startTime1 := work1.StartTime()
		startTime2 := work2.StartTime()
		if startTime1.Equal(startTime2) {
			return true
		}
		return startTime1.After(startTime2)
	}
}

type by func(work1, work2 *Work) bool

func (by by) Sort(works []Work) {
	sorter := &workSroter{
		works: works,
		by:    by,
	}
	sort.Sort(sorter)
}

type workSroter struct {
	works []Work
	by    by
}

func (s *workSroter) Len() int {
	return len(s.works)
}

func (s *workSroter) Swap(i, j int) {
	s.works[i], s.works[j] = s.works[j], s.works[i]
}

func (s *workSroter) Less(i, j int) bool {
	return s.by(&s.works[i], &s.works[j])
}
