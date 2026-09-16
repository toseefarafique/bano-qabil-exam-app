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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedQuizId;

  final TextEditingController _passingController = TextEditingController();

  String? _lastPassingQuizId;

  // ------------------------------------------------------------
  // THEME COLORS
  // ------------------------------------------------------------

  static const Color primary = Color(0xFF6D597A);
  static const Color darkPrimary = Color(0xFF44364D);
  static const Color accent = Color(0xFFDDBEA9);
  static const Color background = Color(0xFFF8F4F0);
  static const Color textDark = Color(0xFF332D35);
  static const Color border = Color(0xFFE5DDD8);

  @override
  void dispose() {
    _passingController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // UPDATE QUIZ STATUS
  // ------------------------------------------------------------

  Future<void> _updateQuizStatus(String quizId, String status) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).set({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Exam status changed to ${_formatStatus(status)}'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text('Error updating status: $e'),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // SAVE PASSING PERCENTAGE
  // ------------------------------------------------------------

  Future<void> _savePassingPercentage(String quizId) async {
    final value = double.tryParse(_passingController.text.trim());

    if (value == null || value < 0 || value > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text(
            'Please enter a valid percentage between 0 and 100.',
          ),
        ),
      );
      return;
    }

    try {
      await _firestore.collection('quizzes').doc(quizId).set({
        'passingPercentage': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Passing percentage saved successfully.'),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text('Error saving percentage: $e'),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // STATUS
  // ------------------------------------------------------------

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
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.orange.shade700;
      case 'published':
        return Colors.green.shade700;
      case 'locked':
        return Colors.red.shade700;
      case 'results_released':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.verified_outlined;
      case 'published':
        return Icons.public_outlined;
      case 'locked':
        return Icons.lock_outline;
      case 'results_released':
        return Icons.assessment_outlined;
      default:
        return Icons.edit_note_outlined;
    }
  }

  // ------------------------------------------------------------
  // STATUS BADGE
  // ------------------------------------------------------------

  Widget _statusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            _formatStatus(status),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _sectionTitle(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // INFO CARD
  // ------------------------------------------------------------

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ACTION BUTTON
  // ------------------------------------------------------------

  Widget _actionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ------------------------------------------------------------
  // REPORT
  // ------------------------------------------------------------

  Widget _buildReport(String quizId, double passingPercentage) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('result')
          .where('quizId', isEqualTo: quizId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingCard();
        }

        if (snapshot.hasError) {
          return _errorCard(snapshot.error.toString());
        }

        final results = snapshot.data?.docs ?? [];

        if (results.isEmpty) {
          return _emptyCard(
            'No student results are available for this exam yet.',
            Icons.bar_chart_outlined,
          );
        }

        double totalPercentage = 0;
        int passedStudents = 0;

        for (final doc in results) {
          final data = doc.data() as Map<String, dynamic>;

          final score = (data['score'] as num?)?.toDouble() ?? 0;

          final totalQuestion =
              (data['totalQuestion'] as num?)?.toDouble() ?? 0;

          if (totalQuestion > 0) {
            final percentage = (score / totalQuestion) * 100;

            totalPercentage += percentage;

            if (percentage >= passingPercentage) {
              passedStudents++;
            }
          }
        }

        final averagePercentage = totalPercentage / results.length;

        final passRate = (passedStudents / results.length) * 100;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),

            _sectionTitle(
              'Class Report',
              'A quick overview of overall exam performance',
              Icons.analytics_outlined,
            ),

            const SizedBox(height: 15),

            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 700 ? 4 : 2;

                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: columns == 4 ? 1.45 : 1.55,
                  children: [
                    _statCard(
                      icon: Icons.people_alt_outlined,
                      title: 'Total Results',
                      value: '${results.length}',
                      color: primary,
                    ),
                    _statCard(
                      icon: Icons.bar_chart_rounded,
                      title: 'Average Score',
                      value: '${averagePercentage.toStringAsFixed(1)}%',
                      color: Colors.blue.shade700,
                    ),
                    _statCard(
                      icon: Icons.check_circle_outline,
                      title: 'Passed',
                      value: '$passedStudents',
                      color: Colors.green.shade700,
                    ),
                    _statCard(
                      icon: Icons.percent_rounded,
                      title: 'Pass Rate',
                      value: '${passRate.toStringAsFixed(1)}%',
                      color: Colors.orange.shade700,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.24),
                    accent.withValues(alpha: 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: accent.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Students need at least '
                      '${passingPercentage.toStringAsFixed(0)}% '
                      'to pass this exam.',
                      style: const TextStyle(
                        color: darkPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // STAT CARD
  // ------------------------------------------------------------

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: color.withValues(alpha: 0.55),
                size: 17,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STUDENT RESULTS
  // ------------------------------------------------------------

  Widget _buildStudentResults(String quizId, double passingPercentage) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('result')
          .where('quizId', isEqualTo: quizId)
          .snapshots(),
      builder: (context, resultSnapshot) {
        if (resultSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingCard();
        }

        if (resultSnapshot.hasError) {
          return _errorCard(resultSnapshot.error.toString());
        }

        final results = resultSnapshot.data?.docs ?? [];

        if (results.isEmpty) {
          return _emptyCard(
            'No student results found for this exam.',
            Icons.people_outline,
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('student').snapshots(),
          builder: (context, studentSnapshot) {
            if (studentSnapshot.connectionState == ConnectionState.waiting) {
              return _loadingCard();
            }

            final studentDocs = studentSnapshot.data?.docs ?? [];

            final studentMap = <String, Map<String, dynamic>>{};

            for (final studentDoc in studentDocs) {
              studentMap[studentDoc.id] =
                  studentDoc.data() as Map<String, dynamic>;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                _sectionTitle(
                  'Student Results',
                  'Individual performance for this exam',
                  Icons.people_alt_outlined,
                ),

                const SizedBox(height: 15),

                ...results.map((resultDoc) {
                  final result = resultDoc.data() as Map<String, dynamic>;

                  final studentId = result['studentId']?.toString() ?? '';

                  final student = studentMap[studentId];

                  final studentName =
                      student?['name']?.toString() ?? 'Unknown Student';

                  final email = student?['email']?.toString() ?? '';

                  final score = (result['score'] as num?)?.toDouble() ?? 0;

                  final total =
                      (result['totalQuestion'] as num?)?.toDouble() ?? 0;

                  final double percentage = total > 0 ? (score / total) * 100 : 0.0;

                  final passed = percentage >= passingPercentage;

                  return _studentResultCard(
                    studentName: studentName,
                    email: email,
                    score: score,
                    total: total,
                    percentage: percentage,
                    passed: passed,
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // STUDENT RESULT CARD
  // ------------------------------------------------------------

  Widget _studentResultCard({
    required String studentName,
    required String email,
    required double score,
    required double total,
    required double percentage,
    required bool passed,
  }) {
    final resultColor = passed ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: 0.18),
                      accent.withValues(alpha: 0.25),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        color: textDark,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      passed
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      size: 14,
                      color: resultColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      passed ? 'Passed' : 'Failed',
                      style: TextStyle(
                        color: resultColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _smallResultInfo(
                  Icons.star_outline,
                  'Score',
                  '${score.toStringAsFixed(0)} / '
                      '${total.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _smallResultInfo(
                  Icons.percent_rounded,
                  'Percentage',
                  '${percentage.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(resultColor),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SMALL RESULT INFO
  // ------------------------------------------------------------

  Widget _smallResultInfo(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: primary),
        ),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: darkPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // CONTROLLER PANEL
  // ------------------------------------------------------------

  Widget _buildControllerPanel(QueryDocumentSnapshot quizDoc) {
    final data = quizDoc.data() as Map<String, dynamic>;

    final quizId = quizDoc.id;

    final title = data['title']?.toString() ?? 'Untitled Quiz';

    final subjectId = data['subjectId']?.toString() ?? 'N/A';

    final status = data['status']?.toString() ?? 'draft';

    final duration = (data['duration'] as num?)?.toInt() ?? 0;

    final totalQuestion = (data['totalQuestion'] as num?)?.toInt() ?? 0;

    final passingPercentage =
        (data['passingPercentage'] as num?)?.toDouble() ?? 50;

    if (_lastPassingQuizId != quizId) {
      _passingController.text = passingPercentage.toStringAsFixed(0);

      _lastPassingQuizId = quizId;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // ------------------------------------------------------
        // QUIZ OVERVIEW CARD
        // ------------------------------------------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Exam ID: $quizId',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _statusBadge(status),
                ],
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // INFO CARDS
              // ------------------------------------------------
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 750 ? 3 : 1;

                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: columns == 3 ? 2.7 : 4.2,
                    children: [
                      _infoCard(
                        icon: Icons.category_outlined,
                        title: 'Subject',
                        value: subjectId,
                      ),
                      _infoCard(
                        icon: Icons.timer_outlined,
                        title: 'Duration',
                        value: '$duration minutes',
                      ),
                      _infoCard(
                        icon: Icons.quiz_outlined,
                        title: 'Questions',
                        value: '$totalQuestion',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // PASSING PERCENTAGE
              // ------------------------------------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.percent_rounded,
                            color: primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Passing Percentage',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _passingController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. 50',
                              suffixText: '%',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        ElevatedButton(
                          onPressed: () {
                            _savePassingPercentage(quizId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 19,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save_outlined, size: 17),
                              SizedBox(width: 7),
                              Text(
                                'Save',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // EXAM LIFECYCLE
              // ------------------------------------------------
              const Text(
                'Exam Lifecycle',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Manage the current stage of this examination.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),

              const SizedBox(height: 13),

              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  _actionButton(
                    title: 'Approve',
                    icon: Icons.check_circle_outline,
                    color: Colors.orange.shade700,
                    onPressed: () {
                      _updateQuizStatus(quizId, 'approved');
                    },
                  ),
                  _actionButton(
                    title: 'Publish',
                    icon: Icons.publish_outlined,
                    color: Colors.green.shade700,
                    onPressed: () {
                      _updateQuizStatus(quizId, 'published');
                    },
                  ),
                  _actionButton(
                    title: 'Lock',
                    icon: Icons.lock_outline,
                    color: Colors.red.shade700,
                    onPressed: () {
                      _updateQuizStatus(quizId, 'locked');
                    },
                  ),
                  _actionButton(
                    title: 'Release Results',
                    icon: Icons.assessment_outlined,
                    color: Colors.blue.shade700,
                    onPressed: () {
                      _updateQuizStatus(quizId, 'results_released');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        _buildReport(quizId, passingPercentage),

        _buildStudentResults(quizId, passingPercentage),
      ],
    );
  }

  // ------------------------------------------------------------
  // LOADING CARD
  // ------------------------------------------------------------

  Widget _loadingCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: primary, strokeWidth: 2.5),
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY CARD
  // ------------------------------------------------------------

  Widget _emptyCard(String message, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 27, color: primary),
          ),
          const SizedBox(height: 13),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ERROR CARD
  // ------------------------------------------------------------

  Widget _errorCard(String error) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Something went wrong:\n$error',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.assessment_outlined, size: 23),
            SizedBox(width: 10),
            Text(
              'Publish & Reports',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('quizzes').orderBy('title').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _errorCard(
                  'Error loading quizzes:\n'
                  '${snapshot.error}',
                ),
              ),
            );
          }

          final quizzes = snapshot.data?.docs ?? [];

          if (quizzes.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: _emptyCard(
                'No quizzes have been created yet.',
                Icons.assignment_outlined,
              ),
            );
          }

          _selectedQuizId ??= quizzes.first.id;

          QueryDocumentSnapshot? selectedQuiz;

          for (final quiz in quizzes) {
            if (quiz.id == _selectedQuizId) {
              selectedQuiz = quiz;
              break;
            }
          }

          selectedQuiz ??= quizzes.first;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1050),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // PAGE HEADER
                    // ------------------------------------------------

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6D597A), Color(0xFF44364D)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.20),
                            blurRadius: 18,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.dashboard_customize_outlined,
                              color: Colors.white,
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Exam Management',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Publish exams, manage their lifecycle, and monitor student performance.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // SELECT EXAM
                    // ------------------------------------------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 12,
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
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.assignment_outlined,
                                  color: primary,
                                  size: 19,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Select Exam',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: textDark,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 11),

                          DropdownButtonFormField<String>(
                            initialValue: selectedQuiz.id,
                            isExpanded: true,
                            decoration: InputDecoration(
                              hintText: 'Choose an exam',
                              filled: true,
                              fillColor: background,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: primary,
                            ),
                            items: quizzes.map((quiz) {
                              final quizData =
                                  quiz.data() as Map<String, dynamic>;

                              final quizTitle =
                                  quizData['title']?.toString() ?? quiz.id;

                              return DropdownMenuItem<String>(
                                value: quiz.id,
                                child: Text(
                                  quizTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: textDark,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedQuizId = value;
                                _lastPassingQuizId = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    _buildControllerPanel(selectedQuiz),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
