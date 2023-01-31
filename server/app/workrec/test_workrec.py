import unittest
from app.workrec import WorkrecClient, CloudDatastoreRepo, Task
from app.workrec.repository import Query


class TestWorkrecClient(unittest.TestCase):
    def setUp(self):
        self.repo = CloudDatastoreRepo()
        self.client = WorkrecClient(repo=self.repo)

    def test_create_task_should_save_a_new_task(self):
        self.client.create_task(user_id="some-user-id", title="some task")

        task = self.repo.execute(Query(Task))[0]
        self.assertNotEqual(task.id, "")
        self.assertEqual(task.user_id, "some-user-id")
        self.assertEqual(task.title, "some task")

    # def test_start_task_should_save_a_new_work_time(self):
    #     self.client.create_task(user_id="some-user-id", title="some task")

    #     work_time = self.repo.execute(Query(WorkTime))[0]
    #     self.assertNotEqual(work_time.id, "")


if __name__ == "__main__":
    unittest.main()
