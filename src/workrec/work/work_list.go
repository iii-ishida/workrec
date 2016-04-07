package work

import (
	"sort"
)

type WorkList []Work

func (workList WorkList) Ordered() WorkList {
	ordered := make([]Work, len(workList))
	copy(ordered, workList)

	byStartTime().Sort(ordered)
	return ordered
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
