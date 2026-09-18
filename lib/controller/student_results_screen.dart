import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ControllerStudentResultsScreen extends StatefulWidget {
  const ControllerStudentResultsScreen({super.key});

  @override
  State<ControllerStudentResultsScreen> createState() =>
      _ControllerStudentResultsScreenState();
}

class _ControllerStudentResultsScreenState
    extends State<ControllerStudentResultsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedQuizId;

// ------------------------------------------------------------
// COLORS
// ------------------------------------------------------------

  static const Color primaryColor = Color(0xFF6D597A);
  static const Color darkColor = Color(0xFF44364D);
  static const Color accentColor = Color(0xFFDDBEA9);
  static const Color backgroundColor = Color(0xFFF8F4F0);
  static const Color textColor = Color(0xFF332D35);

// ------------------------------------------------------------
// QUIZ ORDER
// ------------------------------------------------------------

  int _quizOrder(String id) {
    if (id == 'quiz001') return 1;
    if (id == 'quiz002') return 2;
    if (id == 'quiz003') return 3;
    return 99;
  }

// ------------------------------------------------------------
// QUIZ TITLE
// ------------------------------------------------------------

  String _getQuizTitle(
      QueryDocumentSnapshot<Map<String, dynamic>> quiz,
      ) {
    final data = quiz.data();

    final title = data['title'];

    if (title != null && title.toString().trim().isNotEmpty) {
      return title.toString().trim();
    }

// Safe fallback based on your Firebase quiz IDs.
    if (quiz.id == 'quiz001') {
      return 'Flutter';
    }

    if (quiz.id == 'quiz002') {
      return 'Cybersecurity';
    }

    if (quiz.id == 'quiz003') {
      return 'Web Development';
    }

    return 'Untitled Quiz';
  }

// ------------------------------------------------------------
// GET TOTAL QUESTIONS
// ------------------------------------------------------------

  int _getTotalQuestions(Map<String, dynamic> data) {
    final value = data['totalQuestions'] ?? data['totalQuestion'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

// ------------------------------------------------------------
// GET SCORE
// ------------------------------------------------------------

  double _getScore(Map<String, dynamic> data) {
    final value = data['score'];

    if (value is num) {
      return value.toDouble();
    }

    return 0.0;
  }

// ------------------------------------------------------------
// GET STUDENT NAME
// ------------------------------------------------------------

  Future<String> _getStudentName(
      Map<String, dynamic> data,
      ) async {
    // 1. If result already contains studentName, use it
    final resultStudentName =
    data['studentName']?.toString().trim();

    if (resultStudentName != null &&
        resultStudentName.isNotEmpty) {
      return resultStudentName;
    }

    // 2. Get student ID from result
    final studentId =
    data['studentId']?.toString().trim();

    if (studentId == null || studentId.isEmpty) {
      return 'Unknown Student';
    }

    try {
      // 3. Check users collection using document ID
      final userDoc = await _firestore
          .collection('users')
          .doc(studentId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();

        if (userData != null) {
          final nameFields = [
            userData['name'],
            userData['studentName'],
            userData['fullName'],
            userData['displayName'],
          ];

          for (final field in nameFields) {
            final name = field?.toString().trim();

            if (name != null && name.isNotEmpty) {
              return name;
            }
          }
        }
      }

      // 4. Check student collection using document ID
      final studentDoc = await _firestore
          .collection('student')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        final studentData = studentDoc.data();

        if (studentData != null) {
          final nameFields = [
            studentData['name'],
            studentData['studentName'],
            studentData['fullName'],
            studentData['displayName'],
          ];

          for (final field in nameFields) {
            final name = field?.toString().trim();

            if (name != null && name.isNotEmpty) {
              return name;
            }
          }
        }
      }

      // 5. Search users collection for matching UID
      final usersSnapshot =
      await _firestore.collection('users').get();

      for (final doc in usersSnapshot.docs) {
        final userData = doc.data();

        final possibleIds = [
          userData['uid'],
          userData['userId'],
          userData['studentId'],
          userData['authUid'],
        ];

        bool idMatches = false;

        for (final value in possibleIds) {
          if (value?.toString().trim() == studentId) {
            idMatches = true;
            break;
          }
        }

        if (idMatches) {
          final nameFields = [
            userData['name'],
            userData['studentName'],
            userData['fullName'],
            userData['displayName'],
          ];

          for (final field in nameFields) {
            final name = field?.toString().trim();

            if (name != null && name.isNotEmpty) {
              return name;
            }
          }
        }
      }

      // 6. Search student collection for matching UID
      final studentsSnapshot =
      await _firestore.collection('student').get();

      for (final doc in studentsSnapshot.docs) {
        final studentData = doc.data();

        final possibleIds = [
          studentData['uid'],
          studentData['userId'],
          studentData['studentId'],
          studentData['authUid'],
        ];

        bool idMatches = false;

        for (final value in possibleIds) {
          if (value?.toString().trim() == studentId) {
            idMatches = true;
            break;
          }
        }

        if (idMatches) {
          final nameFields = [
            studentData['name'],
            studentData['studentName'],
            studentData['fullName'],
            studentData['displayName'],
          ];

          for (final field in nameFields) {
            final name = field?.toString().trim();

            if (name != null && name.isNotEmpty) {
              return name;
            }
          }
        }
      }

      return 'Unknown Student';
    } catch (e) {
      debugPrint('Error finding student name: $e');
      return 'Unknown Student';
    }
  }

// ------------------------------------------------------------
// CALCULATE PERCENTAGE
// ------------------------------------------------------------

  double _getPercentage(
      double score,
      int total,
      ) {
    if (total <= 0) {
      return 0.0;
    }

    return (score / total) * 100.0;
  }

// ------------------------------------------------------------
// GET PASSING PERCENTAGE
// ------------------------------------------------------------

  double _getPassingPercentage(
      Map<String, dynamic> quizData,
      ) {
    final value = quizData['passingPercentage'];

    if (value is num) {
      return value.toDouble();
    }

    return 50.0;
  }

// ------------------------------------------------------------
// FORMAT DATE
// ------------------------------------------------------------

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    if (value is DateTime) {
      return '${value.day.toString().padLeft(2, '0')}/'
          '${value.month.toString().padLeft(2, '0')}/'
          '${value.year}';
    }

    return 'Not available';
  }

// ------------------------------------------------------------
// BUILD
// ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Student Results',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('quizzes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingCard();
          }

          if (snapshot.hasError) {
            return _errorCard(
              'Unable to load quizzes.\n${snapshot.error}',
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return _emptyCard(
              'No quizzes found.',
            );
          }

          final quizzes = snapshot.data!.docs.where((quiz) {
            return quiz.id == 'quiz001' ||
                quiz.id == 'quiz002' ||
                quiz.id == 'quiz003';
          }).toList();

          quizzes.sort(
                (a, b) => _quizOrder(a.id).compareTo(
              _quizOrder(b.id),
            ),
          );

          if (quizzes.isEmpty) {
            return _emptyCard(
              'No available quizzes found.',
            );
          }

          // Automatically select the first quiz.
          if (_selectedQuizId == null ||
              !quizzes.any(
                    (quiz) => quiz.id == _selectedQuizId,
              )) {
            _selectedQuizId = quizzes.first.id;
          }

          QueryDocumentSnapshot<Map<String, dynamic>> selectedQuiz =
              quizzes.first;

          // Avoid firstWhere because it can cause a Flutter Web
          // runtime type error with Firestore documents.
          for (final quiz in quizzes) {
            if (quiz.id == _selectedQuizId) {
              selectedQuiz = quiz;
              break;
            }
          }

          final selectedQuizData = selectedQuiz.data();

          final passingPercentage =
          _getPassingPercentage(selectedQuizData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
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
                    borderRadius: BorderRadius.circular(20),
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
                          Icons.assessment_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Results',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'View performance and exam results',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
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

                _sectionTitle(
                  'Select Exam',
                  Icons.quiz_outlined,
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.15),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedQuizId,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: primaryColor,
                      ),
                      items: quizzes.map((quiz) {
                        return DropdownMenuItem<String>(
                          value: quiz.id,
                          child: Text(
                            _getQuizTitle(quiz),
                            style: const TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
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
                ),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // EXAM INFORMATION
                // ------------------------------------------------

                _sectionTitle(
                  'Exam Information',
                  Icons.info_outline_rounded,
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        'Exam',
                        _getQuizTitle(selectedQuiz),
                        Icons.quiz_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _infoCard(
                        'Passing',
                        '${passingPercentage.toStringAsFixed(0)}%',
                        Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // ATTEMPTS
                // ------------------------------------------------

                StreamBuilder<
                    QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection('result')
                      .where(
                    'quizId',
                    isEqualTo: selectedQuiz.id,
                  )
                      .snapshots(),
                  builder: (context, attemptSnapshot) {
                    if (attemptSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _loadingCard();
                    }

                    if (attemptSnapshot.hasError) {
                      return _errorCard(
                        'Unable to load student attempts.\n'
                            '${attemptSnapshot.error}',
                      );
                    }

                    final attempts =
                        attemptSnapshot.data?.docs ?? [];

                    int passed = 0;
                    int failed = 0;
                    double totalPercentage = 0.0;

                    for (final attempt in attempts) {
                      final data = attempt.data();

                      final score = _getScore(data);
                      final total = _getTotalQuestions(data);

                      final double percentage =
                      _getPercentage(score, total);

                      totalPercentage += percentage;

                      if (percentage >= passingPercentage) {
                        passed++;
                      } else {
                        failed++;
                      }
                    }

                    final int totalAttempts = attempts.length;

                    final double averagePercentage =
                    totalAttempts > 0
                        ? totalPercentage / totalAttempts
                        : 0.0;

                    // --------------------------------------------
                    // STAT CARDS
                    // --------------------------------------------

                    Row statRow = Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Attempts',
                            totalAttempts.toString(),
                            Icons.people_alt_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            'Passed',
                            passed.toString(),
                            Icons.check_circle_outline,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            'Failed',
                            failed.toString(),
                            Icons.cancel_outlined,
                          ),
                        ),
                      ],
                    );

                    return Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(
                          'Performance Overview',
                          Icons.bar_chart_rounded,
                        ),

                        const SizedBox(height: 10),

                        statRow,

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor
                                  .withOpacity(0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: accentColor
                                      .withOpacity(0.35),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.percent_rounded,
                                  color: darkColor,
                                ),
                              ),
                              const SizedBox(width: 13),
                              const Expanded(
                                child: Text(
                                  'Average Percentage',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${averagePercentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ----------------------------------------
                        // STUDENT LIST
                        // ----------------------------------------

                        _sectionTitle(
                          'Student Results',
                          Icons.groups_outlined,
                        ),

                        const SizedBox(height: 10),

                        if (attempts.isEmpty)
                          _emptyCard(
                            'No students have attempted this exam yet.',
                          )
                        else
                          ...attempts.map(
                                (attempt) {
                              return _studentCard(
                                attempt,
                                passingPercentage,
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

// ------------------------------------------------------------
// STUDENT CARD
// ------------------------------------------------------------

  Widget _studentCard(
      QueryDocumentSnapshot<Map<String, dynamic>> attempt,
      double passingPercentage,
      ) {
    final data = attempt.data();

    final score = _getScore(data);

    final total = _getTotalQuestions(data);

    final double percentage =
    _getPercentage(score, total);

    final bool passed =
        percentage >= passingPercentage;

    final submittedAt = data['submittedAt'];

    return FutureBuilder<String>(
      future: _getStudentName(data),
      builder: (context, snapshot) {
        final studentName =
            snapshot.data ?? 'Loading...';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: primaryColor.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                    primaryColor.withOpacity(0.12),
                    child: const Icon(
                      Icons.person_rounded,
                      color: primaryColor,
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
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Score: ${score.toStringAsFixed(0)} / $total',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: passed
                          ? Colors.green.withOpacity(0.10)
                          : Colors.red.withOpacity(0.10),
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Text(
                      passed ? 'PASSED' : 'FAILED',
                      style: TextStyle(
                        color: passed
                            ? Colors.green
                            : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ONLY DATE ALIGNMENT CHANGED
              Row(
                children: [
                  Expanded(
                    child: _smallResultInfo(
                      'Percentage',
                      '${percentage.toStringAsFixed(1)}%',
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _smallResultInfo(
                        'Date',
                        _formatDate(submittedAt),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showResultDetails(
                      studentName: studentName,
                      score: score,
                      total: total,
                      percentage: percentage,
                      passed: passed,
                      submittedAt: submittedAt,
                      passingPercentage:
                      passingPercentage,
                    );
                  },
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'View Result Details',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(
                      color: primaryColor,
                    ),
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 11,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// ------------------------------------------------------------
// RESULT DETAILS
// ------------------------------------------------------------

  void _showResultDetails({
    required String studentName,
    required double score,
    required int total,
    required double percentage,
    required bool passed,
    required dynamic submittedAt,
    required double passingPercentage,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Result Details',
                    style: TextStyle(
                      color: darkColor,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _detailRow(
                    'Student',
                    studentName,
                  ),

                  _detailRow(
                    'Score',
                    '${score.toStringAsFixed(0)} / $total',
                  ),

                  _detailRow(
                    'Percentage',
                    '${percentage.toStringAsFixed(1)}%',
                  ),

                  _detailRow(
                    'Passing Percentage',
                    '${passingPercentage.toStringAsFixed(0)}%',
                  ),

                  _detailRow(
                    'Result',
                    passed ? 'Passed' : 'Failed',
                  ),

                  _detailRow(
                    'Submitted',
                    _formatDate(submittedAt),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: passed
                          ? Colors.green.withOpacity(0.10)
                          : Colors.red.withOpacity(0.10),
                      borderRadius:
                      BorderRadius.circular(13),
                    ),
                    child: Text(
                      passed
                          ? 'Student has successfully passed this exam.'
                          : 'Student did not reach the required passing percentage.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                        passed ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// ------------------------------------------------------------
// DETAIL ROW
// ------------------------------------------------------------

  Widget _detailRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

// ------------------------------------------------------------
// SMALL RESULT INFO
// ------------------------------------------------------------

  Widget _smallResultInfo(
      String title,
      String value,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

// ------------------------------------------------------------
// SECTION TITLE
// ------------------------------------------------------------

  Widget _sectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 21,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: darkColor,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

// ------------------------------------------------------------
// INFO CARD
// ------------------------------------------------------------

  Widget _infoCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: primaryColor.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: darkColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
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
// STAT CARD
// ------------------------------------------------------------

  Widget _statCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: primaryColor.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: darkColor,
              fontSize: 20,
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
    );
  }

// ------------------------------------------------------------
// LOADING CARD
// ------------------------------------------------------------

  Widget _loadingCard() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    );
  }

// ------------------------------------------------------------
// EMPTY CARD
// ------------------------------------------------------------

  Widget _emptyCard(
      String message,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            color: primaryColor,
            size: 45,
          ),
          const SizedBox(height: 12),
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

// ------------------------------------------------------------
// ERROR CARD
// ------------------------------------------------------------

  Widget _errorCard(
      String message,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 45,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
