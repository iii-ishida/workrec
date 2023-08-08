import unittest
from datetime import datetime
from app.workrec.workrec import WorkrecClient, InvalidParameterException
from app.repo import InMemoryRepo


class TestWorkrecClient(unittest.TestCase):
    def setUp(self):
        self.repo = InMemoryRepo()
        self.client = WorkrecClient(repo=self.repo)

    def test_task_list(self):
        user_id = "some-user"
        self.client.create_task(user_id=user_id, title="some task 01")
        self.client.create_task(user_id=user_id, title="some task 02")
        self.client.create_task(user_id=user_id, title="some task 03")
        self.client.create_task(user_id=user_id, title="some task 04")
        self.client.create_task(user_id="other-user", title="other task")

        entities, cursor = self.client.task_list(user_id=user_id)
        self.assertEqual(len(entities), 4)
        self.assertEqual(cursor, "")

        entities, cursor = self.client.task_list(user_id=user_id, limit=2)
        self.assertEqual(len(entities), 2)
        self.assertNotEqual(cursor, "")

    def test_create_task(self):
        user_id = "some-user"
        title = "some task"
        self.client.create_task(user_id=user_id, title=title)

        entities, _ = self.repo.list("Task")
        self.assertEqual(len(entities), 1)
        self.assertEqual(entities[0]["user_id"], user_id)
        self.assertEqual(entities[0]["title"], title)
        self.assertEqual(entities[0]["state"], "not_started")
        self.assertEqual(entities[0]["total_working_time"], 0)

    def test_start_work_on_task(self):
        user_id = "some-user"
        start_time = datetime(2021, 1, 1, 10, 0)

        task_id = self.client.create_task(user_id=user_id, title="some task 01")
        self.client.start_work_on_task(
            user_id=user_id, task_id=task_id, timestamp=start_time
        )

        task = self.repo.get(kind="Task", id=task_id)

        self.assertEqual(task["state"], "in_progress")
        self.assertEqual(task["last_work_dict"]["user_id"], user_id)
        self.assertEqual(task["last_work_dict"]["task_id"], task_id)
        self.assertEqual(task["last_work_dict"]["start_time"], start_time)

    def test_stop_work_on_task(self):
        uid = "some-user"
        start_time = datetime(2021, 1, 1, 10, 0)
        stop_time = datetime(2021, 1, 1, 12, 0)

        id = self.client.create_task(user_id=uid, title="some task 01")
        self.client.start_work_on_task(user_id=uid, task_id=id, timestamp=start_time)
        self.client.stop_work_on_task(user_id=uid, task_id=id, timestamp=stop_time)

        task = self.repo.get(kind="Task", id=id)

        self.assertEqual(task["state"], "paused")
        self.assertEqual(task["last_work_dict"]["start_time"], start_time)
        self.assertEqual(task["last_work_dict"]["end_time"], stop_time)

    def test_complete_task(self):
        uid = "some-user"
        start_time = datetime(2021, 1, 1, 10, 0)
        stop_time = datetime(2021, 1, 1, 12, 0)

        id = self.client.create_task(user_id=uid, title="some task 01")
        self.client.start_work_on_task(user_id=uid, task_id=id, timestamp=start_time)
        self.client.stop_work_on_task(user_id=uid, task_id=id, timestamp=stop_time)
        self.client.complete_task(user_id=uid, task_id=id, timestamp=datetime.now())

        task = self.repo.get(kind="Task", id=id)

        self.assertEqual(task["state"], "completed")
        self.assertEqual(task["last_work_dict"]["start_time"], start_time)
        self.assertEqual(task["last_work_dict"]["end_time"], stop_time)

    def test_add_work_session(self):
        uid = "some-user"
        start_time = datetime(2021, 1, 1, 10, 0)
        stop_time = datetime(2021, 1, 1, 12, 0)

        id = self.client.create_task(user_id="some-user", title="some task 01")
        self.client.add_work_session(
            user_id=uid, task_id=id, start_time=start_time, end_time=stop_time
        )

        work_sessions, _ = self.repo.list(kind="WorkSession")

        self.assertEqual(len(work_sessions), 1)
        self.assertEqual(work_sessions[0]["start_time"], start_time)
        self.assertEqual(work_sessions[0]["end_time"], stop_time)

        task = self.repo.get(kind="Task", id=id)
        self.assertEqual(task["last_work_dict"]["start_time"], start_time)
        self.assertEqual(task["last_work_dict"]["end_time"], stop_time)
        self.assertEqual(task["total_working_time"], (stop_time - start_time).seconds)

    def test_add_work_session_multiple(self):
        uid = "some-user"
        start_time_1 = datetime(2021, 1, 1, 10, 0)
        stop_time_1 = datetime(2021, 1, 1, 12, 0)
        start_time_2 = datetime(2021, 1, 1, 13, 0)
        stop_time_2 = datetime(2021, 1, 1, 15, 0)

        id = self.client.create_task(user_id=uid, title="some task 01")
        self.client.add_work_session(
            user_id=uid, task_id=id, start_time=start_time_2, end_time=stop_time_2
        )
        self.client.add_work_session(
            user_id=uid, task_id=id, start_time=start_time_1, end_time=stop_time_1
        )

        work_sessions, _ = self.repo.list(kind="WorkSession")

        self.assertEqual(len(work_sessions), 2)

        task = self.repo.get(kind="Task", id=id)
        self.assertEqual(task["last_work_dict"]["start_time"], start_time_2)
        self.assertEqual(task["last_work_dict"]["end_time"], stop_time_2)
        self.assertEqual(
            task["total_working_time"],
            (stop_time_1 - start_time_1).seconds + (stop_time_2 - start_time_2).seconds,
        )

    def test_add_work_session_invalid(self):
        uid = "some-user"
        start_time_1 = datetime(2021, 1, 1, 10, 0)
        stop_time_1 = datetime(2021, 1, 1, 12, 0)
        start_time_2 = datetime(2021, 1, 1, 11, 0)
        stop_time_2 = datetime(2021, 1, 1, 13, 0)

        id = self.client.create_task(user_id=uid, title="some task 01")
        self.client.add_work_session(
            user_id=uid, task_id=id, start_time=start_time_1, end_time=stop_time_1
        )

        with self.assertRaises(InvalidParameterException):
            self.client.add_work_session(
                user_id=uid, task_id=id, start_time=start_time_2, end_time=stop_time_2
            )

    def test_edit_work_session(self):
        uid = "some-user"
        start_time_1 = datetime(2021, 1, 1, 10, 0)
        stop_time_1 = datetime(2021, 1, 1, 12, 0)
        start_time_2 = datetime(2021, 1, 1, 13, 0)
        stop_time_2 = datetime(2021, 1, 1, 15, 0)
        start_time_3 = datetime(2021, 1, 1, 16, 0)
        stop_time_3 = datetime(2021, 1, 1, 18, 0)
        updated_start_time = datetime(2021, 1, 1, 13, 30)
        updated_end_time = datetime(2021, 1, 1, 15, 30)

        id = self.client.create_task(user_id="some-user", title="some task 01")
        self.client.start_work_on_task(user_id=uid, task_id=id, timestamp=start_time_1)
        self.client.stop_work_on_task(user_id=uid, task_id=id, timestamp=stop_time_1)
        self.client.start_work_on_task(user_id=uid, task_id=id, timestamp=start_time_2)
        self.client.stop_work_on_task(user_id=uid, task_id=id, timestamp=stop_time_2)
        self.client.start_work_on_task(user_id=uid, task_id=id, timestamp=start_time_3)
        self.client.stop_work_on_task(user_id=uid, task_id=id, timestamp=stop_time_3)

        work_sessions, _ = self.repo.list(kind="WorkSession")
        work_session_id = work_sessions[1]["id"]
        self.client.edit_work_session(
            user_id=uid,
            work_session_id=work_session_id,
            start_time=updated_start_time,
            end_time=updated_end_time,
        )

        work_sessions, _ = self.repo.list(kind="WorkSession")
        work_session = work_sessions[1]

        self.assertEqual(work_session["start_time"], updated_start_time)
        self.assertEqual(work_session["end_time"], updated_end_time)

        invalid_start_time = datetime(2021, 1, 1, 11, 59)
        with self.assertRaises(InvalidParameterException):
            self.client.edit_work_session(
                user_id=uid,
                work_session_id=work_session_id,
                start_time=invalid_start_time,
                end_time=updated_end_time,
            )

        invalid_end_time = datetime(2021, 1, 1, 18, 1)
        with self.assertRaises(InvalidParameterException):
            self.client.edit_work_session(
                user_id=uid,
                work_session_id=work_session_id,
                start_time=updated_start_time,
                end_time=invalid_end_time,
            )


if __name__ == "__main__":
    unittest.main()
