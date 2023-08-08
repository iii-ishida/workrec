_KindTask = "Task"
_KindWorkSession = "WorkSession"


class WorkrecRepo:
    def __init__(self, repo):
        self._repo = repo

    def task_list(self, user_id, limit, cursor):
        entities, cursor = self._repo.list(
            _KindTask,
            filters=[("user_id", "=", user_id)],
            order=["-created_at"],
            limit=limit,
            cursor=cursor,
        )
        return entities, cursor or ""

    def working_task_list(self, user_id):
        entities, _ = self._repo.list(
            _KindTask,
            filters=[("user_id", "=", user_id), ("state", "=", "in_progress")],
        )
        return entities

    def find_task(self, id):
        return self._repo.get(_KindTask, id=id)

    def put_task(self, task):
        return self._repo.put(_KindTask, task)

    def work_session_list(self, task_id, limit, cursor):
        entities, cursor = self._repo.list(
            _KindWorkSession,
            filters=[("task_id", "=", task_id)],
            order=["start_time"],
            limit=limit,
            cursor=cursor,
        )
        return entities, cursor or ""

    def find_work_session(self, id):
        return self._repo.get(_KindWorkSession, id=id)

    def find_prev_work_session(self, task_id, work_session_id, start_time):
        prev_work_sessions, _ = self._repo.list(
            _KindWorkSession,
            filters=[
                ("task_id", "=", task_id),
                ("end_time", "<=", start_time),
            ],
            order=["task_id", "-end_time"],
            limit=2,
        )
        prev_work_sessions = [
            w for w in prev_work_sessions if w["id"] != work_session_id
        ]
        return prev_work_sessions[0] if prev_work_sessions else None

    def find_next_work_session(self, task_id, work_session_id, start_time):
        next_work_sessions, _ = self._repo.list(
            _KindWorkSession,
            filters=[
                ("task_id", "=", task_id),
                ("end_time", ">=", start_time),
            ],
            order=["task_id", "end_time"],
            limit=2,
        )
        next_work_sessions = [
            w for w in next_work_sessions if w["id"] != work_session_id
        ]
        return next_work_sessions[0] if next_work_sessions else None

    def put_work_session(self, work_session):
        return self._repo.put(_KindWorkSession, work_session)

    def transaction(self):
        return self._repo.transaction()
