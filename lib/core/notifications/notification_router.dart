import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import 'notification_constants.dart';

/// Handles notification-tap payloads and routes the user to the correct screen.
class NotificationRouter {
  NotificationRouter._();

  /// Call from the `onDidReceiveNotificationResponse` callback.
  ///
  /// [payload] is expected to be a JSON string like `{"route": "/add-expense"}`.
  static void handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final route = data[NotificationConstants.payloadRouteKey] as String?;
      if (route == null || route.isEmpty) return;

      final context = AppRouter.rootNavigatorKey.currentContext;
      if (context == null) {
        debugPrint('[NotificationRouter] no navigator context — skipping $route');
        return;
      }

      GoRouter.of(context).push(route);
      debugPrint('[NotificationRouter] navigated to $route');
    } catch (e) {
      debugPrint('[NotificationRouter] failed to parse payload: $e');
    }
  }

  /// Build a JSON payload string for a given [route].
  static String buildPayload(String route) {
    return jsonEncode({NotificationConstants.payloadRouteKey: route});
  }
}
