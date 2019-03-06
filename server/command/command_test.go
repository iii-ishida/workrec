package command_test

import (
	"errors"
	"fmt"
	"testing"
	"time"

	"github.com/golang/mock/gomock"
	"github.com/google/go-cmp/cmp"
	"github.com/iii-ishida/workrec/server/command"
	"github.com/iii-ishida/workrec/server/command/model"
	"github.com/iii-ishida/workrec/server/command/store"
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/publisher"
	"github.com/iii-ishida/workrec/server/testutil"
	"github.com/iii-ishida/workrec/server/util"
)

func TestCreateWork_Expectation(t *testing.T) {
	cmd, mockStore, mockPublisher, mockCtrl := newCommandWithGoMock(t)
	defer mockCtrl.Finish()

	gomock.InOrder(
		mockStore.EXPECT().PutEvent(gomock.Any()),
		mockStore.EXPECT().PutWork(gomock.Any()),
		mockPublisher.EXPECT().Publish(gomock.Any()),
	)

	cmd.CreateWork("some-userid", command.CreateWorkParam{Title: "Some Title"})
}

func TestCreateWork_OK_ReturnValue(t *testing.T) {
	cmd, s, _ := newCommandWithInmemory()

	id, err := cmd.CreateWork("some-userid", command.CreateWorkParam{Title: "Some Title"})

	t.Run("登録したWorkのIDが返却されること", func(t *testing.T) {
		if id == "" {
			t.Fatal("id is empty, wants not empty")
		}
		if id != s.Work.ID {
			t.Errorf("id = %s, wants = %s (work.ID)", id, s.Work.ID)
		}
	})

	t.Run("errorがnilであること", func(t *testing.T) {
		if err != nil {
			t.Errorf("error = %#v, wants nil", err)
		}
	})
}

func TestCreateWork_OK_SaveValue(t *testing.T) {
	cmd, s, _ := newCommandWithInmemory()

	var (
		userID = "some-userid"
		title  = "Some Title"
	)

	cmd.CreateWork(userID, command.CreateWorkParam{Title: title})

	var (
		e = s.Event
		w = s.Work
	)

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
		t.Run("UserIDに引数で指定したuserIDを設定すること", func(t *testing.T) {
			if e.UserID != userID {
				t.Errorf("event.UserID = %s, wants = %s", e.UserID, userID)
			}
		})
		t.Run("WorkIDに作成したWorkのIDを設定すること", func(t *testing.T) {
			if e.WorkID != w.ID {
				t.Errorf("event.WorkID = %s, wants = %s (work.ID)", e.ID, w.ID)
			}
		})
		t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
			if e.Title != title {
				t.Errorf("event.Title = %s, wants = %s", e.Title, title)
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
		t.Run("UserIDに引数で指定したuserIDを設定すること", func(t *testing.T) {
			if w.UserID != userID {
				t.Errorf("work.UserID = %s, wants = %s", w.UserID, userID)
			}
		})
		t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
			if w.Title != title {
				t.Errorf("work.Title = %s, wants = %s", w.Title, title)
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
}

func TestCreateWork_OK_PublishValue(t *testing.T) {
	cmd, s, p := newCommandWithInmemory()

	cmd.CreateWork("some-userid", command.CreateWorkParam{Title: "Some Title"})

	t.Run("保存したEventをPublishすること", func(t *testing.T) {
		b, _ := event.MarshalPb(s.Event)
		if !cmp.Equal(p.Msg, b) {
			t.Error("publish msg != saved Event, wants equals")
		}
	})
}

func TestCreateWork_InvalidUserID(t *testing.T) {
	cmd, _, _ := newCommandWithInmemory()

	_, err := cmd.CreateWork("", command.CreateWorkParam{Title: "Some Title"})

	t.Run("userIDが空文字の場合はErrForbiddenを返すこと", func(t *testing.T) {
		if err != command.ErrForbidden {
			t.Errorf("error = %#v, wants = %#v", err, command.ErrForbidden)
		}
	})
}

func TestCreateWork_StoreError(t *testing.T) {
	someErr := errors.New("Some Error")

	t.Run("Store#PutEventがエラーになった場合はerrorを返すこと", func(t *testing.T) {
		cmd, s, _ := newCommandWithInmemory()
		s.PutEventError = someErr

		_, err := cmd.CreateWork("some-userid", command.CreateWorkParam{Title: "Some Title"})

		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})

	t.Run("Store#PutWorkがエラーになった場合はerrorを返すこと", func(t *testing.T) {
		cmd, s, _ := newCommandWithInmemory()
		s.PutWorkError = someErr

		_, err := cmd.CreateWork("some-userid", command.CreateWorkParam{Title: "Some Title"})

		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})
}

func TestUpdateWork_Expectation(t *testing.T) {
	cmd, mockStore, mockPublisher, mockCtrl := newCommandWithGoMock(t)
	defer mockCtrl.Finish()

	source := newWork()

	gomock.InOrder(
		mockStore.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
			*dst = source
		}),
		mockStore.EXPECT().PutEvent(gomock.Any()),
		mockStore.EXPECT().PutWork(gomock.Any()),
		mockPublisher.EXPECT().Publish(gomock.Any()),
	)

	cmd.UpdateWork(source.UserID, source.ID, command.UpdateWorkParam{Title: "Updated Title"})
}

func TestUpdateWork_OK_ReturnValue(t *testing.T) {
	cmd, s, _ := newCommandWithInmemory()
	source := newWork()
	s.Work = source

	err := cmd.UpdateWork(source.UserID, source.ID, command.UpdateWorkParam{Title: "Updated Title"})

	t.Run("errorがnil であること", func(t *testing.T) {
		if err != nil {
			t.Errorf("error = %#v, wants nil", err)
		}
	})
}

func TestUpdateWork_OK_SaveValue(t *testing.T) {
	cmd, s, _ := newCommandWithInmemory()
	source := newWork()
	s.Work = source

	title := "Updated Title"
	cmd.UpdateWork(source.UserID, source.ID, command.UpdateWorkParam{Title: title})

	var (
		e = s.Event
		w = s.Work
	)

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
		t.Run("UserIDに引数で指定したuserIDを設定すること", func(t *testing.T) {
			if e.UserID != source.UserID {
				t.Errorf("event.UserID = %s, wants = %s", e.UserID, source.UserID)
			}
		})
		t.Run("WorkIDに更新したWorkのIDを設定すること", func(t *testing.T) {
			if e.WorkID != w.ID {
				t.Errorf("event.WorkID = %s, wants = %s (work.ID)", e.ID, w.ID)
			}
		})
		t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
			if e.Title != title {
				t.Errorf("event.Title = %s, wants = %s", e.Title, title)
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
		t.Run("UserIDに更新前のWork.UserIDを設定すること", func(t *testing.T) {
			if w.UserID != source.UserID {
				t.Errorf("work.UserID = %s, wants = %s", w.UserID, source.UserID)
			}
		})
		t.Run("Titleに引数で指定したTitleを設定すること", func(t *testing.T) {
			if w.Title != title {
				t.Errorf("work.Title = %s, wants = %s", w.Title, title)
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
}

func TestUpdateWork_OK_PublishValue(t *testing.T) {
	cmd, s, p := newCommandWithInmemory()
	source := newWork()
	s.Work = source

	cmd.UpdateWork(source.UserID, source.ID, command.UpdateWorkParam{Title: "Updated Title"})

	t.Run("保存したEventをPublishすること", func(t *testing.T) {
		b, _ := event.MarshalPb(s.Event)
		if !cmp.Equal(p.Msg, b) {
			t.Error("publish msg != saved Event, wants equals")
		}
	})
}

func TestUpdateWork_InvalidUserID(t *testing.T) {
	cmd, s, _ := newCommandWithInmemory()
	source := newWork()
	s.Work = source

	err := cmd.UpdateWork("another-userid", source.ID, command.UpdateWorkParam{Title: "Updated Title"})

	t.Run("userIDが更新前と異なる場合はErrForbiddenを返すこと", func(t *testing.T) {
		if err != command.ErrForbidden {
			t.Errorf("error = %#v, wants = %#v", err, command.ErrForbidden)
		}
	})
}

func TestUpdateWork_InvalidWorkID(t *testing.T) {
	cmd, s, _ := newCommandWithInmemory()
	s.GetWorkError = store.ErrNotfound

	err := cmd.UpdateWork("some-userid", "some-workid", command.UpdateWorkParam{Title: "Updated Title"})

	t.Run("Store#GetWorkがErrNotfoundの場合はErrNotfoundを返すこと", func(t *testing.T) {
		if err != command.ErrNotfound {
			t.Errorf("error = %#v, wants = %#v", err, command.ErrNotfound)
		}
	})
}

func TestUpdateWork_StoreError(t *testing.T) {
	someErr := errors.New("Some Error")
	source := newWork()

	t.Run("Store#PutEventがエラーになった場合はerrorを返すこと", func(t *testing.T) {
		cmd, s, _ := newCommandWithInmemory()
		s.Work = source
		s.PutEventError = someErr

		err := cmd.UpdateWork(source.UserID, source.ID, command.UpdateWorkParam{Title: "Updated Title"})

		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})

	t.Run("Store#PutWorkがエラーになった場合はerrorを返すこと", func(t *testing.T) {
		cmd, s, _ := newCommandWithInmemory()
		s.Work = source
		s.PutWorkError = someErr

		err := cmd.UpdateWork(source.UserID, source.ID, command.UpdateWorkParam{Title: "Updated Title"})

		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})
}

func TestDeleteWork_Expectation(t *testing.T) {
	cmd, mockStore, mockPublisher, mockCtrl := newCommandWithGoMock(t)
	defer mockCtrl.Finish()

	source := newWork()

	gomock.InOrder(
		mockStore.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
			*dst = source
		}),
		mockStore.EXPECT().PutEvent(gomock.Any()),
		mockStore.EXPECT().DeleteWork(gomock.Eq(source.ID)),
		mockPublisher.EXPECT().Publish(gomock.Any()),
	)

	cmd.DeleteWork(source.UserID, source.ID)
}

func TestDeleteWork_OK_ReturnValue(t *testing.T) {
	cmd, s, _ := newCommandWithInmemory()
	source := newWork()
	s.Work = source

	err := cmd.DeleteWork(source.UserID, source.ID)

	t.Run("errorがnil であること", func(t *testing.T) {
		if err != nil {
			t.Errorf("error = %#v, wants nil", err)
		}
	})
}

func TestDeleteWork_OK_PublishValue(t *testing.T) {
	cmd, s, p := newCommandWithInmemory()
	source := newWork()
	s.Work = source

	cmd.DeleteWork(source.UserID, source.ID)

	t.Run("保存したEventをPublishすること", func(t *testing.T) {
		b, _ := event.MarshalPb(s.Event)
		if !cmp.Equal(p.Msg, b) {
			t.Error("publish msg != saved Event, wants equals")
		}
	})
}

func TestDeleteWork_OK_SaveValue(t *testing.T) {
	cmd, s, _ := newCommandWithInmemory()
	source := newWork()
	s.Work = source

	cmd.DeleteWork(source.UserID, source.ID)

	e := s.Event

	t.Run("EventにUUIDを設定すること", func(t *testing.T) {
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
		t.Run("UserIDに引数で指定したuserIDを設定すること", func(t *testing.T) {
			if e.UserID != source.UserID {
				t.Errorf("event.UserID = %s, wants = %s", e.UserID, source.UserID)
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
}

func TestDeleteWork_InvalidUserID(t *testing.T) {
	cmd, s, _ := newCommandWithInmemory()
	source := newWork()
	s.Work = source

	err := cmd.DeleteWork("anotherUserID", source.ID)

	t.Run("userIDが更新前と異なる場合はErrForbiddenを返すこと", func(t *testing.T) {
		if err != command.ErrForbidden {
			t.Errorf("error = %#v, wants = %#v", err, command.ErrForbidden)
		}
	})
}

func TestDeleteWork_InvalidWorkID(t *testing.T) {
	cmd, s, _ := newCommandWithInmemory()
	s.GetWorkError = store.ErrNotfound

	err := cmd.DeleteWork("some-userid", "some-workid")

	t.Run("Store#GetWorkがErrNotfoundの場合はErrNotfoundを返すこと", func(t *testing.T) {
		if err != command.ErrNotfound {
			t.Errorf("error = %#v, wants = %#v", err, command.ErrNotfound)
		}
	})
}

func TestDeleteWork_StoreError(t *testing.T) {
	someErr := errors.New("Some Error")
	source := newWork()

	t.Run("Store#PutEventがエラーになった場合はerrorを返すこと", func(t *testing.T) {
		cmd, s, _ := newCommandWithInmemory()
		s.Work = source
		s.PutEventError = someErr

		err := cmd.DeleteWork(source.UserID, source.ID)

		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})

	t.Run("Store#DeleteWorkがエラーになった場合はerrorを返すこと", func(t *testing.T) {
		cmd, s, _ := newCommandWithInmemory()
		s.Work = source
		s.DeleteWorkError = someErr

		err := cmd.DeleteWork(source.UserID, source.ID)

		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})
}

func TestStartWork(t *testing.T) {
	source := newWork()
	source.State = model.Unstarted

	t.Run("開始", func(t *testing.T) {
		testChangeWorkState(t, command.Command.StartWork, source, event.StartWork, model.Started)
	})

	for _, state := range []model.WorkState{
		model.UnknownState,
		model.Started,
		model.Paused,
		model.Resumed,
		model.Finished,
	} {
		t.Run(fmt.Sprintf("更新前のWork.Stateが%sの場合はValidationErrorになること", state), func(t *testing.T) {
			cmd, s, _ := newCommandWithInmemory()
			s.Work = source
			s.Work.State = state

			err := cmd.StartWork(source.UserID, source.ID, command.ChangeWorkStateParam{Time: time.Now()})

			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

func TestPauseWork(t *testing.T) {
	source := newWork()
	source.State = model.Started

	t.Run("停止", func(t *testing.T) {
		testChangeWorkState(t, command.Command.PauseWork, source, event.PauseWork, model.Paused)
	})

	for _, state := range []model.WorkState{
		model.UnknownState,
		model.Unstarted,
		model.Paused,
		model.Finished,
	} {
		t.Run(fmt.Sprintf("更新前のWork.Stateが%sの場合はValidationErrorになること", state), func(t *testing.T) {
			cmd, s, _ := newCommandWithInmemory()
			s.Work = source
			s.Work.State = state

			err := cmd.PauseWork(source.UserID, source.ID, command.ChangeWorkStateParam{Time: time.Now()})

			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

func TestResumeWork(t *testing.T) {
	source := newWork()
	source.State = model.Paused

	t.Run("再開", func(t *testing.T) {
		testChangeWorkState(t, command.Command.ResumeWork, source, event.ResumeWork, model.Resumed)
	})

	for _, state := range []model.WorkState{
		model.UnknownState,
		model.Unstarted,
		model.Started,
		model.Resumed,
		model.Finished,
	} {
		t.Run(fmt.Sprintf("更新前のWork.Stateが%sの場合はValidationErrorになること", state), func(t *testing.T) {
			cmd, s, _ := newCommandWithInmemory()
			s.Work = source
			s.Work.State = state

			err := cmd.ResumeWork(source.UserID, source.ID, command.ChangeWorkStateParam{Time: time.Now()})

			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

func TestFinishWork(t *testing.T) {
	source := newWork()
	source.State = model.Resumed

	t.Run("完了", func(t *testing.T) {
		testChangeWorkState(t, command.Command.FinishWork, source, event.FinishWork, model.Finished)
	})

	for _, state := range []model.WorkState{
		model.UnknownState,
		model.Unstarted,
		model.Finished,
	} {
		t.Run(fmt.Sprintf("更新前のWork.Stateが%sの場合はValidationErrorになること", state), func(t *testing.T) {
			cmd, s, _ := newCommandWithInmemory()
			s.Work = source
			s.Work.State = state

			err := cmd.FinishWork(source.UserID, source.ID, command.ChangeWorkStateParam{Time: time.Now()})

			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

func TestCancelFinishWork(t *testing.T) {
	source := newWork()
	source.State = model.Finished

	t.Run("完了取り消し", func(t *testing.T) {
		testChangeWorkState(t, command.Command.CancelFinishWork, source, event.CancelFinishWork, model.Paused)
	})

	for _, state := range []model.WorkState{
		model.UnknownState,
		model.Unstarted,
		model.Started,
		model.Paused,
		model.Resumed,
	} {
		t.Run(fmt.Sprintf("更新前のWork.Stateが%sの場合はValidationErrorになること", state), func(t *testing.T) {
			cmd, s, _ := newCommandWithInmemory()
			s.Work = source
			s.Work.State = state

			err := cmd.CancelFinishWork(source.UserID, source.ID, command.ChangeWorkStateParam{Time: time.Now()})

			if _, ok := err.(command.ValidationError); !ok {
				t.Errorf("error = %#v, wants ValidationError", err)
			}
		})
	}
}

type changeWorkStateFunc func(command.Command, string, string, command.ChangeWorkStateParam) error

func testChangeWorkState(t *testing.T, testFunc changeWorkStateFunc, source model.Work, eventAction event.Action, state model.WorkState) {
	t.Run("Expectation", func(t *testing.T) {
		testChangeWorkState_Expectation(t, testFunc, source)
	})
	t.Run("ReturnValue", func(t *testing.T) {
		testChangeWorkState_ReturnValue(t, testFunc, source)
	})
	t.Run("SaveValue", func(t *testing.T) {
		testChangeWorkState_SaveValue(t, testFunc, source, eventAction, state)
	})
	t.Run("PublishValue", func(t *testing.T) {
		testChangeWorkState_OK_PublishValue(t, testFunc, source)
	})
	t.Run("InvalidUserID", func(t *testing.T) {
		testChangeWorkState_InvalidUserID(t, testFunc, source)
	})
	t.Run("InvalidWorkID", func(t *testing.T) {
		testChangeWorkState_InvalidWorkID(t, testFunc, source)
	})
	t.Run("StoreError", func(t *testing.T) {
		testChangeWorkState_StoreError(t, testFunc, source)
	})
	t.Run("InvalidParam", func(t *testing.T) {
		testChangeWorkState_InvalidParam(t, testFunc, source)
	})
}

func testChangeWorkState_Expectation(t *testing.T, testFunc changeWorkStateFunc, source model.Work) {
	cmd, mockStore, mockPublisher, mockCtrl := newCommandWithGoMock(t)
	defer mockCtrl.Finish()

	gomock.InOrder(
		mockStore.EXPECT().GetWork(gomock.Any(), gomock.Any()).Do(func(_ string, dst *model.Work) {
			*dst = source
		}),
		mockStore.EXPECT().PutEvent(gomock.Any()),
		mockStore.EXPECT().PutWork(gomock.Any()),
		mockPublisher.EXPECT().Publish(gomock.Any()),
	)

	testFunc(cmd, source.UserID, source.ID, command.ChangeWorkStateParam{Time: time.Now()})
}

func testChangeWorkState_ReturnValue(t *testing.T, testFunc changeWorkStateFunc, source model.Work) {
	cmd, s, _ := newCommandWithInmemory()
	s.Work = source

	err := testFunc(cmd, source.UserID, source.ID, command.ChangeWorkStateParam{Time: time.Now()})

	t.Run("errorがnil であること", func(t *testing.T) {
		if err != nil {
			t.Errorf("error = %#v, wants nil", err)
		}
	})
}

func testChangeWorkState_SaveValue(t *testing.T, testFunc changeWorkStateFunc, source model.Work, eventAction event.Action, state model.WorkState) {
	cmd, s, _ := newCommandWithInmemory()
	s.Work = source

	now := time.Now()
	testFunc(cmd, source.UserID, source.ID, command.ChangeWorkStateParam{Time: now})

	var (
		e = s.Event
		w = s.Work
	)

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
		t.Run("UserIDに引数で指定したuserIDを設定すること", func(t *testing.T) {
			if e.UserID != source.UserID {
				t.Errorf("event.UserID = %s, wants = %s", e.UserID, source.UserID)
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
		t.Run("UserIDに更新前のWork.UserIDを設定すること", func(t *testing.T) {
			if w.UserID != source.UserID {
				t.Errorf("work.UserID = %s, wants = %s", w.UserID, source.UserID)
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
}

func testChangeWorkState_OK_PublishValue(t *testing.T, testFunc changeWorkStateFunc, source model.Work) {
	cmd, s, p := newCommandWithInmemory()
	s.Work = source

	testFunc(cmd, source.UserID, source.ID, command.ChangeWorkStateParam{Time: time.Now()})

	t.Run("保存したEventをPublishすること", func(t *testing.T) {
		b, _ := event.MarshalPb(s.Event)
		if !cmp.Equal(p.Msg, b) {
			t.Error("publish msg != saved Event, wants equals")
		}
	})
}

func testChangeWorkState_InvalidUserID(t *testing.T, testFunc changeWorkStateFunc, source model.Work) {
	cmd, s, _ := newCommandWithInmemory()
	s.Work = source

	err := testFunc(cmd, "anotherUserID", source.ID, command.ChangeWorkStateParam{Time: time.Now()})

	t.Run("userIDが更新前と異なる場合はErrForbiddenを返すこと", func(t *testing.T) {
		if err != command.ErrForbidden {
			t.Errorf("error = %#v, wants = %#v", err, command.ErrForbidden)
		}
	})
}

func testChangeWorkState_InvalidWorkID(t *testing.T, testFunc changeWorkStateFunc, source model.Work) {
	cmd, s, _ := newCommandWithInmemory()
	s.GetWorkError = store.ErrNotfound

	err := testFunc(cmd, source.UserID, source.ID, command.ChangeWorkStateParam{Time: time.Now()})

	t.Run("Store#GetWorkがErrNotfoundの場合はErrNotfoundを返すこと", func(t *testing.T) {
		if err != command.ErrNotfound {
			t.Errorf("error = %#v, wants = %#v", err, command.ErrNotfound)
		}
	})
}

func testChangeWorkState_StoreError(t *testing.T, testFunc changeWorkStateFunc, source model.Work) {
	someErr := errors.New("Some Error")

	t.Run("Store#PutEventがエラーになった場合はerrorを返すこと", func(t *testing.T) {
		cmd, s, _ := newCommandWithInmemory()
		s.Work = source
		s.PutEventError = someErr

		err := testFunc(cmd, source.UserID, source.ID, command.ChangeWorkStateParam{Time: time.Now()})

		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})

	t.Run("Store#PutWorkがエラーになった場合はerrorを返すこと", func(t *testing.T) {
		cmd, s, _ := newCommandWithInmemory()
		s.Work = source
		s.PutWorkError = someErr

		err := testFunc(cmd, source.UserID, source.ID, command.ChangeWorkStateParam{Time: time.Now()})

		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})
}

func testChangeWorkState_InvalidParam(t *testing.T, testFunc changeWorkStateFunc, source model.Work) {
	cmd, s, _ := newCommandWithInmemory()
	s.Work = source

	err := testFunc(cmd, source.UserID, source.ID, command.ChangeWorkStateParam{Time: source.Time.Add(-1 * time.Second)})

	t.Run("更新前のWork.Timeがparam.Timeより大きい場合はValidationErrorになること", func(t *testing.T) {
		if _, ok := err.(command.ValidationError); !ok {
			t.Errorf("error = %#v, wants ValidationError", err)
		}
	})
}

func TestClose(t *testing.T) {
	var (
		mockCtrl  = gomock.NewController(t)
		mockStore = store.NewMockStore(mockCtrl)
		cmd       = command.New(command.Dependency{Store: mockStore})
	)
	defer mockCtrl.Finish()

	t.Run("dep.Store#Closeを呼ぶこと", func(t *testing.T) {
		mockStore.EXPECT().Close()
		cmd.Close()
	})

	t.Run("dep.Store#Closeがエラーでない場合はnilを返すこと", func(t *testing.T) {
		mockStore.EXPECT().Close()
		err := cmd.Close()
		if err != nil {
			t.Errorf("error = %#v, wants = nil", err)
		}
	})

	t.Run("dep.Store#Closeがエラーになった場合はerrorを返すこと", func(t *testing.T) {
		someErr := errors.New("Some Error")

		mockStore.EXPECT().Close().Return(someErr)
		err := cmd.Close()
		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})
}

func newCommandWithGoMock(t *testing.T) (command.Command, *store.MockStore, *publisher.MockPublisher, *gomock.Controller) {
	var (
		mockCtrl        = gomock.NewController(t)
		mockStore       = store.NewMockStore(mockCtrl)
		mockStoreInTran = store.NewMockStore(mockCtrl)
		mockPublisher   = publisher.NewMockPublisher(mockCtrl)
	)

	mockStore.EXPECT().RunInTransaction(gomock.Any()).DoAndReturn(func(f func(store.Store) error) error {
		return f(mockStoreInTran)
	})

	cmd := command.New(command.Dependency{Store: mockStore, Publisher: mockPublisher})
	return cmd, mockStoreInTran, mockPublisher, mockCtrl
}

func newCommandWithInmemory() (command.Command, *store.InmemoryStore, *publisher.InmemoryPublisher) {
	s := store.NewInmemoryStore()
	p := publisher.NewInmemoryPublisher()
	return command.New(command.Dependency{Store: s, Publisher: p}), s, p
}

func newWork() model.Work {
	workTime := time.Now().Add(-1 * time.Hour)

	return model.Work{
		ID:        util.NewUUID(),
		EventID:   util.NewUUID(),
		UserID:    util.NewUUID(),
		Title:     "Some Title",
		Time:      workTime,
		State:     model.Started,
		UpdatedAt: time.Now(),
	}
}
