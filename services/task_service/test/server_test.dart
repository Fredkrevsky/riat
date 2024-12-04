import 'dart:io';

import 'package:core/core.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('TaskAssignmentService', () {
    const String port = '8081';
    const String host = 'http://localhost:$port';
    late final Process process;

    setUpAll(() async {
      process = await Process.start(
        'dart',
        ['run', 'bin/server.dart'],
        environment: {'PORT': port},
      );

      await process.stdout.first;
    });

    tearDownAll(() {
      process.kill();
    });

    test('/tasks, post returns 200', () async {
      final http.Response response = await http.post(
        Uri.parse('$host/tasks'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': AuthToken.test$,
        },
        body: '{"taskId": "1", "description": "Complete project report"}',
      );

      expect(response.statusCode, 200);
      expect(response.body, 'Task assigned successfully');
    });

    test('/tasks, get returns 200', () async {
      final http.Response response = await http.get(
        Uri.parse('$host/tasks'),
        headers: <String, String>{
          'Authorization': AuthToken.test$,
        },
      );

      expect(response.statusCode, 200);
      expect(response.body.contains('"taskId":"1"'), isTrue);
      expect(response.body.contains('"description":"Complete project report"'), isTrue);
    });

    test('/tasks, post returns 400 (taskId missing)', () async {
      final http.Response response = await http.post(
        Uri.parse('$host/tasks'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': AuthToken.test$,
        },
        body: '{"description": "Complete project report"}', // Missing "taskId"
      );
      expect(response.statusCode, 400);
      expect(response.body, 'Invalid data format');
    });

    test('/tasks, post returns 400 (description missing)', () async {
      final http.Response response = await http.post(
        Uri.parse('$host/tasks'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': AuthToken.test$,
        },
        body: '{"taskId": "1"}', // Missing "description"
      );
      expect(response.statusCode, 400);
      expect(response.body, 'Invalid data format');
    });
  });
}

