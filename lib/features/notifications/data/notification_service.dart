import '../domain/notification_model.dart';

class NotificationService {
  List<NotificationModel> getDummyNotifications() {
    return [
      NotificationModel(
        id: 'n-001',
        title: 'Emergency SOS Signal',
        body: 'SOS Alert confirmed. GPS telemetry sent to closest dispatch terminal.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        category: 'SOS Alerts',
        isRead: false,
      ),
      NotificationModel(
        id: 'n-002',
        title: 'Ride Request Accepted',
        body: 'Driver Alexander (Gold Elite) is en-route in a black Tata Nexon EV. ETA 4 mins.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
        category: 'Ride Updates',
        isRead: false,
      ),
      NotificationModel(
        id: 'n-003',
        title: 'Wallet Balance Refilled',
        body: 'Top-up of ₹10000.00 confirmed via linked Visa Debit Card.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        category: 'Wallet Updates',
        isRead: true,
      ),
      NotificationModel(
        id: 'n-004',
        title: 'Maintenance Booking Active',
        body: 'Diagnostic tuning scheduled at Elite Autoworks Service Center for tomorrow at 10:00 AM.',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        category: 'Booking Updates',
        isRead: true,
      ),
      NotificationModel(
        id: 'n-005',
        title: 'Vehicle Battery Low Warning',
        body: 'Vehicle tracker detected main accessory battery charge dropped below 15%.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Vehicle Alerts',
        isRead: true,
      ),
      NotificationModel(
        id: 'n-006',
        title: 'New Community Thread',
        body: 'A user posted a reply to your question: "Best OBD2 scanners for Nexon EV?"',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Community Alerts',
        isRead: true,
      ),
      NotificationModel(
        id: 'n-007',
        title: 'Service Inspection Report',
        body: 'Periodic engine health diagnostics report is ready. 0 warnings reported.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        category: 'Service Center Alerts',
        isRead: true,
      ),
    ];
  }
}
