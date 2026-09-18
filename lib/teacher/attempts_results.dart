
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttemptsResults extends StatefulWidget {
  const AttemptsResults({super.key});

  @override
  State<AttemptsResults> createState() => _AttemptsResultsState();
}

class _AttemptsResultsState extends State<AttemptsResults> {
  // ================= COLORS =================
  static const Color plum = Color(0xFF6D597A);
  static const Color darkPlum = Color(0xFF44364D);
  static const Color accent = Color(0xFFDDBEA9);
  static const Color cream = Color(0xFFF8F4F0);
  static const Color textColor = Color(0xFF332D35);

  // ================= FILTER =================
  String _selectedQuizId = 'all';

  // ================= GET QUIZ NAME =================
  Future<String> _getQuizTitle(String quizId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .get();

      if (doc.exists) {
        final data = doc.data();

        return data?['title']?.toString() ?? 'Unknown Quiz';
      }

      return 'Unknown Quiz';
    } catch (e) {
      return 'Unknown Quiz';
    }
  }


// ================= GET STUDENT NAME =================
  Future<String> _getStudentName(String studentId) async {
    if (studentId.isEmpty) {
      return 'Unknown Student';
    }

    try {
      // ============================================================
      // FIRST: Check users collection
      // Firebase Auth UID is normally used as the document ID here.
      // ============================================================

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();

        if (data != null) {
          final name = data['name'] ??
              data['fullName'] ??
              data['displayName'] ??
              data['studentName'];

          if (name != null &&
              name.toString().trim().isNotEmpty) {
            return name.toString();
          }
        }
      }

      // ============================================================
      // SECOND: Check student collection
      // This keeps compatibility with your existing student records.
      // ============================================================

      final studentDoc = await FirebaseFirestore.instance
          .collection('student')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        final data = studentDoc.data();

        if (data != null) {
          final name = data['name'] ??
              data['fullName'] ??
              data['displayName'] ??
              data['studentName'];

          if (name != null &&
              name.toString().trim().isNotEmpty) {
            return name.toString();
          }
        }
      }

      return 'Unknown Student';
    } catch (e) {
      debugPrint(
        'Error getting student name: $e',
      );

      return 'Unknown Student';
    }
  }



  // ================= QUIZ FILTER =================
  Widget _quizFilter() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quizzes')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Unable to load quizzes',
            style: TextStyle(color: Colors.red),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final quizzes = snapshot.data?.docs ?? [];

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accent.withOpacity(0.6),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedQuizId,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: plum,
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: 'all',
                  child: Text('All Quizzes'),
                ),
                ...quizzes.map(
                  (quiz) {
                    final data =
                        quiz.data() as Map<String, dynamic>;

                    return DropdownMenuItem<String>(
                      value: quiz.id,
                      child: Text(
                        data['title']?.toString() ??
                            'Untitled Quiz',
                      ),
                    );
                  },
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedQuizId = value;
                });
              },
            ),
          ),
        );
      },
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: plum,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Attempts & Results',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ================= BODY =================
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('result')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading results:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: plum,
                    ),
                  );
                }

                final allResults =
                    snapshot.data?.docs ?? [];

                // ================= FILTER RESULTS =================
                final results = _selectedQuizId == 'all'
                    ? allResults
                    : allResults.where((doc) {
                        final data =
                            doc.data()
                                as Map<String, dynamic>;

                        return data['quizId']?.toString() ==
                            _selectedQuizId;
                      }).toList();

                // ================= SUMMARY =================
                int passed = 0;
                int failed = 0;

                for (final doc in results) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  final percentage =
                      (data['percentage'] as num?)?.toDouble() ??
                          0;

                  if (percentage >= 50) {
                    passed++;
                  } else {
                    failed++;
                  }
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ================= HEADING =================
                      const Text(
                        'Student Attempts',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'View student quiz performance and results.',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.60),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= SUMMARY =================
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              icon: Icons.people,
                              title: 'Attempts',
                              value: results.length
                                  .toString(),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _summaryCard(
                              icon: Icons.check_circle,
                              title: 'Passed',
                              value: passed.toString(),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _summaryCard(
                              icon: Icons.cancel,
                              title: 'Failed',
                              value: failed.toString(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ================= FILTER =================
                      _quizFilter(),

                      const SizedBox(height: 20),

                      // ================= RESULTS =================
                      if (results.isEmpty)
                        _emptyState()
                      else
                        ...results.map(
                          (result) {
                            final data =
                                result.data()
                                    as Map<String, dynamic>;

                            return _resultCard(data);
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: plum,
            size: 24,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkPlum,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ================= RESULT CARD =================
  Widget _resultCard(
    Map<String, dynamic> data,
  ) {
    final String studentId =
        data['studentId']?.toString() ?? '';

    final String quizId =
        data['quizId']?.toString() ?? '';

    final int score =
        (data['score'] as num?)?.toInt() ?? 0;

    final int totalQuestion =
        (data['totalQuestion'] as num?)?.toInt() ?? 0;

    final int percentage =
        (data['percentage'] as num?)?.toInt() ?? 0;

    final int timeUsed =
        (data['timeUsed'] as num?)?.toInt() ?? 0;

    final bool passed = percentage >= 50;

    DateTime? date;

    if (data['date'] is Timestamp) {
      date = (data['date'] as Timestamp).toDate();
    }

    final String formattedDate = date == null
        ? 'Date unavailable'
        : '${date.day} ${_monthName(date.month)} ${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ================= STUDENT ICON =================
              CircleAvatar(
                radius: 25,
                backgroundColor:
                    accent.withOpacity(0.45),
                child: const Icon(
                  Icons.person,
                  color: darkPlum,
                ),
              ),

              const SizedBox(width: 12),

              // ================= STUDENT + QUIZ =================
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: _getStudentName(studentId),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ??
                              'Loading student...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    FutureBuilder<String>(
                      future: _getQuizTitle(quizId),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ??
                              'Loading quiz...',
                          style: const TextStyle(
                            fontSize: 13,
                            color: plum,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 5),

                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // ================= SCORE =================
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    '$score / $totalQuestion',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkPlum,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: passed
                          ? Colors.green
                              .withOpacity(0.12)
                          : Colors.red
                              .withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      passed ? 'Passed' : 'Failed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: passed
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ================= TIME =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: cream,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: plum,
                ),

                const SizedBox(width: 7),

                Text(
                  'Time Used: $timeUsed',
                  style: const TextStyle(
                    fontSize: 12,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 55,
            color: accent,
          ),

          const SizedBox(height: 12),

          const Text(
            'No Attempts Found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: darkPlum,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Student results will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ================= MONTH NAME =================
  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}

