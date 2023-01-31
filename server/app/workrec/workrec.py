from copy import deepcopy
from enum import StrEnum, auto
from dataclasses import dataclass
from datetime import datetime
from typing import Optional
from app.workrec.repository import BaseEntity, CloudDatastoreRepo, Query


class WorkrecClient:
    def __init__(self, *, repo: "CloudDatastoreRepo"):
        self._repo = repo

    def task_list(
        self, *, user_id, limit: Optional[int] = None, cursor: Optional[str] = None
    ) -> tuple[list["Task"], str]:
        """ユーザーに紐づくタスクのリストを返します

        :param user_id: ユーザーのID
        """
        print(f"id: {user_id}, limit: {limit}, cursor: {cursor}")
        return self._repo.execute(
            Query(Task).filter_by("user_id", "=", user_id).limit(limit).cursor(cursor)
        )

    def find_task(self, *, id: str) -> "Task":
        return self._repo.get(Task, id=id)

    def create_task(self, *, user_id, title) -> str:
        """新しいタスクを作成します

        :param user_id: 紐付けるユーザーのID
        :param title: タスクのタイトル
        """
        task = Task.new(user_id=user_id, title=title)
        return self._repo.add(task)

    def update_task(self, *, task_id, title):
        """タスクを更新します

        :param task_id: 更新nnnするタスクのID
        :param title: タスクのタイトル
        """
        None

    def start_task(self, *, task_id: str, timestamp):
        """タスクを開始します

        :param task: 開始するタスクのID
        :param timestamp: 開始日時
        """
        with self._repo.transaction():
            task = self._repo.get(Task, id=task_id)
            task, work_time = task.started(timestamp)
            self._repo.put(task)
            self._repo.add(work_time)

    def suspend_task(self, task_id, timestamp):
        None

    def resume_task(self, task_id, timestamp):
        None


class TaskState(StrEnum):
    """タスクの状態"""

    UNSTARTED = auto()
    """未開始"""

    STARTED = auto()
    """開始"""

    SUSPENDED = auto()
    """停止"""

    RESUMED = auto()
    """再開"""

    FINISHED = auto()
    """完了"""


@dataclass
class WorkTime(BaseEntity):
    task_id: str
    id: str
    start: datetime
    end: Optional[datetime]
    created_at: Optional[datetime]
    updated_at: Optional[datetime]

    @classmethod
    def new(cls, task_id, timestamp) -> "WorkTime":
        return WorkTime(
            task_id=task_id,
            id="",
            start=timestamp,
            end=None,
            created_at=None,
            updated_at=None,
        )

    @property
    def duration_in_seconds(self) -> int:
        """start ~ end までの経過時間を返します

        >>> WorkTime(task_id="", id="", start=datetime(2022, 1, 1, 12, 30), end=datetime(2022, 1, 1, 13, 30)).duration_in_seconds
        3600

        end が None の場合は 0 を返します

        >>> WorkTime(task_id="", id="", start=datetime(2022, 1, 1, 12, 30)).duration_in_seconds
        0
        """
        return (self.end - self.start).seconds if self.end is not None else 0

    def to_dict(self):
        return {
            "task_id": self.task_id,
            "id": self.id,
            "start": self.start,
            "end": self.end,
        }


@dataclass
class Task(BaseEntity):
    user_id: str
    id: str
    title: str
    working_time: int
    state: "TaskState"
    created_at: Optional[datetime]
    updated_at: Optional[datetime]

    @classmethod
    def new(cls, *, user_id, title) -> "Task":
        return Task(
            user_id=user_id,
            id="",
            title=title,
            working_time=0,
            state=TaskState.UNSTARTED,
            created_at=None,
            updated_at=None,
        )

    @classmethod
    def from_dict(cls, dic):
        return Task(
            user_id=dic["user_id"],
            id=dic["id"],
            title=dic["title"] or "",
            working_time=dic["working_time"],
            state=TaskState(dic["state"]),
            created_at=dic["created_at"],
            updated_at=dic["updated_at"],
        )

    def started(self, *, timestamp) -> tuple["Task", "WorkTime"]:
        """開始時間を設定したタスクと開始時間を設定したWorkTimeを返します"""
        work_time = WorkTime.new(task_id=self.id, timestamp=timestamp)

        t = deepcopy(self)
        t.state = TaskState.STARTED
        return t, work_time

    def to_dict(self):
        return {
            "user_id": self.user_id,
            "id": self.id,
            "title": self.title,
            "working_time": self.working_time,
            "state": self.state.value,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
        }


if __name__ == "__main__":
    import doctest

    doctest.testmod()
