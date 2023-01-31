"""

"""

from enum import StrEnum, auto
from uuid import uuid4
from functools import reduce
from dataclasses import dataclass, field
from datetime import datetime
from app.repository import select

class TaskService:
    """Service"""

    def __init__(self, repo, user_id):
        self._repo = repo
        self._user_id = user_id


    def task_list(self):
        return self._repo.execute(select(Task).filter_by(user_id=self._user_id))

    def add_new_task(self, user_id, title):
        task = Task.new(user_id=user_id, title=title)
        self._repo.put(task)

    def update_task(self, task_id, title):
        """update task"""
        None

    def start_task(self, task_id, timestamp):
        """start task"""
        work_time = WorkTime.new(task_id=task_id, start=timestamp)
        self._repo.put(wor_time)

    def suspend_task(self, task_id, timestamp):
        """suspend task"""
        None

    def resume_task(self, task_id, timestamp):
        """resume task"""
        None



class TaskState(StrEnum):
    """タスクの状態"""

    UNSTARTED = auto()
    STARTED = auto()
    SUSPENDED = auto()
    RESUMED = auto()
    FINISHED = auto()


@dataclass
class WorkTime:
    """作業時間"""

    task_id: str
    id: str
    start: datetime
    end: datetime = None

    @property
    def duration(self) -> int:
        """作業時間"""

        return self.end - self.start if self.end is not None else 0

    def to_dict(self):
        return {
            "task_id": self.task_id,
            "id": self.id,
            "start": self.start,
            "end": self.end,
        }


@dataclass
class Task:
    """タスク"""

    user_id: str
    id: str
    title: str
    working_time: int
    state: "TaskState"
    records: list[WorkTime] = field(default_factory=list)

    @staticmethod
    def new(user_id, title) -> "Task":
        return Task(user_id=user_id, id="", title=title, working_time=0, state=TaskState.UNSTARTED)

    @staticmethod
    def from_dict(dic) -> "Task":
        return Task(
            user_id=dic["user_id"],
            id=dic["id"],
            title=dic["title"] or "",
            working_time=dic["working_time"],
            state=TaskState(dic["state"]),
        )

    def to_dict(self):
        return {
            "user_id": self.user_id,
            "id": self.id,
            "title": self.title,
            "working_time": self.working_time,
            "state": self.state.value,
        }
