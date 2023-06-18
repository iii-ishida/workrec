import unittest
from datetime import datetime
from app.workrec.workrec import WorkrecClient
from app.workrec.repository import InMemoryRepo


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
        id = self.client.create_task(user_id="some-user", title="some task 01")
        start_time = datetime(2021, 1, 1, 10, 0)
        self.client.start_work_on_task(
            user_id="some-user", task_id=id, timestamp=start_time
        )

        task = self.repo.get(kind="Task", id=id)

        self.assertEqual(task["state"], "in_progress")
        self.assertEqual(task["last_work_dict"]["start_time"], start_time)

    def test_stop_work_on_task(self):
        id = self.client.create_task(user_id="some-user", title="some task 01")
        start_time = datetime(2021, 1, 1, 10, 0)
        stop_time = datetime(2021, 1, 1, 12, 0)

        self.client.start_work_on_task(
            user_id="some-user", task_id=id, timestamp=start_time
        )
        self.client.stop_work_on_task(
            user_id="some-user", task_id=id, timestamp=stop_time
        )

        task = self.repo.get(kind="Task", id=id)

        self.assertEqual(task["state"], "paused")
        self.assertEqual(task["last_work_dict"]["start_time"], start_time)
        self.assertEqual(task["last_work_dict"]["end_time"], stop_time)

    def test_complete_task(self):
        id = self.client.create_task(user_id="some-user", title="some task 01")
        start_time = datetime(2021, 1, 1, 10, 0)
        stop_time = datetime(2021, 1, 1, 12, 0)

        self.client.start_work_on_task(
            user_id="some-user", task_id=id, timestamp=start_time
        )
        self.client.stop_work_on_task(
            user_id="some-user", task_id=id, timestamp=stop_time
        )
        self.client.complete_task(
            user_id="some-user", task_id=id, timestamp=datetime.now()
        )

        task = self.repo.get(kind="Task", id=id)

        self.assertEqual(task["state"], "completed")
        self.assertEqual(task["last_work_dict"]["start_time"], start_time)
        self.assertEqual(task["last_work_dict"]["end_time"], stop_time)


if __name__ == "__main__":
    unittest.main()
