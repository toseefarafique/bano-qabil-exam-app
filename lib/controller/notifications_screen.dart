import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ControllerNotificationsScreen extends StatefulWidget {
  const ControllerNotificationsScreen({super.key});

  @override
  State<ControllerNotificationsScreen> createState() =>
      _ControllerNotificationsScreenState();
}

class _ControllerNotificationsScreenState
    extends State<ControllerNotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedQuizId;
  String _selectedNotificationType = 'new_quiz';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isSending = false;

  final Color primaryColor = const Color(0xFF6D597A);
  final Color darkColor = const Color(0xFF44364D);
  final Color accentColor = const Color(0xFFDDBEA9);
  final Color backgroundColor = const Color(0xFFF8F4F0);
  final Color textColor = const Color(0xFF332D35);

  @override
  void initState() {
    super.initState();

    _titleController.text = 'New Quiz Available';
    _messageController.text =
        'A new quiz is now available. Open the app to start practicing.';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // LOAD ONLY THE THREE REQUIRED QUIZZES
  // ------------------------------------------------------------

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _loadQuizzes() async {
    const quizIds = ['quiz001', 'quiz002', 'quiz003'];

    final results = await Future.wait(
      quizIds.map((id) => _firestore.collection('quizzes').doc(id).get()),
    );

    return results.where((quiz) => quiz.exists).toList();
  }

  // ------------------------------------------------------------
  // QUIZ TITLE
  // ------------------------------------------------------------

  String _getQuizTitle(DocumentSnapshot<Map<String, dynamic>> quiz) {
    final data = quiz.data();

    final title = data?['title'];

    if (title != null && title.toString().trim().isNotEmpty) {
      return title.toString().trim();
    }

    switch (quiz.id) {
      case 'quiz001':
        return 'Flutter';

      case 'quiz002':
        return 'Cybersecurity';

      case 'quiz003':
        return 'Web Development';

      default:
        return 'Quiz';
    }
  }

  // ------------------------------------------------------------
  // NOTIFICATION TYPE
  // ------------------------------------------------------------

  String _getNotificationTypeLabel(String type) {
    switch (type) {
      case 'new_quiz':
        return 'New Quiz';

      case 'exam_reminder':
        return 'Exam Reminder';

      case 'result_published':
        return 'Result Published';

      case 'quiz_closed':
        return 'Quiz Closed';

      default:
        return 'Notification';
    }
  }

  // ------------------------------------------------------------
  // UPDATE DEFAULT MESSAGE WHEN TYPE CHANGES
  // ------------------------------------------------------------

  void _updateMessageForType(String type) {
    switch (type) {
      case 'new_quiz':
        _titleController.text = 'New Quiz Available';
        _messageController.text =
            'A new quiz is now available. Open the app to start practicing.';
        break;

      case 'exam_reminder':
        _titleController.text = 'Exam Reminder';
        _messageController.text =
            'Your exam is coming soon. Make sure you are prepared.';
        break;

      case 'result_published':
        _titleController.text = 'Result Published';
        _messageController.text = 'Your quiz result has been published. Open the app to view your result.';
        break;

      case 'quiz_closed':
        _titleController.text = 'Quiz Closed';
        _messageController.text =
            'This quiz is now closed and is no longer accepting attempts.';
        break;
    }

    setState(() {});
  }

  // ------------------------------------------------------------
  // SEND NOTIFICATION
  // ------------------------------------------------------------

  Future<void> _sendNotification() async {
    if (_selectedQuizId == null) {
      _showMessage('Please select a quiz.');
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showMessage('Please enter a notification title.');
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      _showMessage('Please enter a notification message.');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get();

      if (studentsSnapshot.docs.isEmpty) {
        _showMessage('No students were found.');

        setState(() {
          _isSending = false;
        });

        return;
      }

      final batch = _firestore.batch();

      for (final student in studentsSnapshot.docs) {
        final notificationRef = _firestore.collection('notifications').doc();

        batch.set(notificationRef, {
          'userId': student.id,
          'title': _titleController.text.trim(),
          'message': _messageController.text.trim(),
          'type': _selectedNotificationType,
          'quizId': _selectedQuizId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      _showMessage(
        'Notification sent to ${studentsSnapshot.docs.length} students.',
      );
    } catch (e) {
      _showMessage(
        'Failed to send notification. Please check Firebase permissions.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkColor,
      ),
    );
  }

  // ------------------------------------------------------------
  // QUIZ SELECTOR
  // ------------------------------------------------------------

  Widget _buildQuizSelector(
    List<DocumentSnapshot<Map<String, dynamic>>> quizzes,
  ) {
    if (quizzes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No quizzes found in Firebase.',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    final validIds = ['quiz001', 'quiz002', 'quiz003'];

    final sortedQuizzes = [...quizzes];

    sortedQuizzes.sort((a, b) {
      return validIds.indexOf(a.id).compareTo(validIds.indexOf(b.id));
    });

    final selectedExists = sortedQuizzes.any(
      (quiz) => quiz.id == _selectedQuizId,
    );

    if (!selectedExists) {
      _selectedQuizId = sortedQuizzes.first.id;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedQuizId,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          items: sortedQuizzes.map((quiz) {
            return DropdownMenuItem<String>(
              value: quiz.id,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.quiz_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(_getQuizTitle(quiz)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedQuizId = value;
            });
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // NOTIFICATION TYPE SELECTOR
  // ------------------------------------------------------------

  Widget _buildNotificationTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedNotificationType,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          items: const [
            DropdownMenuItem(value: 'new_quiz', child: Text('New Quiz')),
            DropdownMenuItem(
              value: 'exam_reminder',
              child: Text('Exam Reminder'),
            ),
            DropdownMenuItem(
              value: 'result_published',
              child: Text('Result Published'),
            ),
            DropdownMenuItem(value: 'quiz_closed', child: Text('Quiz Closed')),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedNotificationType = value;
            });

            _updateMessageForType(value);
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TEXT FIELD
  // ------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        future: _loadQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load quizzes.\nPlease check your Firebase connection and rules.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
              ),
            );
          }

          final quizzes = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------
                // HEADER CARD
                // ------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: darkColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Send Notifications',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Notify students about quizzes, exams and results.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.78),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // QUIZ SELECTION
                // ------------------------------------------------
                Text(
                  'Select Quiz',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 9),

                _buildQuizSelector(quizzes),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // NOTIFICATION TYPE
                // ------------------------------------------------
                Text(
                  'Notification Type',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 9),

                _buildNotificationTypeSelector(),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // NOTIFICATION DETAILS CARD
                // ------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: primaryColor,
                            size: 23,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            'Notification Details',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'Enter notification title',
                      ),

                      const SizedBox(height: 15),

                      _buildTextField(
                        controller: _messageController,
                        label: 'Message',
                        hint: 'Enter notification message',
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // SEND BUTTON
                // ------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendNotification,
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                    label: Text(
                      _isSending ? 'Sending...' : 'Send Notification',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryColor.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ------------------------------------------------
                // INFO
                // ------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'The notification will be sent to all registered students.',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
