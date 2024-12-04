import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../lib/performance_review.dart';

final Router _router = Router()
  ..get('/review', _handleReviewGetRequest)
  ..post('/review', _handleReviewPostRequest);

Future<void> main() async {
  final HttpServer server = await serve(
    Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(authRequests())
        .addHandler(_router),
    InternetAddress.anyIPv4,
    int.parse(Platform.environment['PORT'] ?? '8085'),
  );

  print('PerformanceReviewService running on ${server.address.host}:${server.port}');
}

Future<Response> _handleReviewGetRequest(Request request) async {
  final String? employeeId = request.url.queryParameters['employeeId'];

  if (employeeId == null) return Response.badRequest(body: 'Missing employeeId');

  final List<PerformanceReview> reviews = reviewsByEmployeeId[employeeId] ?? <PerformanceReview>[];

  return Response.ok(
    jsonEncode(reviews),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> _handleReviewPostRequest(Request request) async {
  final String body = await request.readAsString();
  final Map<String, Object?> json = jsonDecode(body);

  if (json case {'employeeId': String employeeId, 'rating': int rating, 'comment': String comment}) {
    final PerformanceReview review = PerformanceReview(employeeId, rating, comment);

    reviewsByEmployeeId.update(
      employeeId,
      (List<PerformanceReview> reviews) => reviews..add(review),
      ifAbsent: () => <PerformanceReview>[review],
    );

    return Response.ok('Performance review added successfully');
  }

  return Response.badRequest(body: 'Invalid data format');
}

