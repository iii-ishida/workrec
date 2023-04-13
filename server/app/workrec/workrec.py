from datetime import datetime
from enum import StrEnum, auto
from typing import NamedTuple, Optional
from uuid import uuid4

from app.workrec.repository import CloudDatastoreRepo


class NotFoundException(Exception):
    pass


class InvalidStateException(Exception):
    pass


class WorkrecClient:
    def __init__(self, *, repo: "CloudDatastoreRepo"):
        self._repo = repo

    def task_list(
        self, *, user_id, limit: Optional[int] = None, cursor: Optional[str] = None
    ) -> tuple[list["Task"], str]:
        """ユーザーに紐づくタスクのリストを返します

        :param user_id: ユーザーのID
        """
        entities, cursor = self._repo.list(
            Task.__name__,
            filters=[("user_id", "=", user_id)],
            limit=limit,
            cursor=cursor,
        )

        cursor = cursor if cursor is not None else ""
        return [Task(**e) for e in entities], cursor

    def find_task(self, *, task_id: str) -> "Task":
        """指定されたタスクを返します

        :param task_id: タスクのID
        """
        e = self._repo.get(Task.__name__, id=task_id)
        return Task(**e)

    def create_task(self, *, user_id, title) -> str:
        """新しいタスクを作成します

        :param user_id: 紐付けるユーザーのID
        :param title: タスクのタイトル
        """
        now = datetime.now()
        task = Task.new(
            user_id=user_id,
            title=title,
        )._replace(
            created_at=now,
            updated_at=now,
        )

        self._repo.add(Task.__name__, id=task.id, entity=task._asdict())

        return task.id

    def update_task(self, *, task_id, title) -> None:
        """タスクを更新します

        :param task_id: 更新するタスクのID
        :param title: タスクのタイトル
        """
        with self._repo.transaction():
            task = self._repo.get(Task.__name__, id=task_id)

            if task is None:
                raise NotFoundException()

            task = Task(**task)
            task = task._replace(title=title, updated_at=datetime.now())
            self._repo.put(Task.__name__, id=task.id, entity=task._asdict())

    def start_work_on_task(self, *, task_id: str, timestamp: datetime) -> None:
        """タスクの作業を開始します

        :param task: 作業を開始するタスクのID
        :param timestamp: 開始日時
        """
        with self._repo.transaction():
            task = self._repo.get(Task.__name__, id=task_id)

            if task is None:
                raise NotFoundException()

            task = Task(**task)
            task, work_time = task.start_work(timestamp)
            self._repo.put(Task.__name__, id=task.id, entity=task._asdict())
            self._repo.add(
                WorkSession.__name__, id=work_time.id, entity=work_time._asdict()
            )

    def stop_work_on_task(self, task_id, timestamp: datetime) -> None:
        """タスクの作業を停止します

        :param task: 作業を停止するタスクのID
        :param timestamp: 停止日時
        """
        with self._repo.transaction():
            task = self._repo.get(Task.__name__, id=task_id)

            if task is None:
                raise NotFoundException()

            task = Task(**task)
            task, work_time = task.pause_work(timestamp)
            self._repo.put(Task.__name__, id=task.id, entity=task._asdict())
            self._repo.put(
                WorkSession.__name__, id=work_time.id, entity=work_time._asdict()
            )

    def complete_task(self, *, task_id: str, timestamp: datetime) -> None:
        """タスクを完了します

        作業中の場合は作業を停止してから完了します

        :param task_id: 完了するタスクのID
        :param timestamp: 完了日時
        """
        with self._repo.transaction():
            task = self._repo.get(Task.__name__, id=task_id)

            if task is None:
                raise NotFoundException()

            task = Task(**task)
            task, work_time = task.complete(timestamp)
            self._repo.put(Task.__name__, id=task.id, entity=task._asdict())
            if work_time:
                self._repo.put(
                    WorkSession.__name__, id=work_time.id, entity=work_time._asdict()
                )


class WorkSession(NamedTuple):
    task_id: str
    id: str
    start_time: datetime = datetime.min
    end_time: datetime = datetime.min
    created_at: datetime = datetime.min
    updated_at: datetime = datetime.min

    @classmethod
    def new(cls, *, task_id: str) -> "WorkSession":
        id = f"{WorkSession.__name__}-{task_id}-{str(uuid4())}"
        return WorkSession(task_id=task_id, id=id)

    @property
    def working_time(self) -> int:
        """作業時間を返します

        >>> WorkSession(task_id="", id="", start_time=datetime(2022, 1, 1, 12, 30), end_time=datetime(2022, 1, 1, 13, 30)).duration_in_seconds
        3600

        end_time が datetime.min の場合は 0 を返します

        >>> WorkSession(task_id="", id="", start_time=datetime(2022, 1, 1, 12, 30)).duration_in_seconds
        0
        """

        start = self.start_time.replace(tzinfo=None)
        end = self.end_time.replace(tzinfo=None)
        return (end - start).seconds if end != datetime.min else 0


class TaskState(StrEnum):
    """タスクの状態"""

    NOT_STARTED = auto()
    """未着手"""

    IN_PROGRESS = auto()
    """作業中"""

    PAUSED = auto()
    """一時停止"""

    COMPLETED = auto()
    """完了"""


class Task(NamedTuple):
    user_id: str
    id: str
    title: str
    total_working_time: int
    state: "TaskState"
    last_work_dict: dict
    created_at: datetime
    updated_at: datetime

    @classmethod
    def new(cls, *, user_id: str, title: str) -> "Task":
        id = f"{Task.__name__}-{str(uuid4())}"
        return Task(
            user_id=user_id,
            id=id,
            title=title,
            state=TaskState.NOT_STARTED,
            total_working_time=0,
            last_work_dict={},
            created_at=datetime.min,
            updated_at=datetime.min,
        )

    @property
    def last_work(self) -> "WorkSession":
        if self.state == TaskState.NOT_STARTED:
            return WorkSession(task_id=self.id, id="")

        return WorkSession(**self.last_work_dict)

    def start_work(self, /, timestamp: datetime) -> tuple["Task", "WorkSession"]:
        """作業中状態にした Task と 開始時間を設定した WorkSession を返します

        :param timestamp: 開始日時
        :raises InvalidStateException: state が NOT_STARTED でない
        """
        if self.state != TaskState.NOT_STARTED and self.state != TaskState.PAUSED:
            raise InvalidStateException(f"state = {self.state}")

        work = WorkSession.new(task_id=self.id)._replace(start_time=timestamp)
        task = self._replace(state=TaskState.IN_PROGRESS, last_work_dict=work._asdict())
        return task, work

    def pause_work(self, /, timestamp: datetime) -> tuple["Task", "WorkSession"]:
        """中断状態にした Task と 終了時間を設定した Work を返します

        :param timestamp: 中断日時
        :raises InvalidStateException: state が IN_PROGRESS でない
        """
        if self.state != TaskState.IN_PROGRESS:
            raise InvalidStateException(f"state = {self.state}")

        work = self.last_work._replace(end_time=timestamp)
        total_working_time = self.total_working_time + work.working_time
        task = self._replace(
            state=TaskState.PAUSED,
            total_working_time=total_working_time,
            last_work_dict=work._asdict(),
        )
        return task, work

    def complete(
        self, /, timestamp: datetime
    ) -> tuple["Task", Optional["WorkSession"]]:
        """完了状態にした Task を返します

        作業中の場合は、作業を終了してから完了状態にします

        :param timestamp: 完了日時
        """
        if self.state == TaskState.IN_PROGRESS:
            task, work = self.pause_work(timestamp=timestamp)
            task = task._replace(state=TaskState.COMPLETED)
            return task, work

        task = self._replace(state=TaskState.COMPLETED)
        return task, None
