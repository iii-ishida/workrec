// Mocks generated by Mockito 5.0.10 from annotations
// in workrec/test/pages/task_list_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:workrec/domain/task_recorder/task_recorder.dart' as _i4;
import 'package:workrec/repository/task_recorder/task_repo.dart' as _i2;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: comment_references
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

/// A class which mocks [TaskListRepo].
///
/// See the documentation for Mockito's code generation for more information.
class MockTaskListRepo extends _i1.Mock implements _i2.TaskListRepo {
  MockTaskListRepo() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get userId =>
      (super.noSuchMethod(Invocation.getter(#userId), returnValue: '')
          as String);
  @override
  _i3.Stream<_i4.TaskRecorder> taskRecorder() =>
      (super.noSuchMethod(Invocation.method(#taskRecorder, []),
              returnValue: Stream<_i4.TaskRecorder>.empty())
          as _i3.Stream<_i4.TaskRecorder>);
  @override
  _i3.Future<void> addNewTask(_i4.TaskRecorder? recorder, String? title) =>
      (super.noSuchMethod(Invocation.method(#addNewTask, [recorder, title]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> recordStartTimeOfTask(
          _i4.TaskRecorder? recorder, String? taskId) =>
      (super.noSuchMethod(
          Invocation.method(#recordStartTimeOfTask, [recorder, taskId]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> recordSuspendTimeOfTask(
          _i4.TaskRecorder? recorder, String? taskId) =>
      (super.noSuchMethod(
          Invocation.method(#recordSuspendTimeOfTask, [recorder, taskId]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> recordResumeTimeOfTask(
          _i4.TaskRecorder? recorder, String? taskId) =>
      (super.noSuchMethod(
          Invocation.method(#recordResumeTimeOfTask, [recorder, taskId]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i3.Future<void>);
}
