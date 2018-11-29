package command_test

import (
	"errors"
	"fmt"
	"testing"
	"time"

	"github.com/golang/mock/gomock"
	"github.com/iii-ishida/workrec/server/command"
	"github.com/iii-ishida/workrec/server/command/model"
	"github.com/iii-ishida/workrec/server/command/store"
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/testutil"
	"github.com/iii-ishida/workrec/server/util"
)

type tranFunc func(store.Store) error

func TestCreateWork(t *testing.T) {
	t.Run("登録OK", func(t *testing.T) {
		mockCtrl := gomock.NewController(t)
		defer mockCtrl.Finish()

		mockStore := store.NewMockStore(mockCtrl)
		mockStoreInTran := store.NewMockStore(mockCtrl)

		mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
			return f(mockStoreInTran)
		})

		var e event.Event
		mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Do(func(evnt event.Event) {
			e = evnt
		})

		var w model.Work
		mockStoreInTran.EXPECT().PutWork(gomock.Any()).Do(func(work model.Work) {
			w = work
		})

		paramTitle := "Some Title"
		cmd := command.New(command.Dependency{Store: mockStore})
		id, err := cmd.CreateWork(command.CreateWorkParam{Title: paramTitle})

		t.Run("登録したWorkのIDが返却されること", func(t *testing.T) {
			if id == "" {
				t.Fatal("id is empty, wants not empty")
			}
			if id != w.ID {
				t.Errorf("id = %s, wants = %s (work.ID)", id, w.ID)
			}
		})

		t.Run("errorがnil であること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants nil", err)
			}
		})

		t.Run("Event", func(t *testing.T) {
			t.Run("IDにUUIDを設定すること", func(t *testing.T) {
				if e.ID == "" {
					t.Error("event.ID is empty, wants not empty")
				}
				if !testutil.IsUUID(e.ID) {
					t.Error("event.ID is not UUID, wants UUID")
				}
			})
			t.Run("PrevIDに空文字を設定すること", func(t *testing.T) {
				if e.PrevID != "" {
					t.Error("event.PrevID is not empty, wants empty")
				}
			})
			t.Run("WorkIDに作成したWorkのIDを設定すること", func(t *testing.T) {
				if e.WorkID != w.ID {
					t.Errorf("event.WorkID = %s, wants = %s (work.ID)", e.ID, w.ID)
				}
			})
			t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
				if e.Title != paramTitle {
					t.Errorf("event.Title = %s, wants = %s", e.Title, paramTitle)
				}
			})
			t.Run("ActionにCreateWorkを設定すること", func(t *testing.T) {
				if e.Action != event.CreateWork {
					t.Errorf("event.Action = %s, wants = %s", e.Action, event.CreateWork)
				}
			})
			t.Run("CreatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(e.CreatedAt) {
					t.Errorf("event.CreatedAt = %s, wants now", e.CreatedAt)
				}
			})
		})

		t.Run("Work", func(t *testing.T) {
			t.Run("IDにUUIDを設定すること", func(t *testing.T) {
				if w.ID == "" {
					t.Error("work.ID is empty, wants not empty")
				}
				if !testutil.IsUUID(w.ID) {
					t.Error("work.ID is not UUID, wants UUID")
				}
			})
			t.Run("EventIDに作成したPutEventで登録したeventのIDを設定すること", func(t *testing.T) {
				if w.EventID != e.ID {
					t.Errorf("work.EventID = %s, wants = %s (event.ID)", w.EventID, e.ID)
				}
			})
			t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
				if w.Title != paramTitle {
					t.Errorf("work.Title = %s, wants = %s", w.Title, paramTitle)
				}
			})
			t.Run("Timeにゼロ値を設定すること", func(t *testing.T) {
				if !w.Time.IsZero() {
					t.Errorf("work.Time = %s, wants Zero", w.Time)
				}
			})
			t.Run("StateにUnstartedを設定すること", func(t *testing.T) {
				if w.State != model.Unstarted {
					t.Errorf("work.State = %s, wants = %s", w.State, model.Unstarted)
				}
			})
			t.Run("UpdatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(w.UpdatedAt) {
					t.Errorf("work.UpdatedAt = %s, wants now", w.UpdatedAt)
				}
			})
		})

		t.Run("Event.CreatedAtとWork.UpdatedAtが同じであること", func(t *testing.T) {
			if !e.CreatedAt.Equal(w.UpdatedAt) {
				t.Errorf("event.CreatedAt(%v) != work.UpdatedAt(%v), wants equals", e.CreatedAt, w.UpdatedAt)
			}
		})
	})

	t.Run("登録エラー", func(t *testing.T) {
		someErr := errors.New("Some Error")

		t.Run("Store#PutEventがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Return(someErr)

			cmd := command.New(command.Dependency{Store: mockStore})
			_, err := cmd.CreateWork(command.CreateWorkParam{Title: "Some Title"})

			if err == nil {
				t.Fatal("error is nil, wants not nil")
			}
			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})

		t.Run("Store#PutWorkがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})
			mockStoreInTran.EXPECT().PutEvent(gomock.Any())

			mockStoreInTran.EXPECT().PutWork(gomock.Any()).Return(someErr)

			cmd := command.New(command.Dependency{Store: mockStore})
			_, err := cmd.CreateWork(command.CreateWorkParam{Title: "Some Title"})

			if err == nil {
				t.Fatal("error is nil, wants not nil")
			}

			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})
	})
}

func TestUpdateWork(t *testing.T) {
	workTime := time.Now().Add(-1 * time.Hour)
	source := model.Work{
		ID:        util.NewUUID(),
		EventID:   util.NewUUID(),
		Title:     "Some Title",
		Time:      workTime,
		State:     model.Started,
		UpdatedAt: time.Now(),
	}

	t.Run("更新OK", func(t *testing.T) {
		mockCtrl := gomock.NewController(t)
		defer mockCtrl.Finish()

		mockStore := store.NewMockStore(mockCtrl)
		mockStoreInTran := store.NewMockStore(mockCtrl)

		mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
			return f(mockStoreInTran)
		})

		mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
			*dst = source
		})

		var e event.Event
		mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Do(func(evnt event.Event) {
			e = evnt
		})

		var w model.Work
		mockStoreInTran.EXPECT().PutWork(gomock.Any()).Do(func(work model.Work) {
			w = work
		})

		paramTitle := "Updated Title"
		cmd := command.New(command.Dependency{Store: mockStore})
		err := cmd.UpdateWork(source.ID, command.UpdateWorkParam{Title: paramTitle})

		t.Run("errorがnil であること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants nil", err)
			}
		})

		t.Run("Event", func(t *testing.T) {
			t.Run("IDにUUIDを設定すること", func(t *testing.T) {
				if e.ID == "" {
					t.Error("event.ID is empty, wants not empty")
				}
				if !testutil.IsUUID(e.ID) {
					t.Error("event.ID is not UUID, wants UUID")
				}
			})
			t.Run("PrevIDに更新前のWork.EventIDを設定すること", func(t *testing.T) {
				if e.PrevID != source.EventID {
					t.Errorf("event.PrevID = %s, wants = work.EventID(%s)", e.PrevID, source.EventID)
				}
			})
			t.Run("WorkIDに更新したWorkのIDを設定すること", func(t *testing.T) {
				if e.WorkID != w.ID {
					t.Errorf("event.WorkID = %s, wants = %s (work.ID)", e.ID, w.ID)
				}
			})
			t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
				if e.Title != paramTitle {
					t.Errorf("event.Title = %s, wants = %s", e.Title, paramTitle)
				}
			})
			t.Run("ActionにUpdateWorkを設定すること", func(t *testing.T) {
				if e.Action != event.UpdateWork {
					t.Errorf("event.Type = %s, wants = %s", e.Action, event.UpdateWork)
				}
			})
			t.Run("CreatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(e.CreatedAt) {
					t.Errorf("event.CreatedAt = %s, wants now", e.CreatedAt)
				}
			})
		})

		t.Run("Work", func(t *testing.T) {
			t.Run("IDに更新前のWork.IDを設定すること", func(t *testing.T) {
				if w.ID != source.ID {
					t.Errorf("work.ID = %s, wants = %s", w.ID, source.ID)
				}
			})
			t.Run("EventIDに作成したPutEventで登録したEventのIDを設定すること", func(t *testing.T) {
				if w.EventID == source.EventID {
					t.Error("work.EventID = source.EventID, wants not equals")
				}
				if w.EventID != e.ID {
					t.Errorf("work.EventID = %s, wants = %s (event.ID)", w.EventID, e.ID)
				}
			})
			t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
				if w.Title != paramTitle {
					t.Errorf("work.Title = %s, wants = %s", w.Title, paramTitle)
				}
			})
			t.Run("Timeに更新前のWork.Timeを設定すること", func(t *testing.T) {
				if !w.Time.Equal(source.Time) {
					t.Errorf("work.Time = %s, wants = %s", w.Time, source.Time)
				}
			})
			t.Run("Stateに更新前のWork.Stateを設定すること", func(t *testing.T) {
				if w.State != source.State {
					t.Errorf("work.State = %s, wants = %s", w.State, source.State)
				}
			})
			t.Run("UpdatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(w.UpdatedAt) {
					t.Errorf("work.UpdatedAt = %s, wants now", w.UpdatedAt)
				}
			})
		})

		t.Run("Event.CreatedAtとWork.UpdatedAtが同じであること", func(t *testing.T) {
			if !e.CreatedAt.Equal(w.UpdatedAt) {
				t.Errorf("event.CreatedAt(%v) != work.UpdatedAt(%v), wants equals", e.CreatedAt, w.UpdatedAt)
			}
		})
	})

	t.Run("更新エラー", func(t *testing.T) {
		someErr := errors.New("Some Error")

		t.Run("Store#GetWorkがErrNotfoundの場合はErrNotfoundを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Return(store.ErrNotfound)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.UpdateWork(util.NewUUID(), command.UpdateWorkParam{Title: "Updated Title"})

			if err != command.ErrNotfound {
				t.Errorf("error = %#v, wants = %#v", err, command.ErrNotfound)
			}
		})

		t.Run("Store#PutEventがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})
			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any())

			mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Return(someErr)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.UpdateWork(util.NewUUID(), command.UpdateWorkParam{Title: "Updated Title"})

			if err == nil {
				t.Fatal("error is nil, wants not nil")
			}

			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})

		t.Run("Store#PutWorkがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})
			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any())
			mockStoreInTran.EXPECT().PutEvent(gomock.Any())

			mockStoreInTran.EXPECT().PutWork(gomock.Any()).Return(someErr)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.UpdateWork(util.NewUUID(), command.UpdateWorkParam{Title: "Updated Title"})

			if err == nil {
				t.Fatal("error is nil, wants not nil")
			}

			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})
	})
}

func TestDeleteWork(t *testing.T) {
	source := model.Work{
		ID:        util.NewUUID(),
		EventID:   util.NewUUID(),
		Title:     "Some Title",
		Time:      time.Now(),
		State:     model.Unstarted,
		UpdatedAt: time.Now(),
	}

	t.Run("削除OK", func(t *testing.T) {
		mockCtrl := gomock.NewController(t)
		defer mockCtrl.Finish()

		mockStore := store.NewMockStore(mockCtrl)
		mockStoreInTran := store.NewMockStore(mockCtrl)

		mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
			return f(mockStoreInTran)
		})

		mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
			*dst = source
		})

		var e event.Event
		mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Do(func(evnt event.Event) {
			e = evnt
		})

		mockStoreInTran.EXPECT().DeleteWork(gomock.Eq(source.ID))

		cmd := command.New(command.Dependency{Store: mockStore})
		err := cmd.DeleteWork(source.ID)

		t.Run("errorがnil であること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants nil", err)
			}
		})

		t.Run("Event", func(t *testing.T) {
			t.Run("IDにUUIDを設定すること", func(t *testing.T) {
				if e.ID == "" {
					t.Error("event.ID is empty, wants not empty")
				}
				if !testutil.IsUUID(e.ID) {
					t.Error("event.ID is not UUID, wants UUID")
				}
			})
			t.Run("PrevIDに削除前のWork.EventIDを設定すること", func(t *testing.T) {
				if e.PrevID != source.EventID {
					t.Errorf("event.PrevID = %s, wants = work.EventID(%s)", e.PrevID, source.EventID)
				}
			})
			t.Run("WorkIDに削除したWorkのIDを設定すること", func(t *testing.T) {
				if e.WorkID != source.ID {
					t.Errorf("event.WorkID = %s, wants = %s (work.ID)", e.ID, source.ID)
				}
			})
			t.Run("ActionにDeleteWorkを設定すること", func(t *testing.T) {
				if e.Action != event.DeleteWork {
					t.Errorf("event.Action = %s, wants = %s", e.Action, event.DeleteWork)
				}
			})
			t.Run("CreatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(e.CreatedAt) {
					t.Errorf("event.CreatedAt = %s, wants now", e.CreatedAt)
				}
			})
		})
	})

	t.Run("削除エラー", func(t *testing.T) {
		someErr := errors.New("Some Error")

		t.Run("Store#GetWorkがErrNotfoundの場合はErrNotfoundを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Return(store.ErrNotfound)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.DeleteWork(util.NewUUID())

			if err != command.ErrNotfound {
				t.Errorf("error = %#v, wants = %#v", err, command.ErrNotfound)
			}
		})

		t.Run("Store#PutEventがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})
			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any())

			mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Return(someErr)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.DeleteWork(util.NewUUID())

			if err == nil {
				t.Fatal("error is nil, wants not nil")
			}

			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})

		t.Run("Store#DeleteWorkがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})
			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any())
			mockStoreInTran.EXPECT().PutEvent(gomock.Any())

			mockStoreInTran.EXPECT().DeleteWork(gomock.Any()).Return(someErr)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.DeleteWork(util.NewUUID())

			if err == nil {
				t.Fatal("error is nil, wants not nil")
			}

			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})
	})
}

func TestStartWork(t *testing.T) {
	source := model.Work{
		ID:        util.NewUUID(),
		EventID:   util.NewUUID(),
		Title:     "Some Title",
		Time:      time.Now().Add(-1 * time.Hour),
		State:     model.Unstarted,
		UpdatedAt: time.Now(),
	}
	testChangeWorkState(t, "開始", command.Command.StartWork, source, event.StartWork, model.Started)

	for _, state := range []model.WorkState{
		model.UnknownState,
		model.Started,
		model.Paused,
		model.Resumed,
		model.Finished,
	} {
		t.Run(fmt.Sprintf("更新前のWork.Stateが%sの場合はValidationErrorになること", state), func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
				w := source
				w.State = state
				*dst = w
			})

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.StartWork(source.ID, command.ChangeWorkStateParam{Time: time.Now()})
			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

func TestPauseWork(t *testing.T) {
	source := model.Work{
		ID:        util.NewUUID(),
		EventID:   util.NewUUID(),
		Title:     "Some Title",
		Time:      time.Now().Add(-1 * time.Hour),
		State:     model.Started,
		UpdatedAt: time.Now(),
	}
	testChangeWorkState(t, "停止", command.Command.PauseWork, source, event.PauseWork, model.Paused)

	for _, state := range []model.WorkState{
		model.UnknownState,
		model.Unstarted,
		model.Paused,
		model.Finished,
	} {
		t.Run(fmt.Sprintf("更新前のWork.Stateが%sの場合はValidationErrorになること", state), func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
				w := source
				w.State = state
				*dst = w
			})

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.PauseWork(source.ID, command.ChangeWorkStateParam{Time: time.Now()})
			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

func TestResumeWork(t *testing.T) {
	source := model.Work{
		ID:        util.NewUUID(),
		EventID:   util.NewUUID(),
		Title:     "Some Title",
		Time:      time.Now().Add(-1 * time.Hour),
		State:     model.Paused,
		UpdatedAt: time.Now(),
	}
	testChangeWorkState(t, "再開", command.Command.ResumeWork, source, event.ResumeWork, model.Resumed)

	for _, state := range []model.WorkState{
		model.UnknownState,
		model.Unstarted,
		model.Started,
		model.Resumed,
		model.Finished,
	} {
		t.Run(fmt.Sprintf("更新前のWork.Stateが%sの場合はValidationErrorになること", state), func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
				w := source
				w.State = state
				*dst = w
			})

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.ResumeWork(source.ID, command.ChangeWorkStateParam{Time: time.Now()})
			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

func TestFinishWork(t *testing.T) {
	source := model.Work{
		ID:        util.NewUUID(),
		EventID:   util.NewUUID(),
		Title:     "Some Title",
		Time:      time.Now().Add(-1 * time.Hour),
		State:     model.Resumed,
		UpdatedAt: time.Now(),
	}
	testChangeWorkState(t, "完了", command.Command.FinishWork, source, event.FinishWork, model.Finished)

	for _, state := range []model.WorkState{
		model.UnknownState,
		model.Unstarted,
		model.Finished,
	} {
		t.Run(fmt.Sprintf("更新前のWork.Stateが%sの場合はValidationErrorになること", state), func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
				w := source
				w.State = state
				*dst = w
			})

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.FinishWork(source.ID, command.ChangeWorkStateParam{Time: time.Now()})
			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}

}

func TestCancelFinishWork(t *testing.T) {
	source := model.Work{
		ID:        util.NewUUID(),
		EventID:   util.NewUUID(),
		Title:     "Some Title",
		Time:      time.Now().Add(-1 * time.Hour),
		State:     model.Finished,
		UpdatedAt: time.Now(),
	}
	testChangeWorkState(t, "完了取り消し", command.Command.CancelFinishWork, source, event.CancelFinishWork, model.Paused)

	for _, state := range []model.WorkState{
		model.UnknownState,
		model.Unstarted,
		model.Started,
		model.Paused,
		model.Resumed,
	} {
		t.Run(fmt.Sprintf("更新前のWork.Stateが%sの場合はValidationErrorになること", state), func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
				w := source
				w.State = state
				*dst = w
			})

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.CancelFinishWork(source.ID, command.ChangeWorkStateParam{Time: time.Now()})
			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

type changeWorkStateFunc func(command.Command, string, command.ChangeWorkStateParam) error

func testChangeWorkState(t *testing.T, testTitle string, testFunc changeWorkStateFunc, source model.Work, eventAction event.Action, state model.WorkState) {
	now := time.Now()

	t.Run(fmt.Sprintf("%sOK", testTitle), func(t *testing.T) {
		mockCtrl := gomock.NewController(t)
		defer mockCtrl.Finish()

		mockStore := store.NewMockStore(mockCtrl)
		mockStoreInTran := store.NewMockStore(mockCtrl)

		mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
			return f(mockStoreInTran)
		})

		mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
			*dst = source
		})

		var e event.Event
		mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Do(func(evnt event.Event) {
			e = evnt
		})

		var w model.Work
		mockStoreInTran.EXPECT().PutWork(gomock.Any()).Do(func(work model.Work) {
			w = work
		})

		cmd := command.New(command.Dependency{Store: mockStore})
		err := testFunc(cmd, source.ID, command.ChangeWorkStateParam{Time: now})

		t.Run("errorがnil であること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants nil", err)
			}
		})

		t.Run("Event", func(t *testing.T) {
			t.Run("IDにUUIDを設定すること", func(t *testing.T) {
				if e.ID == "" {
					t.Error("event.ID is empty, wants not empty")
				}
				if !testutil.IsUUID(e.ID) {
					t.Error("event.ID is not UUID, wants UUID")
				}
			})
			t.Run("PrevIDに更新前のwork.EventIDを設定すること", func(t *testing.T) {
				if e.PrevID != source.EventID {
					t.Errorf("event.PrevID = %s, wants = work.EventID(%s)", e.PrevID, source.EventID)
				}
			})
			t.Run("WorkIDに更新したWorkのIDを設定すること", func(t *testing.T) {
				if e.WorkID != w.ID {
					t.Errorf("event.WorkID = %s, wants = %s (work.ID)", e.ID, w.ID)
				}
			})
			t.Run(fmt.Sprintf("Actionに%sを設定すること", eventAction), func(t *testing.T) {
				if e.Action != eventAction {
					t.Errorf("event.Action = %s, wants = %s", e.Action, eventAction)
				}
			})
			t.Run("CreatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(e.CreatedAt) {
					t.Errorf("event.CreatedAt = %s, wants now", e.CreatedAt)
				}
			})

			t.Run("Timeに引数で指定したTimeを設定すること", func(t *testing.T) {
				if !e.Time.Equal(now) {
					t.Errorf("event.Time = %s, wants = %s", e.Time, now)
				}
			})
		})

		t.Run("Work", func(t *testing.T) {
			t.Run("IDに更新前のWork.IDを設定すること", func(t *testing.T) {
				if w.ID != source.ID {
					t.Errorf("work.ID = %s, wants = %s", w.ID, source.ID)
				}
			})
			t.Run("EventIDに作成したPutEventで登録したeventのIDを設定すること", func(t *testing.T) {
				if w.EventID == source.EventID {
					t.Error("work.EventID = source.EventID, wants not equals")
				}
				if w.EventID != e.ID {
					t.Errorf("work.EventID = %s, wants = %s (event.ID)", w.EventID, e.ID)
				}
			})
			t.Run("Titleに更新前のWork.Titleを設定すること", func(t *testing.T) {
				if w.Title != source.Title {
					t.Errorf("work.Title = %s, wants = %s", w.Title, source.Title)
				}
			})
			t.Run("Timeに引数で指定したTimeを設定すること", func(t *testing.T) {
				if !w.Time.Equal(now) {
					t.Errorf("work.Time = %s, wants = %s", w.Time, now)
				}
			})
			t.Run(fmt.Sprintf("Stateに%sを設定すること", state), func(t *testing.T) {
				if w.State != state {
					t.Errorf("work.State = %s, wants = %s", w.State, state)
				}
			})
			t.Run("UpdatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(w.UpdatedAt) {
					t.Errorf("work.UpdatedAt = %s, wants now", w.UpdatedAt)
				}
			})
		})

		t.Run("event.CreatedAtとwork.UpdatedAtが同じであること", func(t *testing.T) {
			if e.CreatedAt != w.UpdatedAt {
				t.Errorf("event.CreatedAt(%v) != work.UpdatedAt(%v), wants equals", e.CreatedAt, w.UpdatedAt)
			}
		})
	})

	t.Run(fmt.Sprintf("%sエラー", testTitle), func(t *testing.T) {
		someErr := errors.New("Some Error")

		t.Run("Store#GetWorkがErrNotfoundの場合はErrNotfoundを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)

			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Return(store.ErrNotfound)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := testFunc(cmd, source.ID, command.ChangeWorkStateParam{Time: now})

			if err != command.ErrNotfound {
				t.Errorf("error = %#v, wants = %#v", err, command.ErrNotfound)
			}
		})

		t.Run("Store#PutEventがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)

			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
				*dst = source
			})

			mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Return(someErr)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := testFunc(cmd, source.ID, command.ChangeWorkStateParam{Time: now})

			if err == nil {
				t.Fatal("error is nil, wants not nil")
			}

			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})

		t.Run("Store#PutWorkがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)

			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
				*dst = source
			})
			mockStoreInTran.EXPECT().PutEvent(gomock.Any())
			mockStoreInTran.EXPECT().PutWork(gomock.Any()).Return(someErr)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := testFunc(cmd, source.ID, command.ChangeWorkStateParam{Time: now})

			if err == nil {
				t.Fatal("error is nil, wants not nil")
			}

			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})

		t.Run("更新前のWork.Timeがparam.Timeより大きい場合はValidationErrorになること", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)
			mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
				*dst = source
			})

			cmd := command.New(command.Dependency{Store: mockStore})
			err := testFunc(cmd, source.ID, command.ChangeWorkStateParam{Time: source.Time.Add(-1 * time.Second)})
			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	})
}
