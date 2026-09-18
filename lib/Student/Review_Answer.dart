import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewAnswer extends StatefulWidget {
  final String quizId;
  final List<int?> userAnswers;
  const ReviewAnswer({
    super.key,
    required this.quizId,
    required this.userAnswers,
  });

  @override
  State<ReviewAnswer> createState() => _ReviewAnswerState();
}

class _ReviewAnswerState extends State<ReviewAnswer> {

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
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6F435C),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFFFBF0),
            size: 30,
          ),
        ),
        title: const Text(
          "Review Answers",
          style: TextStyle(
            color: Color(0xFFFFFBF0),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getQuestions(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No Questions Found"),
            );
          }

          final questions = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
            ),

            child: Column(
              children: List.generate(
                questions.length,
                (index) {
                  final question = questions[index];

                  final questionText =
                      question['question'] ?? '';

                  final options =
                      List<String>.from(question['options'] ?? []);

                  final correctAnswer =
                      question['correctAnswer'] ?? 0;

                  final userAnswer =
                  index < widget.userAnswers.length
                       ? widget.userAnswers[index]
                       : null;
                    

                  final isCorrect =
                      userAnswer == correctAnswer;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    child: Column(
                      children: [
                        Card(
                          elevation: 2,
                          color: Colors.white,

                          child: Padding(
                            padding: const EdgeInsets.all(20),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "Q${index + 1}: $questionText",

                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Your Answer: ${
                                          userAnswer == null
                                          ? "Not Answered"
                                        : options[userAnswer]
                                    }",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                   Icon(
                                       isCorrect
                                         ? Icons.verified
                                           : Icons.close,
                                         color: isCorrect
                                         ? Colors.green
                                         : Colors.red,
                                        size: 30,
                                 ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Correct Answer: ${options[correctAnswer]}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}