import 'package:flutter/material.dart';
import 'add_question.dart';

class QuestionBank extends StatefulWidget {
  // Parent TeacherDashboard ko batane ke liye
  // ke Back Arrow press hua hai.
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

  // =========================
  // DEMO QUESTIONS
  // =========================

  final List<Map<String, String>> questions = [
    {
      'subject': 'Flutter',
      'difficulty': 'Easy',
      'question':
          'What is the main purpose of setState() in Flutter?',
    },
    {
      'subject': 'Cybersecurity',
      'difficulty': 'Medium',
      'question':
          'Which attack tries to make a system unavailable?',
    },
    {
      'subject': 'Web',
      'difficulty': 'Hard',
      'question':
          'Which HTTP status code means "Not Found"?',
    },
    {
      'subject': 'Islamiat',
      'difficulty': 'Medium',
      'question':
          'Which Surah is known as "Surah Yaseen"?',
    },
  ];

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
            // Parent TeacherDashboard ko call karega.
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
            padding: const EdgeInsets.only(
              right: 15,
            ),
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
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              

              TextField(
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

              
              Row(
                children: [
                  // Subject
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

                  // Difficulty
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
                    '${questions.length} Questions',
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              
              ...questions.map(
                (question) => _questionCard(question),
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
          // Later Add Question screen open hogi.
        },

        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  
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

  
  Widget _questionCard(
    Map<String, String> question,
  ) {
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
                      question['subject']!,
                      primary,
                    ),

                    const SizedBox(width: 7),

                    _difficultyTag(
                      question['difficulty']!,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  question['question']!,
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
              IconButton(
                visualDensity:
                    VisualDensity.compact,

                icon: const Icon(
                  Icons.edit_outlined,
                  color: primary,
                  size: 21,
                ),

                onPressed: () {
                  // Later Edit Question screen
                },
              ),

              IconButton(
                visualDensity:
                    VisualDensity.compact,

                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 21,
                ),

                onPressed: () {
                  // Later Delete Question
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

 
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