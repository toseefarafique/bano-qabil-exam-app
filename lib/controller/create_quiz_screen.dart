import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedSubject;
  String? selectedClass;
  String quizType = 'Practice';
  int selectedTime = 20;

  bool isSaving = false;

  final List<String> subjects = [
    'Flutter',
    'Web Development',
    'Cybersecurity',
    'English',
    'Islamiat',
  ];

  final List<String> classes = ['BSCS-6A', 'BSCS-6B', 'BSIT-6A'];

  final List<int> timeOptions = [10, 15, 20, 30, 45, 60];

  /// Selected question IDs
  final Set<String> selectedQuestions = {};

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // CREATE QUIZ
  // ----------------------------------------------------------

  Future<void> createQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedSubject == null) {
      showMessage('Please select a subject.');
      return;
    }

    if (selectedClass == null) {
      showMessage('Please select a class/batch.');
      return;
    }

    if (selectedQuestions.length < 10) {
      showMessage('Please select at least 10 questions.');
      return;
    }

    if (selectedQuestions.length > 20) {
      showMessage('You can select maximum 20 questions.');
      return;
    }

    final User? user = _auth.currentUser;

    if (user == null) {
      showMessage('Teacher is not logged in.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _firestore.collection('quizzes').add({
        'title': _titleController.text.trim(),
        'subject': selectedSubject,
        'questionIds': selectedQuestions.toList(),
        'questionCount': selectedQuestions.length,
        'timeLimit': selectedTime,
        'type': quizType.toLowerCase(),
        'assignedClass': selectedClass,
        'status': quizType == 'Official' ? 'draft' : 'published',
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage(
        quizType == 'Official'
            ? 'Official exam created as Draft.'
            : 'Quiz created and assigned successfully.',
        success: true,
      );

      _titleController.clear();

      setState(() {
        selectedSubject = null;
        selectedClass = null;
        selectedQuestions.clear();
        quizType = 'Practice';
        selectedTime = 20;
      });
    } catch (e) {
      showMessage('Error creating quiz: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ----------------------------------------------------------
  // MESSAGE
  // ----------------------------------------------------------

  void showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? const Color(0xFF6D597A) : Colors.redAccent,
      ),
    );
  }

  // ----------------------------------------------------------
  // QUESTION SELECTION
  // ----------------------------------------------------------

  Future<void> openQuestionSelection() async {
    if (selectedSubject == null) {
      showMessage('Please select a subject first.');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8F4F0),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Select Questions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF44364D),
                    ),
                  ),

                  Text(
                    '${selectedQuestions.length} / 20 selected',
                    style: const TextStyle(
                      color: Color(0xFF6D597A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('questions')
                          .where('subject', isEqualTo: selectedSubject)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6D597A),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Unable to load questions.'),
                          );
                        }

                        final questions = snapshot.data?.docs ?? [];

                        if (questions.isEmpty) {
                          return const Center(
                            child: Text(
                              'No questions found for this subject.',
                              style: TextStyle(
                                color: Color(0xFF44364D),
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            final question = questions[index];

                            final questionId = question.id;

                            final data =
                                question.data() as Map<String, dynamic>;

                            final questionText =
                                data['question'] ??
                                data['stem'] ??
                                'Question ${index + 1}';

                            final difficulty = data['difficulty'] ?? 'Medium';

                            final isSelected = selectedQuestions.contains(
                              questionId,
                            );

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 10),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: CheckboxListTile(
                                value: isSelected,
                                activeColor: const Color(0xFF6D597A),
                                checkColor: Colors.white,
                                onChanged: (value) {
                                  setModalState(() {
                                    if (value == true) {
                                      if (selectedQuestions.length < 20) {
                                        selectedQuestions.add(questionId);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Maximum 20 questions allowed.',
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      selectedQuestions.remove(questionId);
                                    }
                                  });

                                  setState(() {});
                                },
                                title: Text(
                                  questionText.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF332D35),
                                  ),
                                ),
                                subtitle: Text(
                                  'Difficulty: $difficulty',
                                  style: const TextStyle(
                                    color: Color(0xFF6D597A),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D597A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'DONE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),

      appBar: AppBar(
        title: const Text(
          'Create Quiz',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6D597A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // HEADER
              // ------------------------------------------------

              const Text(
                'Create New Quiz',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF44364D),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Create a quiz and assign it to your class.',
                style: TextStyle(fontSize: 14, color: Color(0xFF332D35)),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // QUIZ TITLE
              // ------------------------------------------------
              const Text(
                'Quiz Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF44364D),
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _titleController,
                decoration: inputDecoration('Enter quiz title', Icons.title),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter quiz title.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // SUBJECT
              // ------------------------------------------------
              const Text(
                'Subject',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF44364D),
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: inputDecoration('Select Subject', Icons.menu_book),
                items: subjects.map((subject) {
                  return DropdownMenuItem(value: subject, child: Text(subject));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubject = value;
                    selectedQuestions.clear();
                  });
                },
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // QUESTIONS
              // ------------------------------------------------
              const Text(
                'Questions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF44364D),
                ),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: openQuestionSelection,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDDBEA9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.library_books_outlined,
                        color: Color(0xFF6D597A),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          selectedQuestions.isEmpty
                              ? 'Select 10–20 questions'
                              : '${selectedQuestions.length} questions selected',
                          style: const TextStyle(
                            color: Color(0xFF332D35),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF6D597A),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // TIME LIMIT
              // ------------------------------------------------
              const Text(
                'Time Limit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF44364D),
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<int>(
                value: selectedTime,
                decoration: inputDecoration(
                  'Select time',
                  Icons.timer_outlined,
                ),
                items: timeOptions.map((time) {
                  return DropdownMenuItem(
                    value: time,
                    child: Text('$time minutes'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedTime = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // QUIZ TYPE
              // ------------------------------------------------
              const Text(
                'Quiz Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF44364D),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'Practice',
                      groupValue: quizType,
                      activeColor: const Color(0xFF6D597A),
                      title: const Text('Practice Quiz'),
                      subtitle: const Text('Students can practice freely.'),
                      onChanged: (value) {
                        setState(() {
                          quizType = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      value: 'Official',
                      groupValue: quizType,
                      activeColor: const Color(0xFF6D597A),
                      title: const Text('Official Exam'),
                      subtitle: const Text('Requires controller approval.'),
                      onChanged: (value) {
                        setState(() {
                          quizType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // CLASS
              // ------------------------------------------------
              const Text(
                'Class / Batch',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF44364D),
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: inputDecoration(
                  'Select Class',
                  Icons.groups_outlined,
                ),
                items: classes.map((className) {
                  return DropdownMenuItem(
                    value: className,
                    child: Text(className),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClass = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // CREATE BUTTON
              // ------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isSaving ? null : createQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D597A),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFDDBEA9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'CREATE & ASSIGN QUIZ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // INPUT DECORATION
  // ----------------------------------------------------------

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF6D597A)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDBEA9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDBEA9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6D597A), width: 2),
      ),
    );
  }
}
