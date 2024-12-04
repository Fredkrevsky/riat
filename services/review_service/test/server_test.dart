import 'dart:io';

import 'package:core/core.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('PerformanceReviewService', () {
    const String port = '8085';
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

    test('/review, post returns 200', () async {
      final http.Response response = await http.post(
        Uri.parse('$host/review'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': AuthToken.test$,
        },
        body: '{"employeeId": "123", "rating": 5, "comment": "Excellent performance!"}',
      );

      expect(response.statusCode, 200);
      expect(response.body, 'Performance review added successfully');
    });

    test('/review, get returns 200', () async {
      final http.Response response = await http.get(
        Uri.parse('$host/review?employeeId=123'),
        headers: <String, String>{
          'Authorization': AuthToken.test$,
        },
      );

      expect(response.statusCode, 200);
      expect(response.body.contains('"employeeId":"123"'), isTrue);
      expect(response.body.contains('"rating":5'), isTrue);
      expect(response.body.contains('"comment":"Excellent performance!"'), isTrue);
    });
  });
}

