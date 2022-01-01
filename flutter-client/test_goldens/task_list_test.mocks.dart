// Mocks generated by Mockito 5.0.16 from annotations
// in workrec_app/test_goldens/task_list_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:workrec_app/workrec_client/models/task.dart' as _i2;
import 'package:workrec_app/workrec_client/workrec_client.dart' as _i3;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeTask_0 extends _i1.Fake implements _i2.Task {}

/// A class which mocks [WorkrecClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockWorkrecClient extends _i1.Mock implements _i3.WorkrecClient {
  MockWorkrecClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.Task> findTaskById(String? taskId) =>
      (super.noSuchMethod(Invocation.method(#findTaskById, [taskId]),
              returnValue: Future<_i2.Task>.value(_FakeTask_0()))
          as _i4.Future<_i2.Task>);
  @override
  _i4.Stream<_i2.Task> currentTaskStream() =>
      (super.noSuchMethod(Invocation.method(#currentTaskStream, []),
          returnValue: Stream<_i2.Task>.empty()) as _i4.Stream<_i2.Task>);
  @override
  _i4.Stream<List<_i2.Task>> tasksStream() =>
      (super.noSuchMethod(Invocation.method(#tasksStream, []),
              returnValue: Stream<List<_i2.Task>>.empty())
          as _i4.Stream<List<_i2.Task>>);
  @override
  _i4.Future<void> addNewTask(
          {String? title, String? description, int? estimatedTime}) =>
      (super.noSuchMethod(
          Invocation.method(#addNewTask, [], {
            #title: title,
            #description: description,
            #estimatedTime: estimatedTime
          }),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<void> startTask(String? taskId, DateTime? timestamp) =>
      (super.noSuchMethod(Invocation.method(#startTask, [taskId, timestamp]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<void> suspendTask(String? taskId, DateTime? timestamp) =>
      (super.noSuchMethod(Invocation.method(#suspendTask, [taskId, timestamp]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<void> resumeTask(String? taskId, DateTime? timestamp) =>
      (super.noSuchMethod(Invocation.method(#resumeTask, [taskId, timestamp]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  String toString() => super.toString();
}
