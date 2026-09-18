
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateQuiz extends StatefulWidget {
  const CreateQuiz({super.key});

  @override
  State<CreateQuiz> createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  // ================= COLORS =================

  static const Color primary = Color(0xFF6D597A);
  static const Color dark = Color(0xFF44364D);
  static const Color accent = Color(0xFFDDBEA9);
  static const Color background = Color(0xFFF8F4F0);
  static const Color textColor = Color(0xFF332D35);

  // ================= CONTROLLERS =================

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController timeController =
      TextEditingController();

  // ================= VARIABLES =================

  String selectedSubject = 'Flutter';
  String selectedType = 'Practice';
  String selectedBatch = 'Batch 1';

  bool isSaving = false;

  // Selected Firebase question document IDs
  final List<String> selectedQuestionIds = [];

  // ================= SUBJECTS =================

  final List<String> subjects = [
    'Flutter',
    'Web',
    'Cybersecurity',
    'English',
    'Islamiat',
  ];

  // ================= DISPOSE =================

  @override
  void dispose() {
    titleController.dispose();
    timeController.dispose();
    super.dispose();
  }

  // ============================================================
  // SELECT QUESTIONS
  // ============================================================

  Future<void> _selectQuestions() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('questions')
            .where(
              'subject',
              isEqualTo: selectedSubject,
            )
            .get();

    if (!mounted) return;

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> questions =
        snapshot.docs;

    final List<String> tempSelected =
        List<String>.from(selectedQuestionIds);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Select Questions',
                style: TextStyle(
                  color: dark,
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SizedBox(
                width: 550,
                height: 450,
                child: questions.isEmpty
                    ? const Center(
                        child: Text(
                          'No questions found for this subject.',
                        ),
                      )
                    : ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final doc = questions[index];

                          final data = doc.data();

                          final question =
                              (data['question'] ?? 'No question')
                                  .toString();

                          final isSelected =
                              tempSelected.contains(doc.id);

                          return CheckboxListTile(
                            value: isSelected,
                            activeColor: primary,

                            title: Text(
                              question,
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 14,
                              ),
                            ),

                            subtitle: Text(
                              doc.id,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),

                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  if (!tempSelected
                                      .contains(doc.id)) {
                                    tempSelected.add(doc.id);
                                  }
                                } else {
                                  tempSelected.remove(doc.id);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedQuestionIds
                        ..clear()
                        ..addAll(tempSelected);
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SAVE QUIZ
  // ============================================================

  Future<void> _saveQuiz(bool publish) async {
    // ---------- TITLE VALIDATION ----------

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter quiz title.',
          ),
        ),
      );

      return;
    }

    // ---------- TIME VALIDATION ----------

    if (timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter time limit.',
          ),
        ),
      );

      return;
    }

    final int? timeLimit =
        int.tryParse(timeController.text.trim());

    if (timeLimit == null || timeLimit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid time in minutes.',
          ),
        ),
      );

      return;
    }

    // ---------- QUESTION VALIDATION ----------

    if (selectedQuestionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one question.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // ---------- FIRESTORE DATA ----------

      await FirebaseFirestore.instance
          .collection('quizzes')
          .add({
        'title': titleController.text.trim(),

        'subject': selectedSubject,

        'type': selectedType,

        'timeLimit': timeLimit,

        'assignTo': selectedBatch,

        'questionIds': selectedQuestionIds,

        'status': publish ? 'Published' : 'Draft',

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            publish
                ? 'Quiz published successfully!'
                : 'Quiz saved as draft!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving quiz: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ================= APP BAR =================

      appBar: AppBar(
        backgroundColor: dark,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Create Quiz / Exam',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ================= BODY =================

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 650,
          ),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ================= TITLE =================

                const Text(
                  'Create New Quiz',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Create a quiz or exam for your students.',
                  style: TextStyle(
                    color: textColor.withOpacity(0.60),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 22),

                // ================= QUIZ TITLE =================

                _label('Quiz / Exam Title'),

                const SizedBox(height: 7),

                _textField(
                  controller: titleController,
                  hint: 'e.g. Flutter Basic Quiz',
                ),

                const SizedBox(height: 18),

                // ================= SUBJECT + TYPE =================

                Row(
                  children: [

                    Expanded(
                      child: _dropdownField(
                        label: 'Subject',
                        value: selectedSubject,
                        items: subjects,
                        onChanged: (value) {
                          setState(() {
                            selectedSubject = value!;

                            // Questions from the previous
                            // subject are no longer selected.
                            selectedQuestionIds.clear();
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _dropdownField(
                        label: 'Type',
                        value: selectedType,
                        items: const [
                          'Practice',
                          'Official',
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ================= TIME + BATCH =================

                Row(
                  children: [

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          _label('Time Limit'),

                          const SizedBox(height: 7),

                          _textField(
                            controller: timeController,
                            hint: 'Minutes',
                            keyboardType:
                                TextInputType.number,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _dropdownField(
                        label: 'Assign To',
                        value: selectedBatch,
                        items: const [
                          'Batch 1',
                          'Batch 2',
                          'Batch 3',
                          'All Students',
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedBatch = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ====================================================
                // SELECT QUESTIONS CARD
                // ====================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),

                    border: Border.all(
                      color: accent.withOpacity(0.5),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: dark.withOpacity(0.05),
                        blurRadius: 8,
                        offset:
                            const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // ================= HEADER =================

                      Row(
                        children: [

                          Container(
                            width: 44,
                            height: 44,

                            decoration: BoxDecoration(
                              color: background,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),

                            child: const Icon(
                              Icons.library_books_outlined,
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
                                  'Select Questions',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 3),

                                Text(
                                  'Choose questions from your question bank.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ================= SELECTED COUNT =================

                      Container(
                        padding:
                            const EdgeInsets.all(13),

                        decoration: BoxDecoration(
                          color: background,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,

                          children: [

                            const Row(
                              children: [

                                Icon(
                                  Icons.quiz_outlined,
                                  color: primary,
                                  size: 21,
                                ),

                                SizedBox(width: 8),

                                Text(
                                  'Questions Selected',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),

                              child: Text(
                                '${selectedQuestionIds.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= SELECT BUTTON =================

                      SizedBox(
                        width: double.infinity,
                        height: 46,

                        child: OutlinedButton.icon(
                          onPressed: _selectQuestions,

                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: primary,
                          ),

                          label: const Text(
                            'Select Questions',
                            style: TextStyle(
                              color: primary,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          style:
                              OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: primary,
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
                ),

                const SizedBox(height: 25),

                // ====================================================
                // SAVE + PUBLISH
                // ====================================================

                Row(
                  children: [

                    // ================= SAVE DRAFT =================

                    Expanded(
                      child: SizedBox(
                        height: 50,

                        child: OutlinedButton(
                          onPressed:
                              isSaving
                                  ? null
                                  : () => _saveQuiz(false),

                          style:
                              OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: primary,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),

                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save as Draft',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ================= PUBLISH =================

                    Expanded(
                      child: SizedBox(
                        height: 50,

                        child:
                            ElevatedButton.icon(
                          onPressed:
                              isSaving
                                  ? null
                                  : () => _saveQuiz(true),

                          icon: const Icon(
                            Icons.publish,
                          ),

                          label: const Text(
                            'Publish',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor:
                                Colors.white,
                            elevation: 0,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN FIELD
  // ============================================================

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        _label(label),

        const SizedBox(height: 7),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
          ),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(12),

            border: Border.all(
              color: accent.withOpacity(0.6),
            ),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,

              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: primary,
              ),

              style: const TextStyle(
                color: textColor,
                fontSize: 13,
              ),

              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),

              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,

      style: const TextStyle(
        color: textColor,
        fontSize: 14,
      ),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 13,
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding:
            const EdgeInsets.all(14),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),

          borderSide: BorderSide(
            color: accent.withOpacity(0.5),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),

          borderSide: const BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _label(String text) {
    return Text(
      text,

      style: const TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}



