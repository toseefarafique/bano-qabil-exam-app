import 'package:flutter/material.dart';

class AttemptsResults extends StatefulWidget {
  const AttemptsResults({super.key});

  @override
  State<AttemptsResults> createState() => _AttemptsResultsState();
}

class _AttemptsResultsState extends State<AttemptsResults> {
  // Theme colors
  static const Color plum = Color(0xFF6D597A);
  static const Color darkPlum = Color(0xFF44364D);
  static const Color accent = Color(0xFFDDBEA9);
  static const Color cream = Color(0xFFF8F4F0);
  static const Color textColor = Color(0xFF332D35);

  // Demo attempts
  final List<Map<String, dynamic>> attempts = [
    {
      'student': 'Ali Ahmed',
      'quiz': 'Flutter Basics',
      'score': '8/10',
      'percentage': '80%',
      'status': 'Passed',
      'date': '15 Sep 2026',
    },
    {
      'student': 'Sara Khan',
      'quiz': 'Web Development',
      'score': '9/10',
      'percentage': '90%',
      'status': 'Passed',
      'date': '15 Sep 2026',
    },
    {
      'student': 'Hamza Ali',
      'quiz': 'Cybersecurity',
      'score': '5/10',
      'percentage': '50%',
      'status': 'Failed',
      'date': '14 Sep 2026',
    },
    {
      'student': 'Ayesha Noor',
      'quiz': 'Flutter Basics',
      'score': '7/10',
      'percentage': '70%',
      'status': 'Passed',
      'date': '14 Sep 2026',
    },
    {
      'student': 'Usman Tariq',
      'quiz': 'English',
      'score': '4/10',
      'percentage': '40%',
      'status': 'Failed',
      'date': '13 Sep 2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

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

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  const Text(
                    'Student Attempts',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'View student quiz performance and results.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.people,
                          title: 'Attempts',
                          value: '24',
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _summaryCard(
                          icon: Icons.check_circle,
                          title: 'Passed',
                          value: '18',
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _summaryCard(
                          icon: Icons.cancel,
                          title: 'Failed',
                          value: '6',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Filter
                  Container(
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
                        value: 'All Quizzes',
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: plum,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All Quizzes',
                            child: Text('All Quizzes'),
                          ),
                          DropdownMenuItem(
                            value: 'Flutter Basics',
                            child: Text('Flutter Basics'),
                          ),
                          DropdownMenuItem(
                            value: 'Web Development',
                            child: Text('Web Development'),
                          ),
                          DropdownMenuItem(
                            value: 'Cybersecurity',
                            child: Text('Cybersecurity'),
                          ),
                          DropdownMenuItem(
                            value: 'English',
                            child: Text('English'),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Attempts list
                  ...attempts.map(
                    (attempt) => _attemptCard(attempt),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Summary card
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

  // Student attempt card
  Widget _attemptCard(Map<String, dynamic> attempt) {
    final bool passed = attempt['status'] == 'Passed';

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student icon
          CircleAvatar(
            radius: 25,
            backgroundColor: accent.withOpacity(0.45),
            child: const Icon(
              Icons.person,
              color: darkPlum,
            ),
          ),

          const SizedBox(width: 12),

          // Student information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attempt['student'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  attempt['quiz'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: plum,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  attempt['date'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Score and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                attempt['score'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkPlum,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                attempt['percentage'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: passed
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  attempt['status'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}