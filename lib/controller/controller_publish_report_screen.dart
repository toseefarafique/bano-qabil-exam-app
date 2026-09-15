import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ControllerPublishReportScreen extends StatefulWidget {
  const ControllerPublishReportScreen({super.key});

  @override
  State<ControllerPublishReportScreen> createState() =>
      _ControllerPublishReportScreenState();
}

class _ControllerPublishReportScreenState
    extends State<ControllerPublishReportScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String? selectedQuizId;

  final TextEditingController _passingController =
  TextEditingController(text: '50');

  final TextEditingController _reasonController =
  TextEditingController();

  @override
  void dispose() {
    _passingController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _updateQuizStatus(
      String quizId,
      String status,
      ) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(quizId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showMessage(
        'Exam status changed to ${_formatStatus(status)}.',
      );
    } catch (e) {
      _showMessage('Unable to update exam status.');
    }
  }

  Future<void> _savePassingPercentage(
      String quizId,
      ) async {
    final value =
    int.tryParse(_passingController.text.trim());

    if (value == null || value < 1 || value > 100) {
      _showMessage(
        'Passing percentage must be between 1 and 100.',
      );
      return;
    }

    try {
      await _firestore
          .collection('quizzes')
          .doc(quizId)
          .update({
        'passingPercentage': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showMessage('Passing percentage saved.');
    } catch (e) {
      _showMessage(
        'Unable to save passing percentage.',
      );
    }
  }

  Future<void> _reopenAttempt(
      String attemptId,
      ) async {
    final reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      _showMessage(
        'Please enter a reason for reopening the attempt.',
      );
      return;
    }

    try {
      await _firestore
          .collection('attempts')
          .doc(attemptId)
          .update({
        'status': 'reopened',
        'reopenReason': reason,
        'reopenedAt': FieldValue.serverTimestamp(),
      });

      _reasonController.clear();

      if (mounted) {
        Navigator.pop(context);
      }

      _showMessage('Attempt reopened successfully.');
    } catch (e) {
      _showMessage('Unable to reopen attempt.');
    }
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return status;

    return status[0].toUpperCase() +
        status.substring(1).replaceAll('_', ' ');
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;

      case 'approved':
        return Colors.orange;

      case 'published':
        return Colors.green;

      case 'locked':
        return Colors.red;

      case 'results_released':
        return const Color(0xFF6D597A);

      default:
        return Colors.blueGrey;
    }
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _infoCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
              const Color(0xFFDDBEA9),
              child: Icon(
                icon,
                color: const Color(0xFF44364D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF44364D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReopenDialog(
      String attemptId,
      ) async {
    _reasonController.clear();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Reopen Attempt',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter a reason for reopening this student attempt.',
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Reason',
                  filled: true,
                  fillColor:
                  const Color(0xFFF8F4F0),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
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
                _reopenAttempt(attemptId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF6D597A),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Reopen',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReport(String quizId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('attempts')
          .where(
        'quizId',
        isEqualTo: quizId,
      )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Unable to load report.',
              ),
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final attempts =
            snapshot.data?.docs ?? [];

        if (attempts.isEmpty) {
          return Card(
            color: Colors.white,
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 45,
                      color: Color(0xFF6D597A),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No attempts available for this exam yet.',
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
          );
        }

        double totalScore = 0;
        int passed = 0;

        for (final attempt in attempts) {
          final data =
          attempt.data() as Map<String, dynamic>;

          final score =
              (data['score'] as num?)?.toDouble() ?? 0;

          totalScore += score;

          final status =
              data['status']?.toString().toLowerCase() ??
                  '';

          if (status == 'passed') {
            passed++;
          }
        }

        final average =
            totalScore / attempts.length;

        final passPercentage =
            (passed / attempts.length) * 100;

        return Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Class Report',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF44364D),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    'Average Score',
                    average.toStringAsFixed(1),
                    Icons.analytics_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoCard(
                    'Pass Rate',
                    '${passPercentage.toStringAsFixed(1)}%',
                    Icons.check_circle_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _infoCard(
              'Total Attempts',
              attempts.length.toString(),
              Icons.people_outline,
            ),

            const SizedBox(height: 20),

            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Insights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF44364D),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: Color(0xFF6D597A),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Hardest question analysis can be added when question-level attempt data is available.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          color: Color(0xFF6D597A),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Students not attempted can be identified using the class student list.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttempts(String quizId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('attempts')
          .where(
        'quizId',
        isEqualTo: quizId,
      )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Text(
            'Unable to load student attempts.',
          );
        }

        final attempts =
            snapshot.data?.docs ?? [];

        if (attempts.isEmpty) {
          return const Text(
            'No student attempts available.',
          );
        }

        return Column(
          children: attempts.map((doc) {
            final data =
            doc.data() as Map<String, dynamic>;

            final studentName =
                data['studentName']?.toString() ??
                    data['name']?.toString() ??
                    'Student';

            final score =
                data['score']?.toString() ?? '0';

            final status =
                data['status']?.toString() ??
                    'completed';

            return Card(
              color: Colors.white,
              margin:
              const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                  const Color(0xFFDDBEA9),
                  child: Text(
                    studentName.isNotEmpty
                        ? studentName[0]
                        .toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      color: Color(0xFF44364D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Score: $score',
                ),
                trailing: TextButton(
                  onPressed: () {
                    _showReopenDialog(doc.id);
                  },
                  child: const Text(
                    'Reopen',
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D597A),
        foregroundColor: Colors.white,
        title: const Text(
          'Controller Publish & Report',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('quizzes')
            .where(
          'type',
          isEqualTo: 'official',
        )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load official exams.',
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final quizzes =
              snapshot.data?.docs ?? [];

          if (quizzes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No official exams found.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF44364D),
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Controller Publish & Report',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF44364D),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage official exam publishing, results and reports.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF332D35),
                  ),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  initialValue: selectedQuizId,
                  decoration: InputDecoration(
                    labelText: 'Select Official Exam',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.assignment_outlined,
                      color: Color(0xFF6D597A),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: quizzes.map((doc) {
                    final data =
                    doc.data() as Map<String, dynamic>;

                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(
                        data['title']?.toString() ??
                            'Official Exam',
                      ),
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
                  _buildControllerPanel(
                    selectedQuizId!,
                    quizzes,
                  )
                else
                  Card(
                    color: Colors.white,
                    child: const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Select an official exam to manage it.',
                          textAlign: TextAlign.center,
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

  Widget _buildControllerPanel(
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

    final data =
    selectedQuiz.data() as Map<String, dynamic>;

    final title =
        data['title']?.toString() ?? 'Official Exam';

    final status =
        data['status']?.toString() ?? 'draft';

    final passingPercentage =
        data['passingPercentage'] ?? 50;

    final timeLimit =
        data['timeLimit'] ?? 0;

    _passingController.text =
        passingPercentage.toString();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
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
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF44364D),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Text(
                      'Current Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: _passingController,
                  keyboardType:
                  TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                    'Passing Percentage',
                    suffixText: '%',
                    filled: true,
                    fillColor:
                    const Color(0xFFF8F4F0),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _savePassingPercentage(
                        quizId,
                      );
                    },
                    icon: const Icon(
                      Icons.save_outlined,
                    ),
                    label: const Text(
                      'Save Passing Percentage',
                    ),
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF6D597A),
                      foregroundColor:
                      Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Exam Time Limit: $timeLimit minutes',
                  style: const TextStyle(
                    color: Color(0xFF332D35),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Exam Lifecycle',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF44364D),
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _actionButton(
                      'Approve',
                      Icons.check,
                          () {
                        _updateQuizStatus(
                          quizId,
                          'approved',
                        );
                      },
                    ),
                    _actionButton(
                      'Publish',
                      Icons.public,
                          () {
                        _updateQuizStatus(
                          quizId,
                          'published',
                        );
                      },
                    ),
                    _actionButton(
                      'Lock',
                      Icons.lock,
                          () {
                        _updateQuizStatus(
                          quizId,
                          'locked',
                        );
                      },
                    ),
                    _actionButton(
                      'Release Results',
                      Icons.celebration_outlined,
                          () {
                        _updateQuizStatus(
                          quizId,
                          'results_released',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        _buildReport(quizId),

        const SizedBox(height: 24),

        const Text(
          'Student Attempts',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF44364D),
          ),
        ),

        const SizedBox(height: 12),

        _buildAttempts(quizId),
      ],
    );
  }

  Widget _actionButton(
      String label,
      IconData icon,
      VoidCallback onPressed,
      ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
        const Color(0xFF6D597A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}