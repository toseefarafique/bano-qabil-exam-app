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

  final TextEditingController _passingController =
  TextEditingController();

  String? _lastPassingQuizId;

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

// Only these three quizzes are displayed.
  bool _isAllowedQuiz(String quizId) {
    return quizId == 'quiz001' ||
        quizId == 'quiz002' ||
        quizId == 'quiz003';
  }

  String _getQuizTitle(
      String quizId,
      Map<String, dynamic> data,
      ) {
    final title = data['title']?.toString().trim() ?? '';


    if (title.isNotEmpty) {
    return title;
    }

    switch (quizId) {
    case 'quiz001':
    return 'Flutter';
    case 'quiz002':
    return 'Cybersecurity';
    case 'quiz003':
    return 'Web Development';
    default:
    return quizId;
    }


  }

  Future<void> _updateQuizStatus(
      String quizId,
      String status,
      ) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });


    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    content: Text(
    'Quiz status changed to ${_formatStatus(status)}',
    ),
    backgroundColor: primary,
    ),
    );
    } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    content: Text('Error: $e'),
    backgroundColor: Colors.red,
    ),
    );
    }


  }

  Future<void> _savePassingPercentage(String quizId) async {
    final value = int.tryParse(
      _passingController.text.trim(),
    );


    if (value == null || value < 0 || value > 100) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text(
    'Please enter a percentage between 0 and 100.',
    ),
    ),
    );
    return;
    }

    try {
    await _firestore.collection('quizzes').doc(quizId).update({
    'passingPercentage': value,
    'updatedAt': Timestamp.now(),
    });

    if (!mounted) return;

    setState(() {
    _lastPassingQuizId = quizId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text(
    'Passing percentage updated successfully.',
    ),
    ),
    );
    } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    content: Text('Error: $e'),
    backgroundColor: Colors.red,
    ),
    );
    }


  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) {
      return 'Unknown';
    }


    switch (status.toLowerCase()) {
    case 'draft':
    return 'Draft';
    case 'approved':
    return 'Approved';
    case 'published':
    return 'Published';
    case 'locked':
    return 'Locked';
    case 'results_released':
    return 'Results Released';
    default:
    return status;
    }


  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'draft':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'published':
        return Colors.green;
      case 'locked':
        return Colors.redAccent;
      case 'results_released':
        return Colors.teal;
      default:
        return primary;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'draft':
        return Icons.edit_note;
      case 'approved':
        return Icons.verified_outlined;
      case 'published':
        return Icons.public;
      case 'locked':
        return Icons.lock_outline;
      case 'results_released':
        return Icons.emoji_events_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _statusBadge(String? status) {
    final color = _statusColor(status);


    return Container(
    padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 7,
    ),
    decoration: BoxDecoration(
    color: color.withOpacity(0.10),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
    color: color.withOpacity(0.25),
    ),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(
    _statusIcon(status),
    size: 16,
    color: color,
    ),
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

  Widget _sectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: darkPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _infoCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: primary,
              size: 21,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: textDark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool outlined = false,
  }) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(
            color: primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      );
    }


    return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
    ),
    ),
    );


  }

  Widget _statCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
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

  Widget _buildControllerPanel(
      String quizId,
      Map<String, dynamic> data,
      ) {
    final title = _getQuizTitle(
      quizId,
      data,
    );


    final status =
    data['status']?.toString() ?? 'draft';

    final duration =
    data['duration']?.toString() ?? '0';

    final totalQuestions =
    data['totalQuestion']?.toString() ?? '0';

    final passingPercentage =
    data['passingPercentage']?.toString() ?? '50';

    if (_lastPassingQuizId != quizId) {
    WidgetsBinding.instance.addPostFrameCallback(
    (_) {
    if (!mounted) return;

    _passingController.text =
    passingPercentage;

    _lastPassingQuizId = quizId;
    },
    );
    }

    return Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
    _sectionTitle(
    'Quiz Overview',
    Icons.dashboard_customize_outlined,
    ),

    const SizedBox(height: 14),

    Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
    color: darkPrimary,
    borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
    children: [
    Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.12),
    borderRadius: BorderRadius.circular(13),
    ),
    child: const Icon(
    Icons.quiz_outlined,
    color: Colors.white,
    size: 27,
    ),
    ),
    const SizedBox(width: 14),
    Expanded(
    child: Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
    Text(
    title,
    style: const TextStyle(
    color: Colors.white,
    fontSize: 21,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 4),
    Text(
    'Quiz ID: $quizId',
    style: TextStyle(
    color: Colors.white70,
    fontSize: 12,
    ),
    ),
    ],
    ),
    ),
    _statusBadge(status),
    ],
    ),
    ),

    const SizedBox(height: 14),

    Row(
    children: [
    _infoCard(
    'Questions',
    totalQuestions,
    Icons.help_outline,
    ),
    const SizedBox(width: 10),
    _infoCard(
    'Duration',
    '$duration min',
    Icons.timer_outlined,
    ),
    const SizedBox(width: 10),
    _infoCard(
    'Passing',
    '$passingPercentage%',
    Icons.percent,
    ),
    ],
    ),

    const SizedBox(height: 24),

    _sectionTitle(
    'Quiz Control',
    Icons.settings_outlined,
    ),

    const SizedBox(height: 14),

    Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: border),
    ),
    child: Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
    const Text(
    'Change Quiz Status',
    style: TextStyle(
    color: textDark,
    fontWeight: FontWeight.bold,
    fontSize: 15,
    ),
    ),

    const SizedBox(height: 12),

    Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
    _actionButton(
    label: 'Approve',
    icon: Icons.check_circle_outline,
    onPressed: () {
    _updateQuizStatus(
    quizId,
    'approved',
    );
    },
    outlined: true,
    ),
    _actionButton(
    label: 'Publish',
    icon: Icons.public,
    onPressed: () {
    _updateQuizStatus(
    quizId,
    'published',
    );
    },
    ),
    _actionButton(
    label: 'Lock',
    icon: Icons.lock_outline,
    onPressed: () {
    _updateQuizStatus(
    quizId,
    'locked',
    );
    },
    outlined: true,
    ),
    _actionButton(
    label: 'Release Results',
    icon: Icons.emoji_events_outlined,
    onPressed: () {
    _updateQuizStatus(
    quizId,
    'results_released',
    );
    },
    ),
    ],
    ),

    const SizedBox(height: 22),

    const Text(
    'Passing Percentage',
    style: TextStyle(
    color: textDark,
    fontWeight: FontWeight.bold,
    fontSize: 15,
    ),
    ),

    const SizedBox(height: 10),

    Row(
    children: [
    Expanded(
    child: TextField(
    controller:
    _passingController,
    keyboardType:
    TextInputType.number,
    decoration: InputDecoration(
    hintText:
    'Enter percentage',
    suffixText: '%',
    filled: true,
    fillColor: background,
    border: OutlineInputBorder(
    borderRadius:
    BorderRadius.circular(10),
    borderSide:
    const BorderSide(
    color: border,
    ),
    ),
    enabledBorder:
    OutlineInputBorder(
    borderRadius:
    BorderRadius.circular(10),
    borderSide:
    const BorderSide(
    color: border,
    ),
    ),
    ),
    ),
    ),
    const SizedBox(width: 10),
    ElevatedButton(
    onPressed: () {
    _savePassingPercentage(
    quizId,
    );
    },
    style: ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding:
    const EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 16,
    ),
    shape:
    RoundedRectangleBorder(
    borderRadius:
    BorderRadius.circular(10),
    ),
    ),
    child: const Text('Save'),
    ),
    ],
    ),
    ],
    ),
    ),

    const SizedBox(height: 24),

    _sectionTitle(
    'Reports',
    Icons.bar_chart_outlined,
    ),

    const SizedBox(height: 14),

    _buildReport(quizId),

    const SizedBox(height: 24),

    _sectionTitle(
    'Student Results',
    Icons.people_outline,
    ),

    const SizedBox(height: 14),

    _buildStudentResults(quizId),
    ],
    );


  }

  Widget _buildReport(String quizId) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
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
          return _loadingCard();
        }


        if (snapshot.hasError) {
        return _errorCard(
        'Unable to load report.',
        );
        }

        final attempts =
        snapshot.data?.docs ?? [];

        final totalAttempts =
        attempts.length;

        int passed = 0;
        int failed = 0;

        for (final attempt in attempts) {
        final data = attempt.data();

        final score =
        (data['score'] as num?)
            ?.toDouble() ??
        0.0;

        final total =
        (data['totalQuestions'] as num?)
            ?.toDouble() ??
        (data['totalQuestion'] as num?)
            ?.toDouble() ??
        0.0;

        if (total > 0 &&
        (score / total) * 100 >= 50) {
        passed++;
        } else {
        failed++;
        }
        }

        return Row(
        children: [
        _statCard(
        'Total Attempts',
        '$totalAttempts',
        Icons.assignment_outlined,
        ),
        const SizedBox(width: 10),
        _statCard(
        'Passed',
        '$passed',
        Icons.check_circle_outline,
        ),
        const SizedBox(width: 10),
        _statCard(
        'Failed',
        '$failed',
        Icons.cancel_outlined,
        ),
        ],
        );
      },
    );


  }

  Widget _buildStudentResults(String quizId) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
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
          return _loadingCard();
        }


        if (snapshot.hasError) {
        return _errorCard(
        'Unable to load student results.',
        );
        }

        final attempts =
        snapshot.data?.docs ?? [];

        if (attempts.isEmpty) {
        return _emptyCard(
        'No student attempts found for this quiz.',
        );
        }

        return Column(
        children: attempts.map((attempt) {
        final data = attempt.data();

        final studentName =
        data['studentName']
            ?.toString() ??
        data['name']?.toString() ??
        'Unknown Student';

        final score =
        data['score']?.toString() ??
        '0';

        final total =
        data['totalQuestions']
            ?.toString() ??
        data['totalQuestion']
            ?.toString() ??
        '0';

        return _studentResultCard(
        studentName,
        score,
        total,
        );
        }).toList(),
        );
      },
    );


  }

  Widget _studentResultCard(
      String studentName,
      String score,
      String total,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor:
            accent.withOpacity(0.45),
            child: const Icon(
              Icons.person_outline,
              color: darkPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              studentName,
              style: const TextStyle(
                color: textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _smallResultInfo(
            'Score',
            '$score / $total',
          ),
        ],
      ),
    );
  }

  Widget _smallResultInfo(
      String title,
      String value,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _loadingCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: primary,
        ),
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Publish & Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('quizzes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            );
          }


          if (snapshot.hasError) {
          return _errorCard(
          'Unable to load quizzes: ${snapshot.error}',
          );
          }

          // Get only quiz001, quiz002 and quiz003.
          final quizzes = (snapshot.data?.docs ?? [])
              .where(
          (quiz) =>
          _isAllowedQuiz(quiz.id),
          )
              .toList();

          // Keep the order:
          // Flutter → Cybersecurity → Web Development
          quizzes.sort((a, b) {
          int getOrder(String id) {
          switch (id) {
          case 'quiz001':
          return 1;
          case 'quiz002':
          return 2;
          case 'quiz003':
          return 3;
          default:
          return 99;
          }
          }

          return getOrder(a.id)
              .compareTo(getOrder(b.id));
          });

          if (quizzes.isEmpty) {
          return _emptyCard(
          'No quizzes found.',
          );
          }

          // IMPORTANT:
          // Do NOT use firstWhere here.
          // It causes the Flutter Web type error.
          QueryDocumentSnapshot<
          Map<String, dynamic>> selectedQuiz =
          quizzes.first;

          if (_selectedQuizId != null) {
          for (final quiz in quizzes) {
          if (quiz.id == _selectedQuizId) {
          selectedQuiz = quiz;
          break;
          }
          }
          }

          if (_selectedQuizId != selectedQuiz.id) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) {
          if (!mounted) return;

          setState(() {
          _selectedQuizId =
          selectedQuiz.id;
          });
          });
          }

          final selectedData =
          selectedQuiz.data();

          return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
          Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
          gradient:
          const LinearGradient(
          colors: [
          darkPrimary,
          primary,
          ],
          ),
          borderRadius:
          BorderRadius.circular(20),
          ),
          child: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
          Text(
          'Publish & Reports',
          style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight:
          FontWeight.bold,
          ),
          ),
          SizedBox(height: 6),
          Text(
          'Manage quizzes, publish exams and review reports.',
          style: TextStyle(
          color: Colors.white70,
          fontSize: 13,
          ),
          ),
          ],
          ),
          ),

          const SizedBox(height: 22),

          _sectionTitle(
          'Select Exam',
          Icons.library_books_outlined,
          ),

          const SizedBox(height: 12),

          Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(16),
          decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
          color: border,
          ),
          ),
          child:
          DropdownButtonFormField<
          String>(
          initialValue:
          selectedQuiz.id,
          isExpanded: true,
          decoration:
          InputDecoration(
          labelText: 'Choose Quiz',
          prefixIcon:
          const Icon(
          Icons.quiz_outlined,
          color: primary,
          ),
          filled: true,
          fillColor: background,
          border:
          OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
          12,
          ),
          borderSide:
          const BorderSide(
          color: border,
          ),
          ),
          enabledBorder:
          OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
          12,
          ),
          borderSide:
          const BorderSide(
          color: border,
          ),
          ),
          ),
          items: quizzes.map((quiz) {
          final data =
          quiz.data();

          final title =
          _getQuizTitle(
          quiz.id,
          data,
          );

          return DropdownMenuItem<
          String>(
          value: quiz.id,
          child: Text(
          title,
          overflow:
          TextOverflow.ellipsis,
          style:
          const TextStyle(
          color: textDark,
          fontWeight:
          FontWeight.w600,
          ),
          ),
          );
          }).toList(),
          onChanged: (value) {
          if (value == null) {
          return;
          }

          setState(() {
          _selectedQuizId =
          value;
          _lastPassingQuizId =
          null;
          });
          },
          ),
          ),

          const SizedBox(height: 24),

          _buildControllerPanel(
          selectedQuiz.id,
          selectedData,
          ),
          ],
          ),
          );
          },
      ),
    );


  }
}
