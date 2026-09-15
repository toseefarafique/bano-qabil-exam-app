import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherAttemptsScreen extends StatefulWidget {
  const TeacherAttemptsScreen({super.key});

  @override
  State<TeacherAttemptsScreen> createState() => _TeacherAttemptsScreenState();
}

class _TeacherAttemptsScreenState extends State<TeacherAttemptsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedQuizId;

  Future<void> _closeQuiz(String quizId) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).update({
        'status': 'locked',
        'closedAt': FieldValue.serverTimestamp(),
      });

      _showMessage('Quiz closed successfully.');
    } catch (e) {
      _showMessage('Unable to close quiz.');
    }
  }

  Future<void> _toggleLeaderboard(String quizId, bool currentValue) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).update({
        'showLeaderboard': !currentValue,
      });

      _showMessage(
        currentValue ? 'Leaderboard hidden.' : 'Leaderboard is now visible.',
      );
    } catch (e) {
      _showMessage('Unable to update leaderboard.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatTime(dynamic timeTaken) {
    if (timeTaken == null) {
      return 'N/A';
    }

    if (timeTaken is num) {
      final seconds = timeTaken.toInt();

      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;

      if (minutes > 0) {
        return '${minutes}m ${remainingSeconds}s';
      }

      return '${remainingSeconds}s';
    }

    return timeTaken.toString();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'passed':
        return Colors.green;

      case 'failed':
        return Colors.red;

      case 'in progress':
      case 'started':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6D597A)),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF332D35),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmCloseQuiz(String quizId, String quizTitle) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Close Quiz?'),
          content: Text(
            'Are you sure you want to close "$quizTitle"? Students will no longer be able to continue this quiz.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _closeQuiz(quizId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D597A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Close Quiz'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D597A),
        foregroundColor: Colors.white,
        title: const Text(
          'Teacher Attempts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('quizzes')
            .where('createdBy', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, quizSnapshot) {
          if (quizSnapshot.hasError) {
            return const Center(child: Text('Unable to load quizzes.'));
          }

          if (quizSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final quizzes = quizSnapshot.data?.docs ?? [];

          if (quizzes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No quizzes found.\nCreate a quiz first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: Color(0xFF44364D)),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Teacher Attempts',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF44364D),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Monitor student attempts and manage quiz settings.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF332D35)),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  initialValue: selectedQuizId,
                  decoration: InputDecoration(
                    labelText: 'Select Quiz',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.quiz_outlined,
                      color: Color(0xFF6D597A),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: quizzes.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(data['title']?.toString() ?? 'Untitled Quiz'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedQuizId = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                if (selectedQuizId != null)
                  _buildSelectedQuiz(selectedQuizId!, quizzes)
                else
                  Card(
                    color: Colors.white,
                    child: const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.touch_app_outlined,
                              size: 45,
                              color: Color(0xFF6D597A),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Select a quiz to view student attempts.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF44364D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedQuiz(
    String quizId,
    List<QueryDocumentSnapshot> quizzes,
  ) {
    QueryDocumentSnapshot? selectedQuiz;

    for (final quiz in quizzes) {
      if (quiz.id == quizId) {
        selectedQuiz = quiz;
        break;
      }
    }

    if (selectedQuiz == null) {
      return const SizedBox();
    }

    final quizData = selectedQuiz.data() as Map<String, dynamic>;

    final quizTitle = quizData['title']?.toString() ?? 'Untitled Quiz';

    final quizStatus = quizData['status']?.toString() ?? 'unknown';

    final showLeaderboard = quizData['showLeaderboard'] == true;

    final questionCount = quizData['questionCount'] ?? 0;

    final timeLimit = quizData['timeLimit'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quizTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF44364D),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _infoItem(
                        Icons.help_outline,
                        '$questionCount Questions',
                      ),
                    ),
                    Expanded(
                      child: _infoItem(Icons.timer_outlined, '$timeLimit min'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _statusBadge(quizStatus),
                  ],
                ),

                const SizedBox(height: 16),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Show Leaderboard',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    showLeaderboard
                        ? 'Students can see the leaderboard.'
                        : 'Leaderboard is hidden.',
                  ),
                  value: showLeaderboard,
                  activeColor: const Color(0xFF6D597A),
                  onChanged: (value) {
                    _toggleLeaderboard(quizId, showLeaderboard);
                  },
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: quizStatus == 'locked'
                        ? null
                        : () {
                            _confirmCloseQuiz(quizId, quizTitle);
                          },
                    icon: const Icon(Icons.lock_outline),
                    label: Text(
                      quizStatus == 'locked' ? 'Quiz Closed' : 'Close Quiz',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6D597A),
                      side: const BorderSide(color: Color(0xFF6D597A)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Student Attempts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF44364D),
          ),
        ),

        const SizedBox(height: 10),

        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('attempts')
              .where('quizId', isEqualTo: quizId)
              .snapshots(),
          builder: (context, attemptSnapshot) {
            if (attemptSnapshot.hasError) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Unable to load attempts.'),
                ),
              );
            }

            if (attemptSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final attempts = attemptSnapshot.data?.docs ?? [];

            if (attempts.isEmpty) {
              return Card(
                color: Colors.white,
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 45,
                          color: Color(0xFF6D597A),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No student attempts yet.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF44364D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final doc = attempts[index];

                final data = doc.data() as Map<String, dynamic>;

                final studentName =
                    data['studentName']?.toString() ??
                    data['name']?.toString() ??
                    'Student';

                final score = data['score']?.toString() ?? '0';

                final status = data['status']?.toString() ?? 'Completed';

                final timeTaken = data['timeTaken'];

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFFDDBEA9),
                          child: Text(
                            studentName.isNotEmpty
                                ? studentName[0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              color: Color(0xFF44364D),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF44364D),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Score: $score',
                                style: const TextStyle(
                                  color: Color(0xFF332D35),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Time: ${_formatTime(timeTaken)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        _statusBadge(status),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
