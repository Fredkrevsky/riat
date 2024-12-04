import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('UserService', () {
    const String port = '8086';
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

    late final String adminAuthToken;
    late final String employeeAuthToken;

    test('/register, post returns 200 (admin)', () async {
      final http.Response response = await http.post(
        Uri.parse('$host/register'),
        headers: {'Content-Type': 'application/json'},
        body: '{"username": "Admin", "password": "admin123", "role": "admin"}',
      );

      adminAuthToken = jsonDecode(response.body)['auth_token'];

      expect(response.statusCode, 200);
      expect(response.body.contains('"auth_token":"$adminAuthToken"'), isTrue);
    });

    test('/register, post returns 200 (employee)', () async {
      final http.Response response = await http.post(
        Uri.parse('$host/register'),
        headers: {'Content-Type': 'application/json'},
        body: '{"username": "Employee", "password": "emp123", "role": "employee"}',
      );

      employeeAuthToken = jsonDecode(response.body)['auth_token'];

      expect(response.statusCode, 200);
      expect(response.body.contains('"auth_token":"$employeeAuthToken"'), isTrue);
    });

    test('/login, post returns 200 (admin)', () async {
      final http.Response response = await http.post(
        Uri.parse('$host/login'),
        headers: {'Content-Type': 'application/json'},
        body: '{"username": "Admin", "password": "admin123"}',
      );

      expect(response.statusCode, 200);
      expect(response.body.contains('"auth_token":"$adminAuthToken"'), isTrue);
    });

    test('/login, post returns 200 (employee)', () async {
      final http.Response response = await http.post(
        Uri.parse('$host/login'),
        headers: {'Content-Type': 'application/json'},
        body: '{"username": "Employee", "password": "emp123"}',
      );

      expect(response.statusCode, 200);
      expect(response.body.contains('"auth_token":"$employeeAuthToken"'), isTrue);
    });

    test('/user, get returns 200 (admin)', () async {
      final http.Response response = await http.get(
        Uri.parse('$host/user'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': adminAuthToken,
        },
      );

      expect(response.statusCode, 200);
      expect(response.body.contains('"username":"Admin"'), isTrue);
      expect(response.body.contains('"role":"admin"'), isTrue);
    });

    test('/user, get returns 200 (employee)', () async {
      final http.Response response = await http.get(
        Uri.parse('$host/user'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': employeeAuthToken,
        },
      );

      expect(response.statusCode, 200);
      expect(response.body.contains('"username":"Employee"'), isTrue);
      expect(response.body.contains('"role":"employee"'), isTrue);
    });

    test('/login, post returns 404 (invalid credentials)', () async {
      final http.Response response = await http.post(
        Uri.parse('$host/login'),
        headers: {'Content-Type': 'application/json'},
        body: '{"username": "Unknown", "password": "wrong"}',
      );

      expect(response.statusCode, 404);
      expect(response.body, 'Invalid credentials');
    });
  });
}

