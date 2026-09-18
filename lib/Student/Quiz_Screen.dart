import 'Result_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // ================= QUESTIONS =================

  List<Map<String, dynamic>> questions = [];

  int currentQuestion = 0;
  bool isLoading = true;

  Future<List<Map<String, dynamic>>> getQuestions() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where('quizId', isEqualTo: widget.quizId)
        .orderBy(FieldPath.documentId)
        .get();

    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }

  Future<void> loadQuestions() async {
    try {
      List<Map<String, dynamic>> data = await getQuestions();

      if (mounted) {
        setState(() {
          questions = data;
          userAnswers = List<int?>.filled(data.length, null);
          submittedQuestions = List<bool>.filled(data.length, false);
          flaggedQuestions = List<bool>.filled(data.length, false);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ERROR LOADING QUESTIONS: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================= ANSWERS =================

  int? selectedOption;

  int score = 0;

  List<int?> userAnswers = [];
  List<bool> submittedQuestions = [];
  List<bool> flaggedQuestions = [];

  // ================= TIMER =================

  Timer? _timer;

  Duration _remainingTime = const Duration(minutes: 30);
  Duration _timeUsed = Duration.zero;

  DateTime? _startTime;

  // Prevents duplicate submission
  bool _examSubmitted = false;

  @override
  void initState() {
    super.initState();

    loadQuestions();

    _startTime = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _examSubmitted) {
        timer.cancel();
        return;
      }

      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);

          if (_startTime != null) {
            _timeUsed = DateTime.now().difference(_startTime!);
          }
        });
      } else {
        _submitExam();
      }
    });
  }

  String formatTime(Duration duration) {
    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    }

    return "$minutes:$seconds";
  }

  // ================= SUBMIT EXAM =================

  Future<void> _submitExam() async {
    if (_examSubmitted) {
      return;
    }

    _examSubmitted = true;

    _timer?.cancel();

    if (_startTime != null) {
      _timeUsed = DateTime.now().difference(_startTime!);

      if (_timeUsed > const Duration(minutes: 30)) {
        _timeUsed = const Duration(minutes: 30);
      }
    }

    debugPrint("Time Used: ${formatTime(_timeUsed)}");

    // Save the result even if the timer finishes.
    await saveResult();

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: score,
          totalQuestions: questions.length,
          timeUsed: _timeUsed,
          quizId: widget.quizId,
          userAnswers: userAnswers,
        ),
      ),
    );
  }

  // ================= SAVE RESULT =================

  Future<bool> saveResult() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("Student not logged in");
      return false;
    }

    final int total = questions.length;

    final int percentage =
    total == 0 ? 0 : ((score / total) * 100).round();

    String studentName = '';

    try {
      // --------------------------------------------------
      // 1. First try Firebase Authentication displayName
      // --------------------------------------------------
      if (user.displayName != null &&
          user.displayName!.trim().isNotEmpty) {
        studentName = user.displayName!.trim();
      }

      // --------------------------------------------------
      // 2. Get student information from users collection
      // --------------------------------------------------
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();

        if (data != null) {
          final name = data['name']?.toString().trim();
          final studentNameField =
          data['studentName']?.toString().trim();
          final fullName =
          data['fullName']?.toString().trim();
          final displayName =
          data['displayName']?.toString().trim();

          if (name != null && name.isNotEmpty) {
            studentName = name;
          } else if (studentNameField != null &&
              studentNameField.isNotEmpty) {
            studentName = studentNameField;
          } else if (fullName != null &&
              fullName.isNotEmpty) {
            studentName = fullName;
          } else if (displayName != null &&
              displayName.isNotEmpty) {
            studentName = displayName;
          }
        }
      }

      // --------------------------------------------------
      // 3. Final fallback
      // --------------------------------------------------
      if (studentName.isEmpty) {
        studentName = user.email ?? 'Student';
      }

      // --------------------------------------------------
      // 4. Save result WITH studentName
      // --------------------------------------------------
      await FirebaseFirestore.instance.collection('result').add({
        'studentId': user.uid,
        'studentName': studentName,
        'quizId': widget.quizId,
        'score': score,
        'totalQuestion': total,
        'totalQuestions': total,
        'percentage': percentage,
        'date': Timestamp.now(),
        'timeUsed': _timeUsed.inSeconds,
      });

      debugPrint("=================================");
      debugPrint("RESULT SAVED SUCCESSFULLY");
      debugPrint("Student Name: $studentName");
      debugPrint("Student ID: ${user.uid}");
      debugPrint("Quiz ID: ${widget.quizId}");
      debugPrint("Score: $score/$total");
      debugPrint("=================================");

      return true;
    } catch (e) {
      debugPrint("ERROR SAVING RESULT: $e");
      return false;
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("No Questions Found")));
    }

    int correct = questions[currentQuestion]['correctAnswer'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6F435C),

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Color(0xFFFFFBF0), size: 30),
        ),

        title: Text(
          "Question Player",
          style: TextStyle(
            fontSize: 25,
            color: Color(0xFFFFFBF0),
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.timer, color: Color(0xFFFFFBF0), size: 28),
                  SizedBox(width: 5),
                  Text(
                    formatTime(_remainingTime),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFFFFFBF0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFFFFBF0),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${currentQuestion + 1}/${questions.length}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF6F435C),
                  ),
                ),

                SizedBox(height: 4),

                LinearProgressIndicator(
                  value: (currentQuestion + 1) / questions.length,
                  minHeight: 8,
                  color: Color(0xFF6F435C),
                  borderRadius: BorderRadius.circular(15),
                ),

                SizedBox(height: 20),

                Text(
                  "Q${currentQuestion + 1}: ${questions[currentQuestion]['question']}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                // ================= A =================
                GestureDetector(
                  onTap: submittedQuestions[currentQuestion]
                      ? null
                      : () {
                          setState(() {
                            selectedOption = 0;
                            userAnswers[currentQuestion] = 0;
                          });
                        },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selectedOption == 0
                          ? const Color(0xFFE8D9E3)
                          : Colors.transparent,
                      border: Border.all(color: Color(0xFF6F435C)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "A. ${questions[currentQuestion]['options'][0]}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // ================= B =================
                GestureDetector(
                  onTap: submittedQuestions[currentQuestion]
                      ? null
                      : () {
                          setState(() {
                            selectedOption = 1;
                            userAnswers[currentQuestion] = 1;
                          });
                        },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selectedOption == 1
                          ? const Color(0xFFE8D9E3)
                          : Colors.transparent,
                      border: Border.all(color: Color(0xFF6F435C)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "B. ${questions[currentQuestion]['options'][1]}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // ================= C =================
                GestureDetector(
                  onTap: submittedQuestions[currentQuestion]
                      ? null
                      : () {
                          setState(() {
                            selectedOption = 2;
                            userAnswers[currentQuestion] = 2;
                          });
                        },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selectedOption == 2
                          ? const Color(0xFFE8D9E3)
                          : Colors.transparent,
                      border: Border.all(color: Color(0xFF6F435C)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "C. ${questions[currentQuestion]['options'][2]}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // ================= D =================
                GestureDetector(
                  onTap: submittedQuestions[currentQuestion]
                      ? null
                      : () {
                          setState(() {
                            selectedOption = 3;
                            userAnswers[currentQuestion] = 3;
                          });
                        },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selectedOption == 3
                          ? const Color(0xFFE8D9E3)
                          : Colors.transparent,
                      border: Border.all(color: Color(0xFF6F435C)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "D. ${questions[currentQuestion]['options'][3]}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                // ================= FLAG / JUMP =================
                Padding(
                  padding: EdgeInsets.all(40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            flaggedQuestions[currentQuestion] =
                                !flaggedQuestions[currentQuestion];
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            241,
                            232,
                            243,
                          ),
                          fixedSize: Size(130, 50),
                          side: BorderSide(
                            color: Color(0xFF6F435C),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                flaggedQuestions[currentQuestion]
                                    ? Icons.flag
                                    : Icons.outlined_flag,
                                color: Color(0xFF6F435C),
                                size: 25,
                              ),
                              Text(
                                "Flag",
                                style: TextStyle(
                                  color: Color(0xFF6F435C),
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 30),

                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Jump To Question"),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: questions.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                    itemBuilder: (context, index) {
                                      return ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);

                                          setState(() {
                                            currentQuestion = index;
                                            selectedOption = userAnswers[index];
                                          });
                                        },
                                        child: Text("${index + 1}"),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        style: TextButton.styleFrom(
                          fixedSize: Size(130, 50),
                          backgroundColor: const Color.fromARGB(
                            255,
                            240,
                            226,
                            243,
                          ),
                          side: BorderSide(
                            color: Color(0xFF6F435C),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: Color(0xFF6F435C),
                                size: 25,
                              ),
                              Text(
                                "Jump To",
                                style: TextStyle(
                                  color: Color(0xFF6F435C),
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                // ================= PREVIOUS / NEXT =================
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: currentQuestion > 0
                            ? () {
                                setState(() {
                                  currentQuestion--;

                                  selectedOption = userAnswers[currentQuestion];
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6F435C),
                          foregroundColor: Color(0xFFFFFBF0),
                          elevation: 2,
                          fixedSize: Size(160, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Previous",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(width: 80),

                      ElevatedButton(
                        onPressed: () async {
                          if (_examSubmitted) {
                            return;
                          }

                          // Already submitted question
                          if (submittedQuestions[currentQuestion]) {
                            if (currentQuestion < questions.length - 1) {
                              setState(() {
                                currentQuestion++;
                                selectedOption = userAnswers[currentQuestion];
                              });
                            }

                            return;
                          }

                          // No answer selected
                          if (selectedOption == null) {
                            debugPrint("Please select an option");
                            return;
                          }

                          // Check answer
                          if (selectedOption == correct) {
                            score++;
                            debugPrint("Correct Answer");
                          } else {
                            debugPrint("Wrong Answer");
                          }

                          submittedQuestions[currentQuestion] = true;

                          // Go to next question
                          if (currentQuestion < questions.length - 1) {
                            setState(() {
                              currentQuestion++;
                              selectedOption = null;
                            });
                          } else {
                            // Final question
                            _examSubmitted = true;
                            _timer?.cancel();

                            if (_startTime != null) {
                              _timeUsed = DateTime.now().difference(
                                _startTime!,
                              );

                              if (_timeUsed > const Duration(minutes: 30)) {
                                _timeUsed = const Duration(minutes: 30);
                              }
                            }

                            await saveResult();

                            if (!mounted) {
                              return;
                            }

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultScreen(
                                  score: score,
                                  totalQuestions: questions.length,
                                  timeUsed: _timeUsed,
                                  quizId: widget.quizId,
                                  userAnswers: userAnswers,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6F435C),
                          foregroundColor: Color(0xFFFFFBF0),
                          elevation: 2,
                          fixedSize: Size(160, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
