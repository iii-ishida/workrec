import unittest
from app.repo import InMemoryRepo


class TestInMemoryRepo(unittest.TestCase):
    def setUp(self):
        self.repo = InMemoryRepo()

    def test_list(self):
        self.repo.put(
            "Task",
            {
                "id": "1",
                "title": "Task 1",
                "completed": False,
            },
        )
        self.repo.put(
            "Task",
            {
                "id": "2",
                "title": "Task 3",
                "completed": True,
            },
        )
        self.repo.put(
            "Task",
            {
                "id": "3",
                "title": "Task 2",
                "completed": False,
            },
        )

        # Test listing all entities
        entities, cursor = self.repo.list("Task")
        self.assertEqual(len(entities), 3)
        self.assertEqual(cursor, "")

        # Test filtering entities
        entities, cursor = self.repo.list("Task", filters=[("completed", "=", False)])
        self.assertEqual(len(entities), 2)
        self.assertEqual(entities[0]["id"], "1")
        self.assertEqual(entities[1]["id"], "3")
        self.assertEqual(cursor, "")

        # Test sorting entities
        entities, cursor = self.repo.list("Task", order=["title"])
        self.assertEqual(len(entities), 3)
        self.assertEqual(entities[0]["id"], "1")
        self.assertEqual(entities[1]["id"], "3")
        self.assertEqual(entities[2]["id"], "2")

        # Test limiting the number of entities returned
        entities, cursor = self.repo.list("Task", limit=2)
        self.assertEqual(len(entities), 2)

        # Test returning entities after the specified cursor
        entities, cursor = self.repo.list("Task", cursor="1")
        self.assertEqual(len(entities), 2)
        self.assertEqual(entities[0]["id"], "2")
        self.assertEqual(entities[1]["id"], "3")
        self.assertEqual(cursor, "")

    def test_get(self):
        self.repo.put(
            "Task",
            {
                "id": "1",
                "title": "Task 1",
                "completed": False,
            },
        )

        # Test getting an existing entity
        entity = self.repo.get("Task", id="1")
        self.assertEqual(entity["id"], "1")
        self.assertEqual(entity["title"], "Task 1")
        self.assertEqual(entity["completed"], False)

        # Test getting a non-existing entity
        entity = self.repo.get("Task", id="2")
        self.assertIsNone(entity)

    def test_add(self):
        self.repo.put(
            "Task",
            {
                "id": "1",
                "title": "Task 1",
                "completed": False,
            },
        )

        # Test adding an entity
        entity = self.repo.get("Task", id="1")
        self.assertEqual(entity["id"], "1")
        self.assertEqual(entity["title"], "Task 1")
        self.assertEqual(entity["completed"], False)

    def test_put(self):
        self.repo.put(
            "Task",
            {
                "id": "1",
                "title": "Task 1",
                "completed": False,
            },
        )

        # Test updating an existing entity
        self.repo.put(
            "Task",
            {
                "id": "1",
                "title": "Updated Task",
                "completed": True,
            },
        )
        entity = self.repo.get("Task", id="1")
        self.assertEqual(entity["id"], "1")
        self.assertEqual(entity["title"], "Updated Task")
        self.assertEqual(entity["completed"], True)


if __name__ == "__main__":
    unittest.main()
