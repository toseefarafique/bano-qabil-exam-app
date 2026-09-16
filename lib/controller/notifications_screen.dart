import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Color primaryColor = const Color(0xFF6D597A);
  final Color darkColor = const Color(0xFF44364D);
  final Color accentColor = const Color(0xFFDDBEA9);
  final Color backgroundColor = const Color(0xFFF8F4F0);
  final Color textColor = const Color(0xFF332D35);

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllNotificationsAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All notifications are already read.'),
            ),
          );
        }
        return;
      }

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to update notifications: $e'),
          ),
        );
      }
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null || timestamp is! Timestamp) {
      return '';
    }

    try {
      final date = timestamp.toDate();

      final hour = date.hour > 12
          ? date.hour - 12
          : date.hour == 0
          ? 12
          : date.hour;

      final minute = date.minute.toString().padLeft(2, '0');

      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '${date.day}/${date.month}/${date.year} '
          '$hour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  IconData _notificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
      case 'new_quiz':
        return Icons.quiz_outlined;

      case 'reminder':
      case 'exam_reminder':
        return Icons.alarm_outlined;

      case 'result':
      case 'result_published':
        return Icons.emoji_events_outlined;

      case 'closed':
      case 'quiz_closed':
      case 'exam_closed':
        return Icons.lock_outline_rounded;

      default:
        return Icons.notifications_outlined;
    }
  }

  Widget _buildUserNotifications(User user) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Notifications',
                      style: TextStyle(
                        color: darkColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stay updated with your exams and results.',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.60),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _markAllNotificationsAsRead(user.uid);
                },
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection('notifications')
                .where(
              'userId',
              isEqualTo: user.uid,
            )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              if (snapshot.hasError) {
                return _errorState();
              }

              final notifications = snapshot.data?.docs ?? [];

              if (notifications.isEmpty) {
                return _emptyNotifications();
              }

              notifications.sort((a, b) {
                final aTime = a.data()['createdAt'];
                final bTime = b.data()['createdAt'];

                if (aTime is Timestamp && bTime is Timestamp) {
                  return bTime.compareTo(aTime);
                }

                return 0;
              });

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  5,
                  20,
                  25,
                ),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final doc = notifications[index];
                  final data = doc.data();

                  final title =
                      data['title']?.toString() ?? 'Notification';

                  final message =
                      data['message']?.toString() ??
                          data['body']?.toString() ??
                          '';

                  final type =
                      data['type']?.toString() ?? 'notification';

                  final isRead = data['isRead'] == true;

                  final date = _formatDate(
                    data['createdAt'],
                  );

                  return _notificationCard(
                    notificationId: doc.id,
                    title: title,
                    message: message,
                    type: type,
                    isRead: isRead,
                    date: date,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _notificationCard({
    required String notificationId,
    required String title,
    required String message,
    required String type,
    required bool isRead,
    required String date,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isRead) {
          _markNotificationAsRead(notificationId);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.white
              : accentColor.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead
                ? Colors.grey.shade200
                : accentColor.withValues(alpha: 0.75),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _notificationIcon(type),
                color: primaryColor,
                size: 25,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: darkColor,
                            fontSize: 16,
                            fontWeight: isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                          ),
                        ),
                      ),

                      if (!isRead)
                        Container(
                          margin: const EdgeInsets.only(
                            top: 5,
                            left: 8,
                          ),
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.75),
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ],

                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: textColor.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.55),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyNotifications() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 55,
                color: primaryColor.withValues(alpha: 0.65),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'No Notifications',
              style: TextStyle(
                color: darkColor,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'New quizzes, exam reminders and results '
                  'will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.65),
                height: 1.5,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginRequiredState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 70,
              color: primaryColor.withValues(alpha: 0.55),
            ),

            const SizedBox(height: 15),

            Text(
              'Please Login First',
              style: TextStyle(
                color: darkColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'You need to be logged in to view your notifications.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.65),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: primaryColor.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 15),
            Text(
              'Unable to load notifications.',
              style: TextStyle(
                color: darkColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          final user = snapshot.data;

          if (user == null) {
            return _loginRequiredState();
          }

          return _buildUserNotifications(user);
        },
      ),
    );
  }
}