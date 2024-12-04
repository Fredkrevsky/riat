import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../lib/task.dart';

final Router _router = Router()
  ..get('/tasks', _handleTaskGetRequest)
  ..post('/tasks', _handleTaskPostRequest);

Future<void> main() async {
  final HttpServer server = await serve(
    Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(authRequests())
        .addHandler(_router),
    InternetAddress.anyIPv4,
    int.parse(Platform.environment['PORT'] ?? '8081'),
  );

  print('TaskAssignmentService running on ${server.address.host}:${server.port}');
}

Future<Response> _handleTaskGetRequest(Request request) async {
  final String userId = request.context['userId'] as String;

  final TaskList tasks = tasksByUserId[userId] ??= TaskList.empty();

  return Response.ok(
    jsonEncode(tasks.items),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
  );
}

Future<Response> _handleTaskPostRequest(Request request) async {
  final String userId = request.context['userId'] as String;

  final String body = await request.readAsString();
  final Map<String, Object?> json = jsonDecode(body);

  if (json case {'taskId': String taskId, 'description': String description}) {
    final TaskItem task = TaskItem(taskId, description);

    tasksByUserId.update(
      userId,
      (TaskList tasks) => tasks..items.add(task),
      ifAbsent: () => TaskList(<TaskItem>[task]),
    );

    return Response.ok('Task assigned successfully');
  }

  return Response.badRequest(body: 'Invalid data format');
}

