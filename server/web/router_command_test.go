package main_test

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"testing"
	"time"

	"cloud.google.com/go/datastore"
	"cloud.google.com/go/pubsub"
	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
	"github.com/iii-ishida/workrec/server/command"
	"github.com/iii-ishida/workrec/server/command/model"
	"github.com/iii-ishida/workrec/server/util"
	main "github.com/iii-ishida/workrec/server/web"
)

func init() {
	ctx := context.Background()
	client, _ := pubsub.NewClient(ctx, util.ProjectID())
	defer client.Close()
	client.CreateTopic(ctx, "workrec")
}

func TestCreateWork_OK(t *testing.T) {
	defer clearStore()

	var (
		userID = "some-userid"
		title  = "some title"
		req    = newRequestWithLogin(userID, "POST", "/v1/works", newCreateWorkRequest(title))
	)

	res := doLoggedInRequest(t, userID, req)
	work := getLatestWork()

	t.Run("ステータスコードに201を設定すること", func(t *testing.T) {
		if res.StatusCode != 201 {
			t.Errorf("StatusCode = %d, wants = 201", res.StatusCode)
		}
	})

	t.Run("パラメータのTitleを使用してWorkを作成すること", func(t *testing.T) {
		if work.Title != title {
			t.Errorf("Title = %s, wants = %s", work.Title, title)
		}
	})

	t.Run("Locationヘッダに作成したWorkのURLを設定すること", func(t *testing.T) {
		wants := fmt.Sprintf("%s/v1/works/%s", util.APIOrigin(), work.ID)
		if l, _ := res.Location(); l.String() != wants {
			t.Errorf("Location = %s, wants = %s", l, wants)
		}
	})
}

func TestCreateWork_NotLoggedIn(t *testing.T) {
	defer clearStore()

	var (
		req, _ = http.NewRequest("POST", "/v1/works", newCreateWorkRequest("some title"))
	)

	res := doRequest(t, req)

	t.Run("ステータスコードに401を設定すること", func(t *testing.T) {
		if res.StatusCode != 401 {
			t.Errorf("StatusCode = %d, wants = 401", res.StatusCode)
		}
	})
}

func TestCreateWork_InvalidParam(t *testing.T) {
	defer clearStore()

	var (
		userID       = "some-userid"
		invalidParam = bytes.NewReader([]byte("invalid"))
		req          = newRequestWithLogin(userID, "POST", "/v1/works", invalidParam)
	)

	res := doLoggedInRequest(t, userID, req)

	t.Run("ステータスコードに400を設定すること", func(t *testing.T) {
		if res.StatusCode != 400 {
			t.Errorf("StatusCode = %d, wants = 400", res.StatusCode)
		}
	})

	t.Run("Workを作成しないこと", func(t *testing.T) {
		work := getLatestWork()
		if work != nil {
			t.Error("created, wants not created")
		}
	})
}

func TestUpdateWork_OK(t *testing.T) {
	defer clearStore()

	var (
		userID = "some-userid"
		source = newWork(userID)
	)
	putWork(source)

	var (
		title = "updated title"
		req   = newRequestWithLogin(userID, "PATCH", fmt.Sprintf("/v1/works/%s", source.ID), newUpdateWorkRequest(title))
	)

	res := doLoggedInRequest(t, userID, req)
	work := getLatestWork()

	t.Run("ステータスコードに200を設定すること", func(t *testing.T) {
		if res.StatusCode != 200 {
			t.Errorf("StatusCode = %d, wants = 200", res.StatusCode)
		}
	})

	t.Run("対象WorkのTitleをパラメータのTitleで更新すること", func(t *testing.T) {
		if work.Title != title {
			t.Errorf("Title = %s, wants = %s", work.Title, title)
		}
	})
}

func TestUpdateWork_InvalidWorkID(t *testing.T) {
	defer clearStore()

	var (
		userID = "some-userid"
		title  = "updated title"
		req    = newRequestWithLogin(userID, "PATCH", "/v1/works/notfoundid", newUpdateWorkRequest(title))
	)

	res := doLoggedInRequest(t, userID, req)
	work := getLatestWork()

	t.Run("ステータスコードに404を設定すること", func(t *testing.T) {
		if res.StatusCode != 404 {
			t.Errorf("StatusCode = %d, wants = 404", res.StatusCode)
		}
	})

	t.Run("Workを作成しないこと", func(t *testing.T) {
		if work != nil {
			t.Error("created, wants not created")
		}
	})
}

func TestUpdateWork_InvalidUserID(t *testing.T) {
	defer clearStore()

	var (
		userID = "some-userid"
		source = newWork(userID)
	)
	putWork(source)

	var (
		anotherUserID = "another-user-id"
		req           = newRequestWithLogin(anotherUserID, "PATCH", fmt.Sprintf("/v1/works/%s", source.ID), newUpdateWorkRequest("updated title"))
	)

	res := doLoggedInRequest(t, anotherUserID, req)
	work := getLatestWork()

	t.Run("ステータスコードに404を設定すること", func(t *testing.T) {
		if res.StatusCode != 404 {
			t.Errorf("StatusCode = %d, wants = 404", res.StatusCode)
		}
	})

	t.Run("Workを更新しないこと", func(t *testing.T) {
		if work.Title != source.Title {
			t.Errorf("Title = %s, wants = %s", work.Title, source.Title)
		}
	})
}

func TestUpdateWork_InvalidParam(t *testing.T) {
	defer clearStore()

	var (
		userID = "some-userid"
		source = newWork(userID)
	)
	putWork(source)

	var (
		invalidParam = bytes.NewReader([]byte("invalid"))
		req          = newRequestWithLogin(userID, "PATCH", fmt.Sprintf("/v1/works/%s", source.ID), invalidParam)
	)

	res := doLoggedInRequest(t, userID, req)
	work := getLatestWork()

	t.Run("ステータスコードに400を設定すること", func(t *testing.T) {
		if res.StatusCode != 400 {
			t.Errorf("StatusCode = %d, wants = 400", res.StatusCode)
		}
	})

	t.Run("Workを更新しないこと", func(t *testing.T) {
		if work.Title != source.Title {
			t.Errorf("Title = %s, wants = %s", work.Title, source.Title)
		}
	})
}

func TestDeleteWork_OK(t *testing.T) {
	defer clearStore()

	var (
		userID = "some-userid"
		source = newWork(userID)
	)
	putWork(source)

	var (
		req = newRequestWithLogin(userID, "DELETE", fmt.Sprintf("/v1/works/%s", source.ID), nil)
	)

	res := doLoggedInRequest(t, userID, req)
	work := getLatestWork()

	t.Run("ステータスコードに200を設定すること", func(t *testing.T) {
		if res.StatusCode != 200 {
			t.Errorf("StatusCode = %d, wants = 200", res.StatusCode)
		}
	})

	t.Run("対象Workを削除すること", func(t *testing.T) {
		if work != nil {
			t.Error("not deleted, wants deleted")
		}
	})
}

func TestDeleteWork_InvalidWorkID(t *testing.T) {
	defer clearStore()

	var (
		userID = "some-userid"
		source = newWork(userID)
	)
	putWork(source)

	var (
		req = newRequestWithLogin(userID, "DELETE", "/v1/works/notfoundid", nil)
	)

	res := doLoggedInRequest(t, userID, req)

	t.Run("ステータスコードに404を設定すること", func(t *testing.T) {
		if res.StatusCode != 404 {
			t.Errorf("StatusCode = %d, wants = 404", res.StatusCode)
		}
	})
}

func TestDeleteWork_InvalidUserID(t *testing.T) {
	defer clearStore()

	var (
		userID = "some-userid"
		source = newWork(userID)
	)
	putWork(source)

	var (
		anotherUserID = "another-user-id"
		req           = newRequestWithLogin(anotherUserID, "DELETE", fmt.Sprintf("/v1/works/%s", source.ID), nil)
	)

	res := doLoggedInRequest(t, anotherUserID, req)
	work := getLatestWork()

	t.Run("ステータスコードに404を設定すること", func(t *testing.T) {
		if res.StatusCode != 404 {
			t.Errorf("StatusCode = %d, wants = 404", res.StatusCode)
		}
	})

	t.Run("Workを削除しないこと", func(t *testing.T) {
		if work == nil {
			t.Error("Work deleted, wants not deleted")
		}
	})
}

func TestChangeStateWork(t *testing.T) {
	var tests = []struct {
		customMethod string
		sourceState  model.WorkState
		wantsState   model.WorkState
	}{
		{"start", model.Unstarted, model.Started},
		{"pause", model.Started, model.Paused},
		{"resume", model.Paused, model.Resumed},
		{"finish", model.Resumed, model.Finished},
		{"cancelFinish", model.Finished, model.Paused},
	}
	for _, tc := range tests {
		t.Run(fmt.Sprintf("%s_OK", tc.customMethod), func(t *testing.T) {
			testChangeWorkState_OK(t, tc.customMethod, tc.sourceState, tc.wantsState)
		})
		t.Run(fmt.Sprintf("%s_InvalidWorkID", tc.customMethod), func(t *testing.T) {
			testChangeWorkState_InvalidWorkID(t, tc.customMethod, tc.sourceState, tc.wantsState)
		})
		t.Run(fmt.Sprintf("%s_InvalidUserID", tc.customMethod), func(t *testing.T) {
			testChangeWorkState_InvalidUserID(t, tc.customMethod, tc.sourceState, tc.wantsState)
		})
		t.Run(fmt.Sprintf("%s_InvalidParam", tc.customMethod), func(t *testing.T) {
			testChangeWorkState_InvalidParam(t, tc.customMethod, tc.sourceState, tc.wantsState)
		})
		t.Run(fmt.Sprintf("%s_InvalidState", tc.customMethod), func(t *testing.T) {
			testChangeWorkState_InvalidState(t, tc.customMethod, tc.sourceState, tc.wantsState)
		})
	}
}

func testChangeWorkState_OK(t *testing.T, customMethod string, sourceState, wantsState model.WorkState) {
	defer clearStore()

	var (
		userID = "some-userid"
		source = newWorkWithState(userID, sourceState)
	)
	putWork(source)

	var (
		workTime = source.Time.Add(10 * time.Minute)
		req      = newRequestWithLogin(userID, "POST", fmt.Sprintf("/v1/works/%s:%s", source.ID, customMethod), newChangeWorkStateRequest(workTime))
	)

	res := doLoggedInRequest(t, userID, req)
	work := getLatestWork()

	t.Run("ステータスコードに200を設定すること", func(t *testing.T) {
		if res.StatusCode != 200 {
			t.Errorf("StatusCode = %d, wants = 200", res.StatusCode)
		}
	})

	t.Run(fmt.Sprintf("対象WorkのStateを%sに更新すること", wantsState), func(t *testing.T) {
		if work.State != wantsState {
			t.Errorf("State = %s, wants = %s", work.State, wantsState)
		}
	})

	t.Run("対象WorkのTimeをパラメータのTimeで更新すること", func(t *testing.T) {
		if !work.Time.Equal(workTime) {
			t.Errorf("Time = %s, wants = %s", work.Time, workTime)
		}
	})
}

func testChangeWorkState_InvalidWorkID(t *testing.T, customMethod string, sourceState, wantsState model.WorkState) {
	defer clearStore()

	var (
		userID   = "some-userid"
		workTime = time.Now()
		req      = newRequestWithLogin(userID, "POST", fmt.Sprintf("/v1/works/notfoundid:%s", customMethod), newChangeWorkStateRequest(workTime))
	)

	res := doLoggedInRequest(t, userID, req)

	t.Run("ステータスコードに404を設定すること", func(t *testing.T) {
		if res.StatusCode != 404 {
			t.Errorf("StatusCode = %d, wants = 404", res.StatusCode)
		}
	})

	t.Run("Workを作成しないこと", func(t *testing.T) {
		work := getLatestWork()
		if work != nil {
			t.Error("created, wants not created")
		}
	})
}

func testChangeWorkState_InvalidUserID(t *testing.T, customMethod string, sourceState, wantsState model.WorkState) {
	defer clearStore()

	var (
		userID = "some-userid"
		source = newWorkWithState(userID, sourceState)
	)
	putWork(source)

	var (
		anotherUserID = "another-user-id"
		workTime      = source.Time.Add(10 * time.Minute)
		req           = newRequestWithLogin(anotherUserID, "POST", fmt.Sprintf("/v1/works/%s:%s", source.ID, customMethod), newChangeWorkStateRequest(workTime))
	)

	res := doLoggedInRequest(t, anotherUserID, req)
	work := getLatestWork()

	t.Run("ステータスコードに404を設定すること", func(t *testing.T) {
		if res.StatusCode != 404 {
			t.Errorf("StatusCode = %d, wants = 404", res.StatusCode)
		}
	})

	t.Run("Workを更新しないこと", func(t *testing.T) {
		if work.State != source.State {
			t.Errorf("State = %s, wants = %s", work.State, source.State)
		}
	})
}

func testChangeWorkState_InvalidParam(t *testing.T, customMethod string, sourceState, wantsState model.WorkState) {
	defer clearStore()

	var (
		userID = "some-userid"
		source = newWorkWithState(userID, sourceState)
	)
	putWork(source)

	var (
		invalidParam = bytes.NewReader([]byte("invalid"))
		req          = newRequestWithLogin(userID, "POST", fmt.Sprintf("/v1/works/%s:%s", source.ID, customMethod), invalidParam)
	)

	res := doLoggedInRequest(t, userID, req)
	work := getLatestWork()

	t.Run("ステータスコードに400を設定すること", func(t *testing.T) {
		if res.StatusCode != 400 {
			t.Errorf("StatusCode = %d, wants = 400", res.StatusCode)
		}
	})

	t.Run("Workを更新しないこと", func(t *testing.T) {
		if work.State != source.State {
			t.Errorf("State = %s, wants = %s", work.State, source.State)
		}
	})
}

func testChangeWorkState_InvalidState(t *testing.T, customMethod string, sourceState, wantsState model.WorkState) {
	defer clearStore()

	var (
		userID        = "some-userid"
		sameStateWork = newWorkWithState(userID, wantsState)
	)
	putWork(sameStateWork)

	var (
		workTime = sameStateWork.Time.Add(10 * time.Minute)
		req      = newRequestWithLogin(userID, "POST", fmt.Sprintf("/v1/works/%s:%s", sameStateWork.ID, customMethod), newChangeWorkStateRequest(workTime))
	)

	res := doLoggedInRequest(t, userID, req)
	work := getLatestWork()

	t.Run("ステータスコードに400を設定すること", func(t *testing.T) {
		if res.StatusCode != 400 {
			t.Errorf("StatusCode = %d, wants = 400", res.StatusCode)
		}
	})

	t.Run("Workを更新しないこと", func(t *testing.T) {
		if !work.Time.Equal(sameStateWork.Time) {
			t.Errorf("Time = %s, wants = %s", work.Time, sameStateWork.Time)
		}
	})
}

func newCreateWorkRequest(title string) io.Reader {
	pb := main.CreateWorkRequestPb{Title: title}
	b, _ := proto.Marshal(&pb)
	return bytes.NewReader(b)
}

func newUpdateWorkRequest(title string) io.Reader {
	pb := main.UpdateWorkRequestPb{Title: title}
	b, _ := proto.Marshal(&pb)
	return bytes.NewReader(b)
}

func newChangeWorkStateRequest(tm time.Time) io.Reader {
	timePb, _ := ptypes.TimestampProto(tm)
	pb := main.ChangeWorkStateRequestPb{Time: timePb}
	b, _ := proto.Marshal(&pb)
	return bytes.NewReader(b)
}

func newWork(userID string) model.Work {
	return newWorkWithState(userID, model.Unstarted)
}

func newWorkWithState(userID string, state model.WorkState) model.Work {
	return model.Work{
		UserID:    userID,
		ID:        util.NewUUID(),
		Title:     "some title",
		State:     state,
		UpdatedAt: time.Now().Add(-1 * time.Hour),
	}
}

func putWork(w model.Work) {
	r, _ := http.NewRequest("GET", "/", nil)
	s, _ := command.NewCloudDataStore(r)
	defer s.Close()

	s.PutWork(w)
}

func getLatestWork() *model.Work {
	ctx := context.Background()
	client, _ := datastore.NewClient(ctx, util.ProjectID())
	defer client.Close()

	var ws []model.Work

	q := datastore.NewQuery(model.KindNameWork).Order("-UpdatedAt").Limit(1)
	client.GetAll(ctx, q, &ws)

	if len(ws) == 0 {
		return nil
	}
	return &ws[0]
}
