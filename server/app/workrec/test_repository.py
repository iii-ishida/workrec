import unittest
from app.workrec.repository import Query
from app.workrec.workrec import Task


class TestCloudDatastoreRepo(unittest.TestCase):
    def test_new_Query(self):
        query = Query(Task)
        self.assertEqual(
            query.to_datastore_query_param(), {"kind": "Task", "filters": []}
        )

    def test_filter_by(self):
        query = Query(Task)
        filter_query = query.filter_by("user_id", "=", "some-user-id").filter_by(
            "order", ">", 10
        )

        self.assertNotEqual(query, filter_query)
        self.assertEqual(
            filter_query.to_datastore_query_param(),
            {
                "kind": "Task",
                "filters": [
                    ("user_id", "=", "some-user-id"),
                    ("order", ">", 10),
                ],
            },
        )


if __name__ == "__main__":
    unittest.main()
