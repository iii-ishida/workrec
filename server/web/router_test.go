package main_test

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"cloud.google.com/go/datastore"
	"github.com/golang/mock/gomock"
	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
	"github.com/iii-ishida/workrec/server/auth"
	"github.com/iii-ishida/workrec/server/command"
	"github.com/iii-ishida/workrec/server/command/model"
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/util"
	main "github.com/iii-ishida/workrec/server/web"
)

func TestCreateWork(t *testing.T) {
	userID := "some-userid"

	t.Run("正常時", func(t *testing.T) {
		defer clearStore()

		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
		)
		defer mockCtrl.Finish()
		getUserID(mockUserIDGetter, userID)

		server := httptest.NewServer(main.NewRouter(mockUserIDGetter))
		defer server.Close()

		title := "some title"
		req := newRequestWithLogin(userID, "POST", server.URL+"/v1/works", newCreateWorkRequest(title))
		res, _ := http.DefaultClient.Do(req)

		work := getLatestWork()

		t.Run("パラメータのTitleを使用してWorkを作成すること", func(t *testing.T) {
			if work.Title != title {
				t.Errorf("Title = %s, wants = %s", work.Title, title)
			}
		})

		t.Run("ステータスコードに201を設定すること", func(t *testing.T) {
			if res.StatusCode != 201 {
				t.Errorf("StatusCode = %d, wants = 201", res.StatusCode)
			}
		})

		t.Run("Locationヘッダに作成したWorkのURLを設定すること", func(t *testing.T) {
			wants := fmt.Sprintf("%s/v1/works/%s", util.GetAPIOrigin(), work.ID)
			if l, _ := res.Location(); l.String() != wants {
				t.Errorf("Location = %s, wants = %s", l, wants)
			}
		})
	})

	t.Run("パラメータ不正", func(t *testing.T) {
		defer clearStore()

		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
		)
		defer mockCtrl.Finish()
		getUserID(mockUserIDGetter, userID)

		server := httptest.NewServer(main.NewRouter(mockUserIDGetter))
		defer server.Close()

		invalidParam := bytes.NewReader([]byte("invalid"))
		req := newRequestWithLogin(userID, "POST", server.URL+"/v1/works", invalidParam)
		res, _ := http.DefaultClient.Do(req)

		work := getLatestWork()

		t.Run("ステータスコードに400を設定すること", func(t *testing.T) {
			if res.StatusCode != 400 {
				t.Errorf("StatusCode = %d, wants = 400", res.StatusCode)
			}
		})

		t.Run("Workを作成しないこと", func(t *testing.T) {
			if work != nil {
				t.Error("created, wants not created")
			}
		})
	})
}

func TestUpdateWork(t *testing.T) {
	userID := "some-userid"

	source := model.Work{
		UserID:    userID,
		ID:        util.NewUUID(),
		Title:     "some title",
		UpdatedAt: time.Now().Add(-1 * time.Hour),
	}

	t.Run("正常時", func(t *testing.T) {
		defer clearStore()
		createWork(source)

		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
		)
		defer mockCtrl.Finish()
		getUserID(mockUserIDGetter, userID)

		server := httptest.NewServer(main.NewRouter(mockUserIDGetter))
		defer server.Close()

		url := fmt.Sprintf("%s/v1/works/%s", server.URL, source.ID)
		title := "updated title"
		req := newRequestWithLogin(userID, "PATCH", url, newUpdateWorkRequest(title))
		res, _ := http.DefaultClient.Do(req)

		work := getLatestWork()

		t.Run("対象WorkのTitleをパラメータのTitleで更新すること", func(t *testing.T) {
			if work.Title != title {
				t.Errorf("Title = %s, wants = %s", work.Title, title)
			}
		})

		t.Run("ステータスコードに200を設定すること", func(t *testing.T) {
			if res.StatusCode != 200 {
				t.Errorf("StatusCode = %d, wants = 200", res.StatusCode)
			}
		})
	})

	t.Run("存在しないid", func(t *testing.T) {
		defer clearStore()

		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
		)
		defer mockCtrl.Finish()
		getUserID(mockUserIDGetter, userID)

		server := httptest.NewServer(main.NewRouter(mockUserIDGetter))
		defer server.Close()

		url := fmt.Sprintf("%s/v1/works/notfoundid", server.URL)
		title := "updated title"
		req := newRequestWithLogin(userID, "PATCH", url, newUpdateWorkRequest(title))
		res, _ := http.DefaultClient.Do(req)

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
	})

	t.Run("パラメータ不正", func(t *testing.T) {
		defer clearStore()
		createWork(source)

		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
		)
		defer mockCtrl.Finish()
		getUserID(mockUserIDGetter, userID)

		server := httptest.NewServer(main.NewRouter(mockUserIDGetter))
		defer server.Close()

		url := fmt.Sprintf("%s/v1/works/%s", server.URL, source.ID)
		invalidParam := bytes.NewReader([]byte("invalid"))
		req := newRequestWithLogin(userID, "PATCH", url, invalidParam)
		res, _ := http.DefaultClient.Do(req)

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
	})
}

func TestDeleteWork(t *testing.T) {
	userID := "some-userid"

	source := model.Work{
		UserID:    userID,
		ID:        util.NewUUID(),
		UpdatedAt: time.Now().Add(-1 * time.Hour),
	}

	t.Run("正常時", func(t *testing.T) {
		defer clearStore()
		createWork(source)

		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
		)
		defer mockCtrl.Finish()
		getUserID(mockUserIDGetter, userID)

		server := httptest.NewServer(main.NewRouter(mockUserIDGetter))
		defer server.Close()

		url := fmt.Sprintf("%s/v1/works/%s", server.URL, source.ID)
		req := newRequestWithLogin(userID, "DELETE", url, nil)
		res, _ := http.DefaultClient.Do(req)

		work := getLatestWork()

		t.Run("対象Workを削除すること", func(t *testing.T) {
			if work != nil {
				t.Error("not deleted, wants deleted")
			}
		})

		t.Run("ステータスコードに200を設定すること", func(t *testing.T) {
			if res.StatusCode != 200 {
				t.Errorf("StatusCode = %d, wants = 200", res.StatusCode)
			}
		})
	})

	t.Run("存在しないid", func(t *testing.T) {
		defer clearStore()

		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
		)
		defer mockCtrl.Finish()
		getUserID(mockUserIDGetter, userID)

		server := httptest.NewServer(main.NewRouter(mockUserIDGetter))
		defer server.Close()

		url := fmt.Sprintf("%s/v1/works/notfoundid", server.URL)
		req := newRequestWithLogin(userID, "DELETE", url, nil)
		res, _ := http.DefaultClient.Do(req)

		t.Run("ステータスコードに404を設定すること", func(t *testing.T) {
			if res.StatusCode != 404 {
				t.Errorf("StatusCode = %d, wants = 404", res.StatusCode)
			}
		})
	})
}

func TestStartWork(t *testing.T) {
	testChangeWorkState(t, "start", model.Unstarted, model.Started)
}

func TestPauseWork(t *testing.T) {
	testChangeWorkState(t, "pause", model.Started, model.Paused)
}

func TestResumeWork(t *testing.T) {
	testChangeWorkState(t, "resume", model.Paused, model.Resumed)
}

func TestFinishWork(t *testing.T) {
	testChangeWorkState(t, "finish", model.Resumed, model.Finished)
}

func TestCancelFinishWork(t *testing.T) {
	testChangeWorkState(t, "cancelFinish", model.Finished, model.Paused)
}

func testChangeWorkState(t *testing.T, customMethod string, sourceState, wantsState model.WorkState) {
	userID := "some-userid"

	source := model.Work{
		UserID:    userID,
		ID:        util.NewUUID(),
		State:     sourceState,
		Time:      time.Now().Add(-1 * time.Hour),
		UpdatedAt: time.Now().Add(-1 * time.Hour),
	}

	t.Run("正常時", func(t *testing.T) {
		defer clearStore()
		createWork(source)

		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
		)
		defer mockCtrl.Finish()
		getUserID(mockUserIDGetter, userID)

		server := httptest.NewServer(main.NewRouter(mockUserIDGetter))
		defer server.Close()

		url := fmt.Sprintf("%s/v1/works/%s:%s", server.URL, source.ID, customMethod)
		workTime := source.Time.Add(10 * time.Minute)
		req := newRequestWithLogin(userID, "POST", url, newChangeWorkStateRequest(workTime))
		res, _ := http.DefaultClient.Do(req)

		work := getLatestWork()

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

		t.Run("ステータスコードに200を設定すること", func(t *testing.T) {
			if res.StatusCode != 200 {
				t.Errorf("StatusCode = %d, wants = 200", res.StatusCode)
			}
		})
	})

	t.Run("存在しないid", func(t *testing.T) {
		defer clearStore()

		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
		)
		defer mockCtrl.Finish()
		getUserID(mockUserIDGetter, userID)

		server := httptest.NewServer(main.NewRouter(mockUserIDGetter))
		defer server.Close()

		url := fmt.Sprintf("%s/v1/works/notfoundid:%s", server.URL, customMethod)
		workTime := source.Time.Add(10 * time.Minute)
		req := newRequestWithLogin(userID, "POST", url, newChangeWorkStateRequest(workTime))
		res, _ := http.DefaultClient.Do(req)

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
	})

	t.Run("パラメータ不正", func(t *testing.T) {
		defer clearStore()
		createWork(source)

		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
		)
		defer mockCtrl.Finish()
		getUserID(mockUserIDGetter, userID)

		server := httptest.NewServer(main.NewRouter(mockUserIDGetter))
		defer server.Close()

		url := fmt.Sprintf("%s/v1/works/%s:%s", server.URL, source.ID, customMethod)
		invalidParam := bytes.NewReader([]byte("invalid"))
		req := newRequestWithLogin(userID, "POST", url, invalidParam)
		res, _ := http.DefaultClient.Do(req)

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
	})

	t.Run("State不正", func(t *testing.T) {
		defer clearStore()

		sameStateWork := source
		sameStateWork.State = wantsState
		createWork(sameStateWork)

		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
		)
		defer mockCtrl.Finish()
		getUserID(mockUserIDGetter, userID)

		server := httptest.NewServer(main.NewRouter(mockUserIDGetter))
		defer server.Close()

		url := fmt.Sprintf("%s/v1/works/%s:%s", server.URL, source.ID, customMethod)
		workTime := source.Time.Add(10 * time.Minute)
		req := newRequestWithLogin(userID, "POST", url, newChangeWorkStateRequest(workTime))
		res, _ := http.DefaultClient.Do(req)

		work := getLatestWork()

		t.Run("ステータスコードに400を設定すること", func(t *testing.T) {
			if res.StatusCode != 400 {
				t.Errorf("StatusCode = %d, wants = 400", res.StatusCode)
			}
		})

		t.Run("Workを更新しないこと", func(t *testing.T) {
			if !work.Time.Equal(source.Time) {
				t.Errorf("Time = %s, wants = %s", work.Time, source.Time)
			}
		})
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

func createWork(w model.Work) {
	r, _ := http.NewRequest("GET", "/", nil)
	s, _ := command.NewCloudDataStore(r)
	s.PutWork(w)
}

func getLatestWork() *model.Work {
	ctx := context.Background()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())

	var ws []model.Work

	q := datastore.NewQuery(model.KindNameWork).Order("-UpdatedAt").Limit(1)
	client.GetAll(ctx, q, &ws)

	if len(ws) == 0 {
		return nil
	}
	return &ws[0]
}

func getUserID(mockUserIDGetter *auth.MockUserIDGetter, userID string) {
	mockUserIDGetter.EXPECT().GetUserID(gomock.Any()).Return(userID, nil)
}

func newRequestWithLogin(userID, method, url string, body io.Reader) *http.Request {
	req, _ := http.NewRequest(method, url, body)
	req.Header.Add("Authorization", "Bearer someidtoken")
	ctx := auth.ContextWithUserID(req.Context(), userID)
	return req.WithContext(ctx)
}

func clearStore() {
	ctx := context.Background()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())

	for _, kind := range []string{model.KindNameWork, event.KindName} {
		q := datastore.NewQuery(kind).KeysOnly()
		keys, _ := client.GetAll(ctx, q, nil)
		client.DeleteMulti(ctx, keys)
	}
}
