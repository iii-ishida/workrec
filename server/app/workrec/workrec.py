from datetime import datetime
from enum import StrEnum, auto
from typing import NamedTuple, Optional
from uuid import uuid4

from app.repo import CloudDatastoreRepo
from app.workrec.workrec_repo import WorkrecRepo


class InvalidParameterException(Exception):
    pass


class NotFoundException(Exception):
    pass


class WorkrecClient:
    def __init__(self, *, repo: "CloudDatastoreRepo"):
        self._repo = WorkrecRepo(repo)

    def task_list(
        self,
        *,
        user_id,
        limit: Optional[int] = None,
        cursor: Optional[str] = None,
    ) -> tuple[list["Task"], str]:
        entities, cursor = self._repo.task_list(user_id, limit, cursor)
        return [Task(**e) for e in entities], cursor

    def find_task(self, *, user_id: str, task_id: str) -> "Task":
        return self._find_task(user_id, task_id)

    def create_task(self, *, user_id, title) -> str:
        task = Task.new(user_id=user_id, title=title)
        self._repo.put_task(task._asdict())
        return task.id

    def update_task(self, *, user_id, task_id, title) -> None:
        with self._repo.transaction():
            task = self._find_task(user_id, task_id)
            task = task.update(title=title)
            self._repo.put_task(task._asdict())

    def start_work_on_task(
        self,
        *,
        user_id: str,
        task_id: str,
        timestamp: datetime,
    ) -> None:
        with self._repo.transaction():
            task = self._find_task(user_id, task_id)
            task, work_session = task.start_work(timestamp)
            self._repo.put_task(task._asdict())
            self._repo.put_work_session(work_session._asdict())

            self._stop_all_works(
                user_id=task.user_id, timestamp=timestamp, exclude=task_id
            )

    def stop_work_on_task(
        self,
        *,
        user_id: str,
        task_id: str,
        timestamp: datetime,
    ) -> None:
        with self._repo.transaction():
            task = self._find_task(user_id, task_id)
            task, work_session = task.pause_work(timestamp)
            self._repo.put_task(task._asdict())
            self._repo.put_work_session(work_session._asdict())

    def complete_task(self, *, user_id, task_id: str, timestamp: datetime) -> None:
        with self._repo.transaction():
            task = self._find_task(user_id, task_id)
            task, work_session = task.complete(timestamp)
            self._repo.put_task(task._asdict())
            if work_session is not None:
                self._repo.put_work_session(work_session._asdict())

    def work_session_list(
        self,
        *,
        task_id: str,
        limit: Optional[int] = None,
        cursor: Optional[str] = None,
    ) -> tuple[list["WorkSession"], str]:
        entities, cursor = self._repo.work_session_list(task_id, limit, cursor)
        return [WorkSession(**e) for e in entities], cursor

    def find_work_session(self, *, user_id: str, work_session_id: str) -> "WorkSession":
        return self._get_work_session(user_id, work_session_id)

    def add_work_session(
        self,
        *,
        user_id: str,
        task_id: str,
        start_time: datetime,
        end_time: datetime,
    ) -> str:
        with self._repo.transaction():
            task = self._find_task(user_id, task_id)
            task, work_session = task.add_work_session(start_time, end_time)

            self._validate_work_session(work_session)

            task = task.update_last_work(work_session)
            self._repo.put_task(task._asdict())
            self._repo.put_work_session(work_session._asdict())
            return work_session.id

    def edit_work_session(
        self,
        *,
        user_id: str,
        work_session_id: str,
        start_time: datetime,
        end_time: datetime,
    ) -> None:
        with self._repo.transaction():
            work_session = self._get_work_session(user_id, work_session_id)
            work_session = work_session._replace(
                start_time=start_time, end_time=end_time
            )

            task = self._find_task(user_id, work_session.task_id)
            if (
                task.last_work.end_time == datetime.min
                and task.last_work.start_time < work_session.end_time
            ):
                raise InvalidParameterException()

            self._validate_work_session(work_session)

            task = task.update_last_work(work_session)
            if task.last_work == work_session:
                self._repo.put_task(task._asdict())

            self._repo.put_work_session(work_session._asdict())

    def _validate_work_session(self, work_session: "WorkSession") -> None:
        prev_work_session = self._repo.find_prev_work_session(
            work_session.task_id,
            work_session.id,
            work_session.start_time,
        )

        if prev_work_session:
            prev_work_session = WorkSession(**prev_work_session)
            if prev_work_session.is_overlapped(work_session):
                raise InvalidParameterException(
                    f"start_time is invalid: {work_session.start_time}"
                )

        next_work_session = self._repo.find_next_work_session(
            work_session.task_id,
            work_session.id,
            work_session.start_time,
        )

        if next_work_session:
            next_work_session = WorkSession(**next_work_session)
            if next_work_session.is_overlapped(work_session):
                raise InvalidParameterException(
                    f"end_time is invalid: {work_session.end_time}"
                )

    def _get_work_session(self, user_id, id) -> "WorkSession":
        entity = self._repo.find_work_session(id)

        if entity is None:
            raise NotFoundException()

        work_session = WorkSession(**entity)

        if work_session.user_id != user_id:
            raise NotFoundException()

        return work_session

    def _find_task(self, user_id, id) -> "Task":
        entity = self._repo.find_task(id)

        if entity is None:
            raise NotFoundException()

        task = Task(**entity)

        if task.user_id != user_id:
            raise NotFoundException()

        return task

    def _stop_work(self, task, timestamp: datetime) -> None:
        task = Task(**task)
        task, work_time = task.pause_work(timestamp)
        self._repo.put_task(task._asdict())
        self._repo.put_work_session(work_time._asdict())

    def _stop_all_works(self, user_id: str, timestamp: datetime, exclude: str) -> None:
        entities = self._repo.working_task_list(user_id)

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
        now = datetime.now()
        return Task(
            user_id=user_id,
            id=id,
            title=title,
            state=TaskState.NOT_STARTED,
            total_working_time=0,
            last_work_dict={},
            created_at=now,
            updated_at=now,
        )

    @property
    def is_started(self) -> bool:
        return self.state != TaskState.NOT_STARTED

    @property
    def last_work(self) -> "WorkSession":
        if not self.is_started:
            return WorkSession(user_id=self.user_id, task_id=self.id, id="")

        return WorkSession(**self.last_work_dict)

    def update(self, *, title: str) -> "Task":
        return self._replace(title=title)

    def update_last_work(self, work_session) -> "Task":
        if self.last_work.end_time <= work_session.start_time:
            return self._replace(last_work_dict=work_session._asdict())

        return self

    def start_work(self, /, timestamp: datetime) -> tuple["Task", "WorkSession"]:
        if self.state != TaskState.NOT_STARTED and self.state != TaskState.PAUSED:
            raise InvalidParameterException(f"state = {self.state}")

        work = WorkSession.new(user_id=self.user_id, task_id=self.id)._replace(
            start_time=timestamp
        )
        task = self._replace(state=TaskState.IN_PROGRESS, last_work_dict=work._asdict())
        return task, work

    def pause_work(self, /, timestamp: datetime) -> tuple["Task", "WorkSession"]:
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
        if self.state == TaskState.IN_PROGRESS:
            task, work = self.pause_work(timestamp=timestamp)
            task = task._replace(state=TaskState.COMPLETED)
            return task, work

        task = self._replace(state=TaskState.COMPLETED)
        return task, None

    def add_work_session(
        self, /, start_time: datetime, end_time: datetime
    ) -> tuple["Task", "WorkSession"]:
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
