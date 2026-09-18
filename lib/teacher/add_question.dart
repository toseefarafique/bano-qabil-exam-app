import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestion extends StatefulWidget {
  const AddQuestion({super.key});

  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  // ================= COLORS =================

  static const Color primary = Color(0xFF6D597A);
  static const Color dark = Color(0xFF44364D);
  static const Color accent = Color(0xFFDDBEA9);
  static const Color background = Color(0xFFF8F4F0);
  static const Color textColor = Color(0xFF332D35);

  // ================= CONTROLLERS =================

  final TextEditingController questionController =
      TextEditingController();

  final TextEditingController optionAController =
      TextEditingController();

  final TextEditingController optionBController =
      TextEditingController();

  final TextEditingController optionCController =
      TextEditingController();

  final TextEditingController optionDController =
      TextEditingController();

  final TextEditingController explanationController =
      TextEditingController();

  // ================= DROPDOWN VALUES =================

  String selectedSubject = 'Flutter';
  String selectedDifficulty = 'Easy';
  String correctAnswer = 'A';

  // Loading state
  bool isSaving = false;

  @override
  void dispose() {
    questionController.dispose();
    optionAController.dispose();
    optionBController.dispose();
    optionCController.dispose();
    optionDController.dispose();
    explanationController.dispose();

    super.dispose();
  }

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
          'Add Question',
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
                const Text(
                  'Create New Question',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Add an MCQ to your question bank.',
                  style: TextStyle(
                    color: textColor.withOpacity(0.60),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 22),

                // ================= SUBJECT + DIFFICULTY =================

                Row(
                  children: [
                    Expanded(
                      child: _dropdownField(
                        label: 'Subject',
                        value: selectedSubject,
                        items: const [
                          'Flutter',
                          'Web',
                          'Cybersecurity',

                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedSubject = value!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _dropdownField(
                        label: 'Difficulty',
                        value: selectedDifficulty,
                        items: const [
                          'Easy',
                          'Medium',
                          'Hard',
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedDifficulty = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ================= QUESTION =================

                _label('Question'),

                const SizedBox(height: 7),

                _textField(
                  controller: questionController,
                  hint: 'Enter your question...',
                  maxLines: 4,
                ),

                const SizedBox(height: 20),

                // ================= OPTIONS =================

                const Text(
                  'Answer Options',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                _optionField(
                  letter: 'A',
                  controller: optionAController,
                ),

                const SizedBox(height: 10),

                _optionField(
                  letter: 'B',
                  controller: optionBController,
                ),

                const SizedBox(height: 10),

                _optionField(
                  letter: 'C',
                  controller: optionCController,
                ),

                const SizedBox(height: 10),

                _optionField(
                  letter: 'D',
                  controller: optionDController,
                ),

                const SizedBox(height: 20),

                // ================= CORRECT ANSWER =================

                _label('Correct Answer'),

                const SizedBox(height: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
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
                      value: correctAnswer,
                      isExpanded: true,

                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: primary,
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: 'A',
                          child: Text('A'),
                        ),
                        DropdownMenuItem(
                          value: 'B',
                          child: Text('B'),
                        ),
                        DropdownMenuItem(
                          value: 'C',
                          child: Text('C'),
                        ),
                        DropdownMenuItem(
                          value: 'D',
                          child: Text('D'),
                        ),
                      ],

                      onChanged: (value) {
                        setState(() {
                          correctAnswer = value!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= EXPLANATION =================

                _label('Explanation'),

                const SizedBox(height: 7),

                _textField(
                  controller: explanationController,
                  hint:
                      'Explain why this answer is correct...',
                  maxLines: 4,
                ),

                const SizedBox(height: 25),

                // ================= SAVE BUTTON =================

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    onPressed:
                        isSaving ? null : _saveQuestion,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),

                    icon: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.save_outlined,
                          ),

                    label: Text(
                      isSaving
                          ? 'Saving...'
                          : 'Save Question',

                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= DROPDOWN =================

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
          padding: const EdgeInsets.symmetric(
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

  // ================= OPTION FIELD =================

  Widget _optionField({
    required String letter,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 50,

          decoration: BoxDecoration(
            color: primary,
            borderRadius:
                BorderRadius.circular(10),
          ),

          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _textField(
            controller: controller,
            hint: 'Option $letter',
          ),
        ),
      ],
    );
  }

  // ================= TEXT FIELD =================

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,

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

          borderSide:
              const BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ================= LABEL =================

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

  // ================= SAVE QUESTION =================

  Future<void> _saveQuestion() async {
    // Check question
    if (questionController.text.trim().isEmpty) {
      _showMessage(
        'Please enter the question.',
      );
      return;
    }

    // Check options
    if (optionAController.text.trim().isEmpty ||
        optionBController.text.trim().isEmpty ||
        optionCController.text.trim().isEmpty ||
        optionDController.text.trim().isEmpty) {
      _showMessage(
        'Please fill in all four options.',
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Convert A/B/C/D into Firebase index
      int correctAnswerIndex = 0;

      if (correctAnswer == 'A') {
        correctAnswerIndex = 0;
      } else if (correctAnswer == 'B') {
        correctAnswerIndex = 1;
      } else if (correctAnswer == 'C') {
        correctAnswerIndex = 2;
      } else if (correctAnswer == 'D') {
        correctAnswerIndex = 3;
      }

      // Options array
      final List<String> options = [
        optionAController.text.trim(),
        optionBController.text.trim(),
        optionCController.text.trim(),
        optionDController.text.trim(),
      ];

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('questions')
          .add({
        'question':
            questionController.text.trim(),

        'options': options,

        'correctAnswer1':
            correctAnswerIndex,

        'quizId': 'quiz001',

        'subject':
            selectedSubject,

        'difficulty':
            selectedDifficulty,

        'explanation':
            explanationController.text.trim(),

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Question added successfully!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving question: $e',
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

  // ================= MESSAGE =================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}