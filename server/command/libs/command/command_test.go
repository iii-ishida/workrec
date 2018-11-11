package command_test

import (
	"errors"
	"fmt"
	"testing"
	"time"

	"github.com/golang/mock/gomock"
	"github.com/iii-ishida/workrec/server/command/libs/command"
	"github.com/iii-ishida/workrec/server/command/libs/model"
	"github.com/iii-ishida/workrec/server/command/libs/store"
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

		mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
			return f(mockStoreInTran)
		})

		var event model.Event
		mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Do(func(e model.Event) {
			event = e
		})

		var work model.Work
		mockStoreInTran.EXPECT().PutWork(gomock.Any()).Do(func(w model.Work) {
			work = w
		})

		paramTitle := "Some Title"
		cmd := command.New(command.Dependency{Store: mockStore})
		id, err := cmd.CreateWork(command.CreateWorkParam{Title: paramTitle})

		t.Run("登録したWorkのIDが返却されること", func(t *testing.T) {
			if id == "" {
				t.Fatal("id is empty, wants not empty")
			}
			if id != work.ID {
				t.Errorf("id = %s, wants = %s (work.ID)", id, work.ID)
			}
		})

		t.Run("errorがnil であること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants nil", err)
			}
		})

		t.Run("PutEvent", func(t *testing.T) {
			t.Run("IDにUUIDを設定すること", func(t *testing.T) {
				if event.ID == "" {
					t.Error("event.ID is empty, wants not empty")
				}
				if !testutil.IsUUID(string(event.ID)) {
					t.Error("event.ID is not UUID, wants UUID")
				}
			})
			t.Run("PrevIDに空文字を設定すること", func(t *testing.T) {
				if event.PrevID != "" {
					t.Error("event.PrevID is not empty, wants empty")
				}
			})
			t.Run("WorkIDに作成したWorkのIDを設定すること", func(t *testing.T) {
				if event.WorkID != work.ID {
					t.Errorf("event.WorkID = %s, wants = %s (work.ID)", event.ID, work.ID)
				}
			})
			t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
				if event.Title != paramTitle {
					t.Errorf("event.Title = %s, wants = %s", event.Title, paramTitle)
				}
			})
			t.Run("TypeにCreateWorkを設定すること", func(t *testing.T) {
				if event.Type != model.CreateWork {
					t.Errorf("event.Type = %s, wants = %s", event.Type, model.CreateWork)
				}
			})
			t.Run("CreatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(event.CreatedAt) {
					t.Errorf("event.CreatedAt = %s, wants now", event.CreatedAt)
				}
			})
		})

		t.Run("PutWork", func(t *testing.T) {
			t.Run("IDにUUIDを設定すること", func(t *testing.T) {
				if work.ID == "" {
					t.Error("work.ID is empty, wants not empty")
				}
				if !testutil.IsUUID(string(work.ID)) {
					t.Error("work.ID is not UUID, wants UUID")
				}
			})
			t.Run("EventIDに作成したPutEventで登録したeventのIDを設定すること", func(t *testing.T) {
				if work.EventID != event.ID {
					t.Errorf("work.EventID = %s, wants = %s (event.ID)", work.EventID, event.ID)
				}
			})
			t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
				if work.Title != paramTitle {
					t.Errorf("work.Title = %s, wants = %s", work.Title, paramTitle)
				}
			})
			t.Run("StateにUnstartedを設定すること", func(t *testing.T) {
				if work.State != model.Unstarted {
					t.Errorf("work.State = %s, wants = %s", work.State, model.Unstarted)
				}
			})
			t.Run("UpdatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(work.UpdatedAt) {
					t.Errorf("work.UpdatedAt = %s, wants now", work.UpdatedAt)
				}
			})
		})

		t.Run("Event.CreatedAtとWork.UpdatedAtが同じであること", func(t *testing.T) {
			if event.CreatedAt != work.UpdatedAt {
				t.Errorf("event.CreatedAt(%v) != work.UpdatedAt(%v), wants equals", event.CreatedAt, work.UpdatedAt)
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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
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
	source := model.Work{
		ID:        model.WorkID(util.NewUUID()),
		EventID:   model.EventID(util.NewUUID()),
		Title:     "Some Title",
		State:     model.Started,
		UpdatedAt: time.Now(),
	}

	t.Run("更新OK", func(t *testing.T) {
		mockCtrl := gomock.NewController(t)
		defer mockCtrl.Finish()

		mockStore := store.NewMockStore(mockCtrl)
		mockStoreInTran := store.NewMockStore(mockCtrl)

		mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
			return f(mockStoreInTran)
		})

		mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ model.WorkID, dst *model.Work) {
			*dst = source
		})

		var event model.Event
		mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Do(func(e model.Event) {
			event = e
		})

		var work model.Work
		mockStoreInTran.EXPECT().PutWork(gomock.Any()).Do(func(w model.Work) {
			work = w
		})

		paramTitle := "Updated Title"
		cmd := command.New(command.Dependency{Store: mockStore})
		err := cmd.UpdateWork(string(source.ID), command.UpdateWorkParam{Title: paramTitle})

		t.Run("errorがnil であること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants nil", err)
			}
		})

		t.Run("PutEvent", func(t *testing.T) {
			t.Run("IDにUUIDを設定すること", func(t *testing.T) {
				if event.ID == "" {
					t.Error("event.ID is empty, wants not empty")
				}
				if !testutil.IsUUID(string(event.ID)) {
					t.Error("event.ID is not UUID, wants UUID")
				}
			})
			t.Run("PrevIDに更新前のWork.EventIDを設定すること", func(t *testing.T) {
				if event.PrevID != source.EventID {
					t.Errorf("event.PrevID = %s, wants = work.EventID(%s)", event.PrevID, source.EventID)
				}
			})
			t.Run("WorkIDに更新したWorkのIDを設定すること", func(t *testing.T) {
				if event.WorkID != work.ID {
					t.Errorf("event.WorkID = %s, wants = %s (work.ID)", event.ID, work.ID)
				}
			})
			t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
				if event.Title != paramTitle {
					t.Errorf("event.Title = %s, wants = %s", event.Title, paramTitle)
				}
			})
			t.Run("TypeにUpdateWorkを設定すること", func(t *testing.T) {
				if event.Type != model.UpdateWork {
					t.Errorf("event.Type = %s, wants = %s", event.Type, model.UpdateWork)
				}
			})
			t.Run("CreatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(event.CreatedAt) {
					t.Errorf("event.CreatedAt = %s, wants now", event.CreatedAt)
				}
			})
		})

		t.Run("PutWork", func(t *testing.T) {
			t.Run("IDに更新前のWork.IDを設定すること", func(t *testing.T) {
				if work.ID != source.ID {
					t.Errorf("work.ID = %s, wants = %s", work.ID, source.ID)
				}
			})
			t.Run("EventIDに作成したPutEventで登録したEventのIDを設定すること", func(t *testing.T) {
				if work.EventID == source.EventID {
					t.Error("work.EventID = source.EventID, wants not equals")
				}
				if work.EventID != event.ID {
					t.Errorf("work.EventID = %s, wants = %s (event.ID)", work.EventID, event.ID)
				}
			})
			t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
				if work.Title != paramTitle {
					t.Errorf("work.Title = %s, wants = %s", work.Title, paramTitle)
				}
			})
			t.Run("Stateに更新前のWork.Stateを設定すること", func(t *testing.T) {
				if work.State != source.State {
					t.Errorf("work.State = %s, wants = %s", work.State, source.State)
				}
			})
			t.Run("UpdatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(work.UpdatedAt) {
					t.Errorf("work.UpdatedAt = %s, wants now", work.UpdatedAt)
				}
			})
		})

		t.Run("Event.CreatedAtとWork.UpdatedAtが同じであること", func(t *testing.T) {
			if event.CreatedAt != work.UpdatedAt {
				t.Errorf("event.CreatedAt(%v) != work.UpdatedAt(%v), wants equals", event.CreatedAt, work.UpdatedAt)
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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
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
		ID:        model.WorkID(util.NewUUID()),
		EventID:   model.EventID(util.NewUUID()),
		Title:     "Some Title",
		State:     model.Unstarted,
		UpdatedAt: time.Now(),
	}

	t.Run("削除OK", func(t *testing.T) {
		mockCtrl := gomock.NewController(t)
		defer mockCtrl.Finish()

		mockStore := store.NewMockStore(mockCtrl)
		mockStoreInTran := store.NewMockStore(mockCtrl)

		mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
			return f(mockStoreInTran)
		})

		mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ model.WorkID, dst *model.Work) {
			*dst = source
		})

		var event model.Event
		mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Do(func(e model.Event) {
			event = e
		})

		mockStoreInTran.EXPECT().DeleteWork(gomock.Eq(source.ID))

		cmd := command.New(command.Dependency{Store: mockStore})
		err := cmd.DeleteWork(string(source.ID))

		t.Run("errorがnil であること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants nil", err)
			}
		})

		t.Run("PutEvent", func(t *testing.T) {
			t.Run("IDにUUIDを設定すること", func(t *testing.T) {
				if event.ID == "" {
					t.Error("event.ID is empty, wants not empty")
				}
				if !testutil.IsUUID(string(event.ID)) {
					t.Error("event.ID is not UUID, wants UUID")
				}
			})
			t.Run("PrevIDに削除前のWork.EventIDを設定すること", func(t *testing.T) {
				if event.PrevID != source.EventID {
					t.Errorf("event.PrevID = %s, wants = work.EventID(%s)", event.PrevID, source.EventID)
				}
			})
			t.Run("WorkIDに削除したWorkのIDを設定すること", func(t *testing.T) {
				if event.WorkID != source.ID {
					t.Errorf("event.WorkID = %s, wants = %s (work.ID)", event.ID, source.ID)
				}
			})
			t.Run("TypeにDeleteWorkを設定すること", func(t *testing.T) {
				if event.Type != model.DeleteWork {
					t.Errorf("event.Type = %s, wants = %s", event.Type, model.DeleteWork)
				}
			})
			t.Run("CreatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(event.CreatedAt) {
					t.Errorf("event.CreatedAt = %s, wants now", event.CreatedAt)
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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
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
		ID:        model.WorkID(util.NewUUID()),
		EventID:   model.EventID(util.NewUUID()),
		Title:     "Some Title",
		State:     model.Unstarted,
		UpdatedAt: time.Now(),
	}
	testChangeWorkState(t, "開始", command.Command.StartWork, source, model.StartWork, model.Started)

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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ model.WorkID, dst *model.Work) {
				w := source
				w.State = state
				*dst = w
			})

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.StartWork(string(source.ID), command.ChangeWorkStateParam{Time: time.Now()})
			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

func TestPauseWork(t *testing.T) {
	source := model.Work{
		ID:        model.WorkID(util.NewUUID()),
		EventID:   model.EventID(util.NewUUID()),
		Title:     "Some Title",
		State:     model.Started,
		UpdatedAt: time.Now(),
	}
	testChangeWorkState(t, "停止", command.Command.PauseWork, source, model.PauseWork, model.Paused)

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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ model.WorkID, dst *model.Work) {
				w := source
				w.State = state
				*dst = w
			})

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.PauseWork(string(source.ID), command.ChangeWorkStateParam{Time: time.Now()})
			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

func TestResumeWork(t *testing.T) {
	source := model.Work{
		ID:        model.WorkID(util.NewUUID()),
		EventID:   model.EventID(util.NewUUID()),
		Title:     "Some Title",
		State:     model.Paused,
		UpdatedAt: time.Now(),
	}
	testChangeWorkState(t, "再開", command.Command.ResumeWork, source, model.ResumeWork, model.Resumed)

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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ model.WorkID, dst *model.Work) {
				w := source
				w.State = state
				*dst = w
			})

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.ResumeWork(string(source.ID), command.ChangeWorkStateParam{Time: time.Now()})
			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

func TestFinishWork(t *testing.T) {
	source := model.Work{
		ID:        model.WorkID(util.NewUUID()),
		EventID:   model.EventID(util.NewUUID()),
		Title:     "Some Title",
		State:     model.Resumed,
		UpdatedAt: time.Now(),
	}
	testChangeWorkState(t, "完了", command.Command.FinishWork, source, model.FinishWork, model.Finished)

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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ model.WorkID, dst *model.Work) {
				w := source
				w.State = state
				*dst = w
			})

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.FinishWork(string(source.ID), command.ChangeWorkStateParam{Time: time.Now()})
			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}

}

func TestCancelFinishWork(t *testing.T) {
	source := model.Work{
		ID:        model.WorkID(util.NewUUID()),
		EventID:   model.EventID(util.NewUUID()),
		Title:     "Some Title",
		State:     model.Finished,
		UpdatedAt: time.Now(),
	}
	testChangeWorkState(t, "完了取り消し", command.Command.CancelFinishWork, source, model.CancelFinishWork, model.Paused)

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
			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ model.WorkID, dst *model.Work) {
				w := source
				w.State = state
				*dst = w
			})

			cmd := command.New(command.Dependency{Store: mockStore})
			err := cmd.CancelFinishWork(string(source.ID), command.ChangeWorkStateParam{Time: time.Now()})
			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

type changeWorkStateFunc func(command.Command, string, command.ChangeWorkStateParam) error

func testChangeWorkState(t *testing.T, testTitle string, testFunc changeWorkStateFunc, source model.Work, eventType model.EventType, state model.WorkState) {
	now := time.Now()

	t.Run(fmt.Sprintf("%sOK", testTitle), func(t *testing.T) {
		mockCtrl := gomock.NewController(t)
		defer mockCtrl.Finish()

		mockStore := store.NewMockStore(mockCtrl)
		mockStoreInTran := store.NewMockStore(mockCtrl)

		mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
			return f(mockStoreInTran)
		})

		mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ model.WorkID, dst *model.Work) {
			*dst = source
		})

		var event model.Event
		mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Do(func(e model.Event) {
			event = e
		})

		var work model.Work
		mockStoreInTran.EXPECT().PutWork(gomock.Any()).Do(func(w model.Work) {
			work = w
		})

		cmd := command.New(command.Dependency{Store: mockStore})
		err := testFunc(cmd, string(source.ID), command.ChangeWorkStateParam{Time: now})

		t.Run("errorがnil であること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants nil", err)
			}
		})

		t.Run("PutEvent", func(t *testing.T) {
			t.Run("IDにUUIDを設定すること", func(t *testing.T) {
				if event.ID == "" {
					t.Error("event.ID is empty, wants not empty")
				}
				if !testutil.IsUUID(string(event.ID)) {
					t.Error("event.ID is not UUID, wants UUID")
				}
			})
			t.Run("PrevIDに更新前のwork.EventIDを設定すること", func(t *testing.T) {
				if event.PrevID != source.EventID {
					t.Errorf("event.PrevID = %s, wants = work.EventID(%s)", event.PrevID, source.EventID)
				}
			})
			t.Run("WorkIDに更新したWorkのIDを設定すること", func(t *testing.T) {
				if event.WorkID != work.ID {
					t.Errorf("event.WorkID = %s, wants = %s (work.ID)", event.ID, work.ID)
				}
			})
			t.Run(fmt.Sprintf("Typeに%sを設定すること", eventType), func(t *testing.T) {
				if event.Type != eventType {
					t.Errorf("event.Type = %s, wants = %s", event.Type, eventType)
				}
			})
			t.Run("CreatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(event.CreatedAt) {
					t.Errorf("event.CreatedAt = %s, wants now", event.CreatedAt)
				}
			})

			t.Run("Timeに引数で指定したTimeを設定すること", func(t *testing.T) {
				if event.Time != now {
					t.Errorf("event.Time = %s, wants = %s", event.Time, now)
				}
			})
		})

		t.Run("PutWork", func(t *testing.T) {
			t.Run("IDに更新前のWork.IDを設定すること", func(t *testing.T) {
				if work.ID != source.ID {
					t.Errorf("work.ID = %s, wants = %s", work.ID, source.ID)
				}
			})
			t.Run("EventIDに作成したPutEventで登録したeventのIDを設定すること", func(t *testing.T) {
				if work.EventID == source.EventID {
					t.Error("work.EventID = source.EventID, wants not equals")
				}
				if work.EventID != event.ID {
					t.Errorf("work.EventID = %s, wants = %s (event.ID)", work.EventID, event.ID)
				}
			})
			t.Run("Titleに更新前のWork.Titleを設定すること", func(t *testing.T) {
				if work.Title != source.Title {
					t.Errorf("work.Title = %s, wants = %s", work.Title, source.Title)
				}
			})
			t.Run(fmt.Sprintf("Stateに%sを設定すること", state), func(t *testing.T) {
				if work.State != state {
					t.Errorf("work.State = %s, wants = %s", work.State, state)
				}
			})
			t.Run("UpdatedAtにシステム日時を設定すること", func(t *testing.T) {
				if !testutil.IsSystemTime(work.UpdatedAt) {
					t.Errorf("work.UpdatedAt = %s, wants now", work.UpdatedAt)
				}
			})
		})

		t.Run("event.CreatedAtとwork.UpdatedAtが同じであること", func(t *testing.T) {
			if event.CreatedAt != work.UpdatedAt {
				t.Errorf("event.CreatedAt(%v) != work.UpdatedAt(%v), wants equals", event.CreatedAt, work.UpdatedAt)
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

			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Return(store.ErrNotfound)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := testFunc(cmd, string(source.ID), command.ChangeWorkStateParam{Time: now})

			if err != command.ErrNotfound {
				t.Errorf("error = %#v, wants = %#v", err, command.ErrNotfound)
			}
		})

		t.Run("Store#PutEventがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			mockCtrl := gomock.NewController(t)
			defer mockCtrl.Finish()

			mockStore := store.NewMockStore(mockCtrl)
			mockStoreInTran := store.NewMockStore(mockCtrl)

			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ model.WorkID, dst *model.Work) {
				*dst = source
			})

			mockStoreInTran.EXPECT().PutEvent(gomock.Any()).Return(someErr)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := testFunc(cmd, string(source.ID), command.ChangeWorkStateParam{Time: now})

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

			mockStore.EXPECT().RunTransaction(gomock.Any()).DoAndReturn(func(f tranFunc) error {
				return f(mockStoreInTran)
			})

			mockStoreInTran.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ model.WorkID, dst *model.Work) {
				*dst = source
			})
			mockStoreInTran.EXPECT().PutEvent(gomock.Any())
			mockStoreInTran.EXPECT().PutWork(gomock.Any()).Return(someErr)

			cmd := command.New(command.Dependency{Store: mockStore})
			err := testFunc(cmd, string(source.ID), command.ChangeWorkStateParam{Time: now})

			if err == nil {
				t.Fatal("error is nil, wants not nil")
			}

			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})
	})
}
