import 'package:bluebubbles/services/backend/notifications/desktop_notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_io/io.dart';

class MockFlutterLocalNotificationsPlugin extends Fake implements FlutterLocalNotificationsPlugin {
  bool cancelCalled = false;
  bool cancelAllCalled = false;
  bool getActiveNotificationsCalled = false;

  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelCalled = true;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalled = true;
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    getActiveNotificationsCalled = true;
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    DesktopNotifications.registerPlugin(mockPlugin);
  });

  group('DesktopNotifications macOS Bypass Tests', () {
    test('activeIds returns empty list early on macOS/Linux without calling plugin IPC', () async {
      final active = await DesktopNotifications.activeIds();
      expect(active, isEmpty);
      if (Platform.isMacOS || Platform.isLinux) {
        expect(mockPlugin.getActiveNotificationsCalled, isFalse);
      }
    });

    test('cancel clears callback map and bypasses plugin cancel on macOS', () async {
      const int testId = 1234;
      await DesktopNotifications.cancel(testId);
      expect(DesktopNotifications.isLive(testId), isFalse);
      if (Platform.isMacOS) {
        expect(mockPlugin.cancelCalled, isFalse);
      }
    });

    test('cancelAll clears callbacks and bypasses plugin cancelAll on macOS', () async {
      await DesktopNotifications.cancelAll();
      if (Platform.isMacOS) {
        expect(mockPlugin.cancelAllCalled, isFalse);
      }
    });
  });
}
