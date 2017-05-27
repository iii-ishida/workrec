package repo_test

import (
	"strconv"
	"testing"
	"workrec/query/model"
	"workrec/query/repo"

	"google.golang.org/appengine/aetest"
)

func TestAppengineRepo(t *testing.T) {
	inst, _ := aetest.NewInstance(&aetest.Options{StronglyConsistentDatastore: true})
	req, _ := inst.NewRequest("GET", "/", nil)
	defer inst.Close()

	re := repo.AppengineRepo.WithRequest(req)

	// Save Test
	for i := 0; i < 100; i++ {
		id := strconv.Itoa(i)
		title := "A-" + id
		work := model.Work{ID: id, Title: title, UpdatedAt: int64(i + 1)}
		if err := re.SaveWork(work); err != nil {
			t.Fatalf("Save error: %v", err)
		}
	}

	// GetList Test
	list, err := re.GetList(10, "")
	if err != nil {
		t.Fatalf("Get error: %v", err)
	}
	if l := len(list.Works); l != 10 {
		t.Errorf("len(list.Works) = %d, wants = 10", l)
	}
	if n := list.Next; n == "" {
		t.Error("list.Next is Empty")
	}

	wantsUpdatedAt := int64(100)
	for i, s := range list.Works {
		if s.UpdatedAt != wantsUpdatedAt {
			t.Errorf("works[%d].UpdatedAt = %d, wants = %d", i, s.UpdatedAt, wantsUpdatedAt)
		}
		wantsUpdatedAt--
	}

	// Get Next Test
	list, err = re.GetList(90, list.Next)
	if err != nil {
		t.Fatalf("Get error: %v", err)
	}
	if l := len(list.Works); l != 90 {
		t.Errorf("len(list.Works) = %d, wants = 90", l)
	}
	if n := list.Next; n != "" {
		t.Errorf("list.Next = %s, wants Empty", n)
	}
	wantsUpdatedAt = int64(90)
	for i, s := range list.Works {
		if s.UpdatedAt != wantsUpdatedAt {
			t.Errorf("list[%d].UpdatedAt = %d, wants = %d", i, s.UpdatedAt, wantsUpdatedAt)
		}
		wantsUpdatedAt--
	}

	// Delete Test
	if err := re.DeleteWork("98"); err != nil {
		t.Fatalf("Delete error: %v", err)
	}

	list, err = re.GetList(5, "")
	if err != nil {
		t.Fatalf("Get error: %v", err)
	}
	if l := len(list.Works); l != 5 {
		t.Errorf("len(list.Works) = %d, wants = 5", l)
	}

	if id := list.Works[0].ID; id != "99" {
		t.Errorf("list.Works[0].ID = %s, wants = 99", id)
	}
	if id := list.Works[1].ID; id != "97" {
		t.Errorf("list.Works[1].ID = %s, wants = 97", id)
	}
	if id := list.Works[4].ID; id != "94" {
		t.Errorf("list.Works[4].ID = %s, wants = 94", id)
	}
}
