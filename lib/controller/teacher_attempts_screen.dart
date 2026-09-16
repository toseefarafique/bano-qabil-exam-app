import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherAttemptsScreen extends StatefulWidget {
  const TeacherAttemptsScreen({super.key});

  @override
  State<TeacherAttemptsScreen> createState() =>
      _TeacherAttemptsScreenState();
}

class _TeacherAttemptsScreenState extends State<TeacherAttemptsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedQuizId;

  static const Color primary = Color(0xFF6D597A);
  static const Color darkPurple = Color(0xFF44364D);
  static const Color accent = Color(0xFFDDBEA9);
  static const Color background = Color(0xFFF8F4F0);
  static const Color textColor = Color(0xFF332D35);
  static const Color borderColor = Color(0xFFE5DDD8);

  Future<void> _closeQuiz(String quizId) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).set(
        {
          'status': 'locked',
          'closedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      _showMessage('Exam closed successfully.');
    } catch (e) {
      _showMessage('Unable to close exam.');
    }
  }

  Future<void> _toggleLeaderboard(
      String quizId,
      bool currentValue,
      ) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).set(
        {
          'showLeaderboard': !currentValue,
        },
        SetOptions(merge: true),
      );

      _showMessage(
        currentValue
            ? 'Leaderboard hidden.'
            : 'Leaderboard is now visible.',
      );
    } catch (e) {
      _showMessage('Unable to update leaderboard.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkPurple,
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'locked':
        return Colors.orange;
      case 'published':
        return Colors.blue;
      case 'approved':
        return Colors.orange;
      case 'results_released':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'published':
        return 'Published';
      case 'locked':
        return 'Locked';
      case 'results_released':
        return 'Results Released';
      case 'draft':
        return 'Draft';
      case 'passed':
        return 'Passed';
      case 'failed':
        return 'Failed';
      case 'completed':
        return 'Completed';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
        ),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: darkPurple,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
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

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallResultInfo(
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primary,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCloseQuiz(
      String quizId,
      String quizTitle,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Close Exam?',
            style: TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to close "$quizTitle"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: primary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _closeQuiz(quizId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Close Exam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Student Attempts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('quizzes')
            .orderBy('title')
            .snapshots(),
        builder: (context, quizSnapshot) {
          if (quizSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            );
          }

          if (quizSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading exams:\n${quizSnapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          final quizzes = quizSnapshot.data?.docs ?? [];

          if (quizzes.isEmpty) {
            return _emptyCard(
              'No exams have been created yet.',
            );
          }

          if (selectedQuizId == null ||
              !quizzes.any(
                    (quiz) => quiz.id == selectedQuizId,
              )) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              setState(() {
                selectedQuizId = quizzes.first.id;
              });
            });
          }

          QueryDocumentSnapshot selectedQuiz = quizzes.first;

          for (final quiz in quizzes) {
            if (quiz.id == selectedQuizId) {
              selectedQuiz = quiz;
              break;
            }
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth =
              constraints.maxWidth > 1100
                  ? 1050.0
                  : constraints.maxWidth;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          icon: Icons.assignment_outlined,
                          title: 'Exam Management',
                          subtitle:
                          'View student attempts and manage exam settings.',
                        ),

                        const SizedBox(height: 20),

                        _buildSelectExam(quizzes),

                        const SizedBox(height: 20),

                        _buildSelectedExam(selectedQuiz),

                        const SizedBox(height: 26),

                        const Text(
                          'Student Attempts',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: darkPurple,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'View the performance of students who attempted this exam.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _buildResults(selectedQuiz.id),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectExam(
      List<QueryDocumentSnapshot> quizzes,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.quiz_outlined,
                  color: primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Exam',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Choose an exam to view its attempts.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            initialValue: selectedQuizId,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: borderColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: borderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: primary,
                  width: 1.5,
                ),
              ),
            ),
            items: quizzes.map((doc) {
              final data =
              doc.data() as Map<String, dynamic>;

              final title =
                  data['title']?.toString() ??
                      'Untitled Exam';

              return DropdownMenuItem<String>(
                value: doc.id,
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedQuizId = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedExam(
      QueryDocumentSnapshot quizDoc,
      ) {
    final data =
    quizDoc.data() as Map<String, dynamic>;

    final quizId = quizDoc.id;

    final title =
        data['title']?.toString() ??
            'Untitled Exam';

    final subjectId =
        data['subjectId']?.toString() ??
            'N/A';

    final status =
        data['status']?.toString() ??
            'draft';

    final duration =
        (data['duration'] as num?)?.toInt() ??
            0;

    final totalQuestions =
        (data['totalQuestion'] as num?)?.toInt() ??
            0;

    final showLeaderboard =
        data['showLeaderboard'] == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Exam ID: $quizId',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  children: [
                    _infoCard(
                      icon: Icons.category_outlined,
                      title: 'Subject',
                      value: subjectId,
                    ),
                    const SizedBox(height: 10),
                    _infoCard(
                      icon: Icons.timer_outlined,
                      title: 'Duration',
                      value: '$duration minutes',
                    ),
                    const SizedBox(height: 10),
                    _infoCard(
                      icon: Icons.quiz_outlined,
                      title: 'Questions',
                      value: '$totalQuestions',
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      icon: Icons.category_outlined,
                      title: 'Subject',
                      value: subjectId,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      icon: Icons.timer_outlined,
                      title: 'Duration',
                      value: '$duration minutes',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      icon: Icons.quiz_outlined,
                      title: 'Questions',
                      value: '$totalQuestions',
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 18),

          Container(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: SwitchListTile(
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 3,
              ),
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius:
                  BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.leaderboard_outlined,
                  color: primary,
                ),
              ),
              title: const Text(
                'Leaderboard',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                showLeaderboard
                    ? 'Leaderboard is visible to students.'
                    : 'Leaderboard is currently hidden.',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              value: showLeaderboard,
              activeColor: primary,
              onChanged: (value) {
                _toggleLeaderboard(
                  quizId,
                  showLeaderboard,
                );
              },
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: status.toLowerCase() == 'locked'
                  ? null
                  : () {
                _confirmCloseQuiz(
                  quizId,
                  title,
                );
              },
              icon: const Icon(
                Icons.lock_outline,
              ),
              label: Text(
                status.toLowerCase() == 'locked'
                    ? 'Exam Closed'
                    : 'Close Exam',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                disabledForegroundColor:
                Colors.grey,
                side: BorderSide(
                  color: status.toLowerCase() == 'locked'
                      ? Colors.grey
                      : primary,
                ),
                padding:
                const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(String quizId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('result')
          .where(
        'quizId',
        isEqualTo: quizId,
      )
          .snapshots(),
      builder: (context, resultSnapshot) {
        if (resultSnapshot.connectionState ==
            ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            ),
          );
        }

        if (resultSnapshot.hasError) {
          return _errorCard(
            'Unable to load student attempts.\n'
                '${resultSnapshot.error}',
          );
        }

        final results =
            resultSnapshot.data?.docs ?? [];

        if (results.isEmpty) {
          return _emptyCard(
            'No student attempts are available for this exam yet.',
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('student')
              .snapshots(),
          builder: (context, studentSnapshot) {
            if (studentSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: CircularProgressIndicator(
                    color: primary,
                  ),
                ),
              );
            }

            final studentDocs =
                studentSnapshot.data?.docs ?? [];

            final studentMap =
            <String, Map<String, dynamic>>{};

            for (final studentDoc in studentDocs) {
              studentMap[studentDoc.id] =
              studentDoc.data()
              as Map<String, dynamic>;
            }

            return Column(
              children: results.map((resultDoc) {
                final result =
                resultDoc.data()
                as Map<String, dynamic>;

                final studentId =
                    result['studentId']
                        ?.toString() ??
                        '';

                final student =
                studentMap[studentId];

                final studentName =
                    student?['name']
                        ?.toString() ??
                        'Unknown Student';

                final email =
                    student?['email']
                        ?.toString() ??
                        '';

                final score =
                    (result['score'] as num?)
                        ?.toDouble() ??
                        0;

                final total =
                    (result['totalQuestion'] as num?)
                        ?.toDouble() ??
                        0;

                final double percentage =
                total > 0
                    ? (score / total) * 100
                    : 0.0;

                final passed =
                    percentage >= 50;

                return _buildStudentAttemptCard(
                  studentName: studentName,
                  email: email,
                  score: score,
                  total: total,
                  percentage: percentage,
                  passed: passed,
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentAttemptCard({
    required String studentName,
    required String email,
    required double score,
    required double total,
    required double percentage,
    required bool passed,
  }) {
    final statusColor =
    passed ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    studentName.isNotEmpty
                        ? studentName[0]
                        .toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      color: darkPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        email,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(
                      alpha: 0.25,
                    ),
                  ),
                ),
                child: Text(
                  passed ? 'Passed' : 'Failed',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _smallResultInfo(
                            'Score',
                            '${score.toStringAsFixed(0)} / '
                                '${total.toStringAsFixed(0)}',
                            Icons.star_outline,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _smallResultInfo(
                            'Percentage',
                            '${percentage.toStringAsFixed(0)}%',
                            Icons.percent_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _smallResultInfo(
                      'Score',
                      '${score.toStringAsFixed(0)} / '
                          '${total.toStringAsFixed(0)}',
                      Icons.star_outline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _smallResultInfo(
                      'Percentage',
                      '${percentage.toStringAsFixed(0)}%',
                      Icons.percent_outlined,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkPurple,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
