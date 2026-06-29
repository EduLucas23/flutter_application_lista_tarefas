// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:lista_tarefas/models/task_model.dart';

void main() {
  test('TaskModel converts to and from map', () {
    const task = TaskModel(
      id: 1,
      title: 'Estudar Flutter',
      description: 'Praticar CRUD com SQLite',
      isDone: false,
      createdAt: '2026-06-29T12:00:00.000',
    );

    final map = task.toMap();
    final convertedTask = TaskModel.fromMap(map);

    expect(convertedTask.id, 1);
    expect(convertedTask.title, 'Estudar Flutter');
    expect(convertedTask.description, 'Praticar CRUD com SQLite');
    expect(convertedTask.isDone, false);
    expect(convertedTask.createdAt, '2026-06-29T12:00:00.000');
  });
}
