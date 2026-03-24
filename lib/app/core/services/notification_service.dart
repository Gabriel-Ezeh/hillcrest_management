import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

/// A service to handle showing in-app notifications (toasts).
/// It wraps the [overlay_support] package to provide a clean, centralized API.
class NotificationService {
  /// Shows a success message at the top of the screen.
  void showSuccess(String message) {
    showSimpleNotification(
      Text(message),
      background: Colors.green,
      position: NotificationPosition.top,
    );
  }

  /// Shows an error message at the top of the screen.
  void showError(String message) {
    showSimpleNotification(
      Text(message),
      background: Colors.red,
      position: NotificationPosition.top,
    );
  }

  /// Shows a generic info message at the top of the screen.
  void showInfo(String message) {
    showSimpleNotification(
      Text(message),
      background: Colors.blue,
      position: NotificationPosition.top,
    );
  }
}
