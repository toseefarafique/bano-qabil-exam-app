import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_question.dart';
import 'edit_question.dart';

class QuestionBank extends StatefulWidget {
  final VoidCallback? onBack;

  const QuestionBank({
    super.key,
    this.onBack,
  });

  @override
  State<QuestionBank> createState() => _QuestionBankState();
}

class _QuestionBankState extends State<QuestionBank> {
  static const Color primary = Color(0xFF6D597A);
  static const Color dark = Color(0xFF44364D);
  static const Color accent = Color(0xFFDDBEA9);
  static const Color background = Color(0xFFF8F4F0);
  static const Color textColor = Color(0xFF332D35);

  String selectedSubject = 'All Subjects';
  String selectedDifficulty = 'All Difficulty';
  String searchText = '';

  final TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Firebase se questions read karna
  Stream<QuerySnapshot<Map<String, dynamic>>> _questionsStream() {
    return FirebaseFirestore.instance
        .collection('questions')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            }
          },
        ),

        title: const Text(
          'Question Bank',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: accent,
              child: const Icon(
                Icons.person,
                color: dark,
              ),
            ),
          ),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),

          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Search
              TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search questions...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: primary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Filters
              Row(
                children: [
                  Expanded(
                    child: _filterDropdown(
                      value: selectedSubject,
                      items: const [
                        'All Subjects',
                        'Flutter',
                        'Web',
                        'Cybersecurity',
                        'English',
                        'Islamiat',
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedSubject = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _filterDropdown(
                      value: selectedDifficulty,
                      items: const [
                        'All Difficulty',
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

              const SizedBox(height: 20),

              // Questions heading + Firebase count
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _questionsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      'Error loading questions',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Text(
                      'Questions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  final filteredQuestions =
                      docs.where((doc) {
                    final data = doc.data();

                    final question =
                        (data['question'] ?? '')
                            .toString();

                    final subject =
                        (data['subject'] ?? '')
                            .toString();

                    final difficulty =
                        (data['difficulty'] ?? '')
                            .toString();

                    // Search filter
                    final matchesSearch =
                        searchText.isEmpty ||
                        question
                            .toLowerCase()
                            .contains(searchText);

                    // Subject filter
                    final matchesSubject =
                        selectedSubject ==
                            'All Subjects' ||
                        subject == selectedSubject;

                    // Difficulty filter
                    final matchesDifficulty =
                        selectedDifficulty ==
                            'All Difficulty' ||
                        difficulty ==
                            selectedDifficulty;

                    return matchesSearch &&
                        matchesSubject &&
                        matchesDifficulty;
                  }).toList();

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Questions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),

                          Text(
                            '${filteredQuestions.length} Questions',
                            style: const TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (filteredQuestions.isEmpty)
                        _emptyState()
                      else
                        ...filteredQuestions.map(
                          (doc) => _questionCard(
                            doc.id,
                            doc.data(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddQuestion(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // Dropdown
  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
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
    );
  }

  // Question Card
  Widget _questionCard(
    String documentId,
    Map<String, dynamic> question,
  ) {
    final String questionText =
        (question['question'] ?? 'No question')
            .toString();

    final String subject =
        (question['subject'] ?? 'No Subject')
            .toString();

    final String difficulty =
        (question['difficulty'] ?? 'No Difficulty')
            .toString();

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withOpacity(0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: dark.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: background,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.help_outline,
              color: primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _tag(
                      subject,
                      primary,
                    ),

                    const SizedBox(width: 7),

                    _difficultyTag(
                      difficulty,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  questionText,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              // Edit
              IconButton(
                visualDensity:
                    VisualDensity.compact,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: primary,
                  size: 21,
                ),
                onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditQuestion(
        documentId: documentId,
        questionData: question,
      ),
    ),
  );
},
              ),

              // Delete
              IconButton(
                visualDensity:
                    VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 21,
                ),
                onPressed: () {
                  _deleteQuestion(
                    documentId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Empty state
  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 55,
            color: accent,
          ),
          const SizedBox(height: 12),
          const Text(
            'No questions found',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Try another search or filter.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Delete question
  Future<void> _deleteQuestion(
    String documentId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(documentId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Question deleted successfully!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting question: $e',
          ),
        ),
      );
    }
  }

  // Subject tag
  Widget _tag(
    String title,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: primary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Difficulty tag
  Widget _difficultyTag(
    String difficulty,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.25),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        difficulty,
        style: const TextStyle(
          color: dark,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}