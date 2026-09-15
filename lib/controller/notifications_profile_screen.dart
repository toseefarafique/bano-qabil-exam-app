import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsProfileScreen extends StatefulWidget {
  const NotificationsProfileScreen({super.key});

  @override
  State<NotificationsProfileScreen> createState() =>
      _NotificationsProfileScreenState();
}

class _NotificationsProfileScreenState
    extends State<NotificationsProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedTab = 0;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _campusController = TextEditingController();

  bool _loadingProfile = true;
  bool _savingProfile = false;

  String _email = '';
  String _photoUrl = '';

  final Color primaryColor = const Color(0xFF6D597A);
  final Color darkColor = const Color(0xFF44364D);
  final Color accentColor = const Color(0xFFDDBEA9);
  final Color backgroundColor = const Color(0xFFF8F4F0);
  final Color textColor = const Color(0xFF332D35);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _batchController.dispose();
    _campusController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() {
        _loadingProfile = false;
      });
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      final data = doc.data();

      setState(() {
        _email = data?['email']?.toString() ?? user.email ?? '';
        _nameController.text =
            data?['name']?.toString() ?? user.displayName ?? '';
        _classController.text = data?['class']?.toString() ?? '';
        _batchController.text = data?['batch']?.toString() ?? '';
        _campusController.text = data?['campus']?.toString() ?? '';
        _photoUrl = data?['photoUrl']?.toString() ?? '';
        _loadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _loadingProfile = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to load profile: $e'),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first.'),
        ),
      );
      return;
    }

    setState(() {
      _savingProfile = true;
    });

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'name': _nameController.text.trim(),
          'email': _email,
          'class': _classController.text.trim(),
          'batch': _batchController.text.trim(),
          'campus': _campusController.text.trim(),
          'photoUrl': _photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _savingProfile = false;
        });
      }
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
      });
    } catch (_) {
      // Ignore if notification is already removed or unavailable.
    }
  }

  Future<void> _markAllNotificationsAsRead() async {
    final user = _auth.currentUser;

    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

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
    if (timestamp == null) {
      return '';
    }

    try {
      DateTime date;

      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else {
        return '';
      }

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

      default:
        return Icons.notifications_outlined;
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            backgroundImage:
            _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
            child: _photoUrl.isEmpty
                ? Icon(
              Icons.person,
              size: 30,
              color: primaryColor,
            )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty
                      ? 'Student'
                      : _nameController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email.isEmpty ? 'Your Profile' : _email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              index: 0,
            ),
          ),
          Expanded(
            child: _tabButton(
              title: 'Profile',
              icon: Icons.person_outline,
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final selected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? Colors.white : textColor,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifications() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Please login first.'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Notifications',
                style: TextStyle(
                  color: darkColor,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _markAllNotificationsAsRead,
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
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
                .where('userId', isEqualTo: user.uid)
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Unable to load notifications.',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                );
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
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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

                  final date = _formatDate(data['createdAt']);

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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : accentColor.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead
                ? Colors.grey.shade200
                : accentColor.withValues(alpha: 0.70),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
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
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: darkColor,
                            fontSize: 16,
                            fontWeight:
                            isRead ? FontWeight.w600 : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
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
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.55),
                        fontSize: 11.5,
                      ),
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
            Icon(
              Icons.notifications_none_rounded,
              size: 70,
              color: primaryColor.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 15),
            Text(
              'No Notifications',
              style: TextStyle(
                color: darkColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'New quizzes, exam reminders and results '
                  'will appear here.',
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

  Widget _buildProfile() {
    if (_loadingProfile) {
      return Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _profilePhoto(),
            const SizedBox(height: 25),
            _profileField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            _profileField(
              controller: _classController,
              label: 'Class',
              icon: Icons.school_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your class';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            _profileField(
              controller: _batchController,
              label: 'Batch',
              icon: Icons.groups_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your batch';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            _profileField(
              controller: _campusController,
              label: 'Campus',
              icon: Icons.location_city_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your campus';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            _profileField(
              controller: TextEditingController(text: _email),
              label: 'Email',
              icon: Icons.email_outlined,
              enabled: false,
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _savingProfile ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: _savingProfile
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _savingProfile ? 'Saving...' : 'Save Changes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilePhoto() {
    return Column(
      children: [
        Container(
          width: 105,
          height: 105,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor.withValues(alpha: 0.35),
            border: Border.all(
              color: primaryColor,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: _photoUrl.isNotEmpty
                ? Image.network(
              _photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: 55,
                  color: primaryColor,
                );
              },
            )
                : Icon(
              Icons.person,
              size: 55,
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Profile Photo',
          style: TextStyle(
            color: darkColor,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Photo URL can be stored using Firebase Storage.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.55),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _profileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: primaryColor,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
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
          'Notifications & Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabButtons(),
          Expanded(
            child: _selectedTab == 0
                ? _buildNotifications()
                : _buildProfile(),
          ),
        ],
      ),
    );
  }
}