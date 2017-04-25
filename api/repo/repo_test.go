package repo_test

import (
	"errors"
	"reflect"
	"testing"
	"workrec/api/event"
	"workrec/api/model"
	"workrec/api/repo"

	"google.golang.org/appengine/aetest"
)

func TestAppengineRepo(t *testing.T) {
	inst, _ := aetest.NewInstance(&aetest.Options{StronglyConsistentDatastore: true})
	req, _ := inst.NewRequest("GET", "/", nil)
	defer inst.Close()

	re := repo.AppengineRepo.WithRequest(req)
	testRepoForWork(t, re)
	testRepoForEvent(t, re)
	testTransaction(t, re)
}

func TestInmemoryRepo(t *testing.T) {
	testRepoForWork(t, repo.InmemoryRepo.WithRequest(nil))
	testRepoForEvent(t, repo.InmemoryRepo.WithRequest(nil))
}

func testRepoForWork(t *testing.T, re repo.Repo) {
	w := model.CreateWork("A").Start(10).Pause(20).Resume(30).Finish(40)

	// Save Test
	if err := re.SaveWork(w); err != nil {
		t.Fatalf("SaveWork error: %v", err)
	}

	// Get Test
	if saved, err := re.GetWork(w.ID); err != nil {
		t.Fatalf("GetWork error: %v", err)
	} else if !saved.Equal(w) {
		t.Errorf("GetWork = %#v, wants = %#v", saved, w)
	}

	// Delete Test
	if err := re.SaveWork(w.Delete()); err != nil {
		t.Fatalf("SaveWork(Delete) error: %v", err)
	}

	if w2, err := re.GetWork(w.ID); err != nil {
		t.Fatalf("GetWork error: %v", err)
	} else if !w2.Equal(model.Work{}) {
		t.Errorf("GetWork = %#v, wants Empty", w2)
	}
}

func testRepoForEvent(t *testing.T, re repo.Repo) {
	e := event.NewForCreated("123", "A", 10)

	// Save Test
	if err := re.SaveEvent(e); err != nil {
		t.Fatalf("SaveEvent error: %v", err)
	}

	// Get Test
	if saved, err := re.GetEvent(e.ID); err != nil {
		t.Fatalf("GetEvent error: %v", err)
	} else if !reflect.DeepEqual(saved, e) {
		t.Errorf("GetEvent = %#v, wants = %#v", saved, e)
	}
}

func testTransaction(t *testing.T, re repo.Repo) {
	w := model.CreateWork("A").Start(10).Pause(20).Resume(30).Finish(40)

	// Rollback Test
	re.RunInTransaction(func() error {
		if err := re.SaveWork(w); err != nil {
			t.Fatalf("SaveWork error: %v", err)
		}
		if err := re.SaveEvent(w.Change()); err != nil {
			t.Fatalf("SaveEvent error: %v", err)
		}
		return errors.New("DUMMY")
	})

	if saved, err := re.GetWork(w.ID); err != nil {
		t.Fatalf("GetWork error: %v", err)
	} else if !saved.Equal(model.Work{}) {
		t.Error("transaction was not rollback (work)")
	}
	if saved, err := re.GetEvent(w.Change().ID); err != nil {
		t.Fatalf("GetEvent error: %v", err)
	} else if !reflect.DeepEqual(saved, event.Event{}) {
		t.Error("transaction was not rollback (event)")
	}

	// Commit Test
	re.RunInTransaction(func() error {
		if err := re.SaveWork(w); err != nil {
			t.Fatalf("SaveWork error: %v", err)
		}
		if err := re.SaveEvent(w.Change()); err != nil {
			t.Fatalf("SaveEvent error: %v", err)
		}
		return nil
	})

	if saved, err := re.GetWork(w.ID); err != nil {
		t.Fatalf("GetWork error: %v", err)
	} else if !saved.Equal(w) {
		t.Error("transaction was rollback (work)")
	}
	if saved, err := re.GetEvent(w.Change().ID); err != nil {
		t.Fatalf("GetEvent error: %v", err)
	} else if !reflect.DeepEqual(saved, w.Change()) {
		t.Error("transaction was rollback (event)")
	}
}
