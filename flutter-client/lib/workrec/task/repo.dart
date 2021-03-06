import './inmemory_repo.dart';

class TaskListRepo extends InmemoryTaskRepo {
  TaskListRepo({required String userId}) : super(userId: userId);
}
