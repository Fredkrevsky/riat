import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../lib/employee.dart';

final Router _router = Router()
  ..get('/employee', _handleEmployeeGetRequest)
  ..post('/employee', _handleEmployeePostRequest);

Future<void> main() async {
  final HttpServer server = await serve(
    Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(authRequests())
        .addHandler(_router),
    InternetAddress.anyIPv4,
    int.parse(Platform.environment['PORT'] ?? '8084'),
  );

  print('EmployeeManagementService running on ${server.address.host}:${server.port}');
}

Future<Response> _handleEmployeeGetRequest(Request request) async {
  final String? employeeId = request.url.queryParameters['employeeId'];

  if (employeeId == null) return Response.badRequest(body: 'Missing employeeId');

  final Employee? employee = employeeById[employeeId];

  if (employee == null) return Response.notFound('Employee not found');

  return Response.ok(
    jsonEncode(employee),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> _handleEmployeePostRequest(Request request) async {
  final String body = await request.readAsString();
  final Map<String, Object?> json = jsonDecode(body);

  if (json case {'employeeId': String employeeId, 'name': String name, 'position': String position, 'salary': double salary}) {
    employeeById[employeeId] = Employee(employeeId, name, position, salary);

    return Response.ok('Employee added successfully');
  }

  return Response.badRequest(body: 'Invalid data format');
}

