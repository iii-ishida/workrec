import './firestore_repo.dart';

class TaskListRepo extends FirestoreTaskRepo {
  TaskListRepo({required String userId}) : super(userId: userId);
}
