import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_quiz.dart';

class ManageQuizzes extends StatefulWidget {
  const ManageQuizzes({super.key});

  @override
  State<ManageQuizzes> createState() => _ManageQuizzesState();
}

class _ManageQuizzesState extends State<ManageQuizzes> {
  // ================= COLORS =================
  static const Color plum = Color(0xFF6D597A);
  static const Color darkPlum = Color(0xFF44364D);
  static const Color accent = Color(0xFFDDBEA9);
  static const Color cream = Color(0xFFF8F4F0);
  static const Color textColor = Color(0xFF332D35);

  // ================= DELETE QUIZ =================
  Future<void> _deleteQuiz(String quizId) async {
    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz deleted successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting quiz: $e'),
        ),
      );
    }
  }

  // ================= CONFIRM DELETE =================
  Future<void> _confirmDelete(
    String quizId,
    String title,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Quiz?'),
          content: Text(
            'Are you sure you want to delete "$title"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteQuiz(quizId);
    }
  }

  // ================= PUBLISH QUIZ =================
  Future<void> _publishQuiz(String quizId) async {
    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .update({
        'status': 'Published',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz published successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error publishing quiz: $e'),
        ),
      );
    }
  }

  // ================= EDIT QUIZ =================
  void _editQuiz(
    String quizId,
    Map<String, dynamic> data,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuiz(
          quizId: quizId,
          quizData: data,
        ),
      ),
    );
  }

  // ================= QUIZ CARD =================
  Widget _quizCard(
    String quizId,
    Map<String, dynamic> data,
  ) {
    final String title =
        data['title']?.toString() ?? 'Untitled Quiz';

    final String subject =
        data['subject']?.toString() ?? 'Unknown';

    final String type =
        data['type']?.toString() ?? 'Practice';

    final String status =
        data['status']?.toString() ?? 'Draft';

    final String assignTo =
        data['assignTo']?.toString() ?? 'All Students';

    final int timeLimit =
        data['timeLimit'] is int
            ? data['timeLimit']
            : int.tryParse(
                  data['timeLimit']?.toString() ?? '0',
                ) ??
                0;

    final List questionIds =
        data['questionIds'] is List
            ? data['questionIds']
            : [];

    final bool isPublished = status == 'Published';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TITLE + STATUS =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPublished
                        ? Colors.green.withOpacity(0.12)
                        : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isPublished
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ================= SUBJECT =================
            _infoRow(
              Icons.menu_book_outlined,
              'Subject',
              subject,
            ),

            const SizedBox(height: 9),

            // ================= TYPE =================
            _infoRow(
              Icons.quiz_outlined,
              'Type',
              type,
            ),

            const SizedBox(height: 9),

            // ================= TIME =================
            _infoRow(
              Icons.access_time,
              'Time Limit',
              '$timeLimit minutes',
            ),

            const SizedBox(height: 9),

            // ================= QUESTIONS =================
            _infoRow(
              Icons.help_outline,
              'Questions',
              '${questionIds.length}',
            ),

            const SizedBox(height: 9),

            // ================= ASSIGNED TO =================
            _infoRow(
              Icons.people_outline,
              'Assigned To',
              assignTo,
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 12),

            // ================= ACTIONS =================
            const Text(
              'Actions',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // ================= EDIT QUIZ BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _editQuiz(
                    quizId,
                    data,
                  );
                },
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                label: const Text(
                  'Edit Quiz',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: plum,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ================= PUBLISH BUTTON =================
            if (!isPublished)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _publishQuiz(quizId);
                  },
                  icon: const Icon(
                    Icons.publish,
                  ),
                  label: const Text(
                    'Publish',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkPlum,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

            if (!isPublished)
              const SizedBox(height: 10),

            // ================= DELETE BUTTON =================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _confirmDelete(
                    quizId,
                    title,
                  );
                },
                icon: const Icon(
                  Icons.delete_outline,
                ),
                label: const Text(
                  'Delete',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INFO ROW =================
  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: plum,
        ),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            color: textColor.withOpacity(0.60),
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: darkPlum,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manage Quizzes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ================= FIRESTORE =================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder: (context, snapshot) {
          // ================= LOADING =================
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: plum,
              ),
            );
          }

          // ================= ERROR =================
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Something went wrong:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          // ================= NO DATA =================
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 65,
                    color: plum.withOpacity(0.5),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'No quizzes found',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Create a quiz first to manage it here.',
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          final quizzes = snapshot.data!.docs;

          // ================= QUIZ LIST =================
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1000,
              ),
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  // ================= HEADER =================
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Quizzes',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              accent.withOpacity(0.35),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${quizzes.length} Quiz${quizzes.length == 1 ? '' : 'zes'}',
                          style: const TextStyle(
                            color: darkPlum,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ================= QUIZ CARDS =================
                  ...quizzes.map(
                    (doc) {
                      final data =
                          doc.data()
                              as Map<String, dynamic>;

                      return _quizCard(
                        doc.id,
                        data,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}