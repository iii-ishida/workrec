from datetime import datetime
from enum import StrEnum, auto
from typing import NamedTuple, Optional
from uuid import uuid4

from app.workrec.repository import CloudDatastoreRepo


class InvalidParameterException(Exception):
    pass


class NotFoundException(Exception):
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
            order=["-created_at"],
            limit=limit,
            cursor=cursor,
        )

        return [Task(**e) for e in entities], cursor or ""

    def find_task(self, *, user_id: str, task_id: str) -> "Task":
        """指定されたタスクを返します

        :param task_id: タスクのID
        """
        return self._get_task(user_id, task_id)

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

    def update_task(self, *, user_id, task_id, title) -> None:
        """タスクを更新します

        :param task_id: 更新するタスクのID
        :param title: タスクのタイトル
        """
        with self._repo.transaction():
            task = self._get_task(user_id, task_id)

            task = task._replace(title=title, updated_at=datetime.now())
            self._repo.put(Task.__name__, id=task.id, entity=task._asdict())

    def start_work_on_task(
        self, *, user_id: str, task_id: str, timestamp: datetime
    ) -> None:
        """タスクの作業を開始します

        :param task: 作業を開始するタスクのID
        :param timestamp: 開始日時
        """
        with self._repo.transaction():
            task = self._get_task(user_id, task_id)

            task, work_session = task.start_work(timestamp)
            self._repo.put(Task.__name__, id=task.id, entity=task._asdict())
            self._repo.add(
                WorkSession.__name__, id=work_session.id, entity=work_session._asdict()
            )

            self._stop_all_works(
                user_id=task.user_id, timestamp=timestamp, exclude=task_id
            )

    def stop_work_on_task(
        self, *, user_id: str, task_id: str, timestamp: datetime
    ) -> None:
        """タスクの作業を停止します

        :param task: 作業を停止するタスクのID
        :param timestamp: 停止日時
        """
        with self._repo.transaction():
            task = self._get_task(user_id, task_id)

            task, work_session = task.pause_work(timestamp)
            self._repo.put(Task.__name__, id=task.id, entity=task._asdict())
            self._repo.put(
                WorkSession.__name__, id=work_session.id, entity=work_session._asdict()
            )

    def complete_task(self, *, user_id, task_id: str, timestamp: datetime) -> None:
        """タスクを完了します

        作業中の場合は作業を停止してから完了します

        :param task_id: 完了するタスクのID
        :param timestamp: 完了日時
        """
        with self._repo.transaction():
            task = self._get_task(user_id, task_id)

            task, work_session = task.complete(timestamp)
            self._repo.put(Task.__name__, id=task.id, entity=task._asdict())
            if work_session:
                self._repo.put(
                    WorkSession.__name__,
                    id=work_session.id,
                    entity=work_session._asdict(),
                )

    def work_session_list(
        self, *, task_id: str, limit: Optional[int] = None, cursor: Optional[str] = None
    ) -> tuple[list["WorkSession"], str]:
        """タスクに紐づく作業のリストを返します

        :param task_id: タスクのID
        """
        entities, cursor = self._repo.list(
            WorkSession.__name__,
            filters=[("task_id", "=", task_id)],
            order=["start_time"],
            limit=limit,
            cursor=cursor,
        )

        return [WorkSession(**e) for e in entities], cursor or ""

    def find_work_session(self, *, user_id: str, work_session_id: str) -> "WorkSession":
        """指定されたWorkSessionを返します

        :param work_session_id: WorkSessionのID
        """
        return self._get_work_session(user_id, work_session_id)

    def add_work_session(
        self, *, user_id: str, task_id: str, start_time: datetime, end_time: datetime
    ) -> str:
        """作業を追加します

        :param task_id: 作業を追加するタスクのID
        :param start_time: 開始日時
        :param end_time: 終了日時
        """
        with self._repo.transaction():
            task = self._get_task(user_id, task_id)

            task, work_session = task.add_work_session(start_time, end_time)

            self._validate_work_session(work_session)

            task = task.update_last_work(work_session)
            self._repo.put(Task.__name__, id=task.id, entity=task._asdict())
            self._repo.add(
                WorkSession.__name__, id=work_session.id, entity=work_session._asdict()
            )

            return work_session.id

    def edit_work_session(
        self,
        *,
        user_id: str,
        work_session_id: str,
        start_time: datetime,
        end_time: datetime,
    ) -> None:
        """作業の開始日時と終了日時を更新します

        :param work_session_id: 更新する作業のID
        :param start_time: 開始日時
        :param end_time: 終了日時
        """
        with self._repo.transaction():
            work_session = self._get_work_session(user_id, work_session_id)
            work_session = work_session._replace(
                start_time=start_time, end_time=end_time
            )

            task = self._get_task(user_id, work_session.task_id)
            if (
                task.last_work.end_time == datetime.min
                and task.last_work.start_time < work_session.end_time
            ):
                raise InvalidParameterException()

            self._validate_work_session(work_session)

            task = task.update_last_work(work_session)
            if task.last_work == work_session:
                self._repo.put(Task.__name__, id=task.id, entity=task._asdict())

            self._repo.put(
                WorkSession.__name__, id=work_session.id, entity=work_session._asdict()
            )

    def _validate_work_session(self, work_session: "WorkSession") -> None:
        prev_work_session = self._get_prev_work_session(work_session)

        if prev_work_session:
            if prev_work_session.is_overlapped(work_session):
                raise InvalidParameterException(
                    f"start_time is invalid: {work_session.start_time}"
                )

        next_work_session = self._get_next_work_session(work_session)

        if next_work_session:
            if next_work_session.is_overlapped(work_session):
                raise InvalidParameterException(
                    f"end_time is invalid: {work_session.end_time}"
                )

    def _get_work_session(self, user_id, id) -> "WorkSession":
        entity = self._repo.get(WorkSession.__name__, id=id)

        if entity is None:
            raise NotFoundException()

        work_session = WorkSession(**entity)

        if work_session.user_id != user_id:
            raise NotFoundException()

        return work_session

    def _get_prev_work_session(self, work_session) -> Optional["WorkSession"]:
        prev_work_sessions, _ = self._repo.list(
            WorkSession.__name__,
            filters=[
                ("task_id", "=", work_session.task_id),
                ("end_time", "<=", work_session.start_time),
            ],
            order=["task_id", "-end_time"],
            limit=2,
        )
        prev_work_sessions = [WorkSession(**w) for w in prev_work_sessions]
        prev_work_sessions = [w for w in prev_work_sessions if w.id != work_session.id]
        return prev_work_sessions[0] if prev_work_sessions else None

    def _get_next_work_session(self, work_session) -> Optional["WorkSession"]:
        next_work_sessions, _ = self._repo.list(
            WorkSession.__name__,
            filters=[
                ("task_id", "=", work_session.task_id),
                ("end_time", ">=", work_session.start_time),
            ],
            order=["task_id", "end_time"],
            limit=2,
        )
        next_work_sessions = [WorkSession(**w) for w in next_work_sessions]
        next_work_sessions = [w for w in next_work_sessions if w.id != work_session.id]
        return next_work_sessions[0] if next_work_sessions else None

    def _get_task(self, user_id, id) -> "Task":
        entity = self._repo.get(Task.__name__, id=id)

        if entity is None:
            raise NotFoundException()

        task = Task(**entity)

        if task.user_id != user_id:
            raise NotFoundException()

        return task

    def _stop_work(self, task, timestamp: datetime) -> None:
        task = Task(**task)
        task, work_time = task.pause_work(timestamp)
        self._repo.put(Task.__name__, id=task.id, entity=task._asdict())
        self._repo.put(
            WorkSession.__name__, id=work_time.id, entity=work_time._asdict()
        )

    def _stop_all_works(self, user_id: str, timestamp: datetime, exclude: str) -> None:
        entities, _ = self._repo.list(
            Task.__name__,
            filters=[("user_id", "=", user_id), ("state", "=", TaskState.IN_PROGRESS)],
        )

        for e in entities:
            task = Task(**e)
            if task.id != exclude:
                self._stop_work(task, timestamp)


class WorkSession(NamedTuple):
    user_id: str
    task_id: str
    id: str
    start_time: datetime = datetime.min
    end_time: datetime = datetime.min
    created_at: datetime = datetime.min
    updated_at: datetime = datetime.min

    @classmethod
    def new(cls, *, user_id: str, task_id: str) -> "WorkSession":
        id = f"{WorkSession.__name__}-{task_id}-{str(uuid4())}"
        return WorkSession(user_id=user_id, task_id=task_id, id=id)

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

    def is_overlapped(self, other) -> bool:
        return self.start_time <= other.end_time and self.end_time >= other.start_time


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
    def is_started(self) -> bool:
        return self.state != TaskState.NOT_STARTED

    @property
    def last_work(self) -> "WorkSession":
        if not self.is_started:
            return WorkSession(user_id=self.user_id, task_id=self.id, id="")

        return WorkSession(**self.last_work_dict)

    def update_last_work(self, work_session) -> "Task":
        if self.last_work.end_time <= work_session.start_time:
            return self._replace(last_work_dict=work_session._asdict())

        return self

    def start_work(self, /, timestamp: datetime) -> tuple["Task", "WorkSession"]:
        """作業中状態にした Task と 開始時間を設定した WorkSession を返します

        :param timestamp: 開始日時
        :raises InvalidStateException: state が NOT_STARTED でない
        """
        if self.state != TaskState.NOT_STARTED and self.state != TaskState.PAUSED:
            raise InvalidParameterException(f"state = {self.state}")

        work = WorkSession.new(user_id=self.user_id, task_id=self.id)._replace(
            start_time=timestamp
        )
        task = self._replace(state=TaskState.IN_PROGRESS, last_work_dict=work._asdict())
        return task, work

    def pause_work(self, /, timestamp: datetime) -> tuple["Task", "WorkSession"]:
        """中断状態にした Task と 終了時間を設定した Work を返します

        :param timestamp: 中断日時
        :raises InvalidStateException: state が IN_PROGRESS でない
        """
        if self.state != TaskState.IN_PROGRESS:
            raise InvalidParameterException(f"state = {self.state}")

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

    def add_work_session(
        self, /, start_time: datetime, end_time: datetime
    ) -> tuple["Task", "WorkSession"]:
        """WorkSession を追加した Task を返します

        :param work: 追加する WorkSession
        """
        work = WorkSession.new(user_id=self.user_id, task_id=self.id)._replace(
            start_time=start_time, end_time=end_time
        )

        if (
            self.is_started
            and self.last_work.end_time == datetime.min
            and self.last_work.start_time < work.end_time
        ):
            raise InvalidParameterException()

        task = self._replace(
            total_working_time=self.total_working_time + work.working_time
        )

        if not self.is_started:
            task = task._replace(state=TaskState.PAUSED, last_work_dict=work._asdict())
        elif self.last_work.end_time <= work.start_time:
            task = task._replace(last_work_dict=work._asdict())

        return task, work
