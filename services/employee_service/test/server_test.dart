import 'dart:io';

import 'package:core/core.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('EmployeeManagementService', () {
    const String port = '8084';
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

    test('/employee, post returns 200', () async {
      final http.Response response = await http.post(
        Uri.parse('$host/employee'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': AuthToken.test$,
        },
        body: '{"employeeId": "1", "name": "John Doe", "position": "Developer", "salary": 70000.0}',
      );

      expect(response.statusCode, 200);
      expect(response.body, 'Employee added successfully');
    });

    test('/employee, get returns 200', () async {
      final http.Response response = await http.get(
        Uri.parse('$host/employee?employeeId=1'),
        headers: <String, String>{
          'Authorization': AuthToken.test$,
        },
      );

      expect(response.statusCode, 200);
      expect(response.body.contains('"employeeId":"1"'), isTrue);
      expect(response.body.contains('"name":"John Doe"'), isTrue);
      expect(response.body.contains('"position":"Developer"'), isTrue);
      expect(response.body.contains('"salary":70000.0'), isTrue);
    });
  });
}

