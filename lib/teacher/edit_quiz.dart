
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditQuiz extends StatefulWidget {
  final String quizId;
  final Map<String, dynamic> quizData;

  const EditQuiz({
    super.key,
    required this.quizId,
    required this.quizData,
  });

  @override
  State<EditQuiz> createState() => _EditQuizState();
}

class _EditQuizState extends State<EditQuiz> {
  // ================= COLORS =================
  static const Color plum = Color(0xFF6D597A);
  static const Color darkPlum = Color(0xFF44364D);
  static const Color cream = Color(0xFFF8F4F0);
  static const Color textColor = Color(0xFF332D35);

  // ================= CONTROLLERS =================
  late TextEditingController _titleController;
  late TextEditingController _timeController;

  // ================= VALUES =================
  String _selectedSubject = 'Flutter';
  String _selectedType = 'Practice';
  String _selectedAssignTo = 'All Students';

  bool _isSaving = false;

  // ================= OPTIONS =================
  final List<String> _subjects = [
    'Flutter',
    'Web',
    'Cybersecurity',
    'English',
    'Islamiat',
  ];

  final List<String> _types = [
    'Practice',
    'Official',
  ];

  final List<String> _assignToOptions = [
    'Batch 1',
    'Batch 2',
    'Batch 3',
    'All Students',
  ];

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.quizData['title']?.toString() ?? '',
    );

    _timeController = TextEditingController(
      text: widget.quizData['timeLimit']?.toString() ?? '30',
    );

    final subject =
        widget.quizData['subject']?.toString() ?? 'Flutter';

    final type =
        widget.quizData['type']?.toString() ?? 'Practice';

    final assignTo =
        widget.quizData['assignTo']?.toString() ??
            'All Students';

    if (_subjects.contains(subject)) {
      _selectedSubject = subject;
    }

    if (_types.contains(type)) {
      _selectedType = type;
    }

    if (_assignToOptions.contains(assignTo)) {
      _selectedAssignTo = assignTo;
    }
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // ================= SAVE CHANGES =================
  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();

    final timeLimit = int.tryParse(
      _timeController.text.trim(),
    );

    // Title validation
    if (title.isEmpty) {
      _showMessage('Please enter quiz title');
      return;
    }

    // Time validation
    if (timeLimit == null || timeLimit <= 0) {
      _showMessage('Please enter a valid time limit');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ================= FIRESTORE UPDATE =================
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .update({
        'title': title,
        'subject': _selectedSubject,
        'type': _selectedType,
        'timeLimit': timeLimit,
        'assignTo': _selectedAssignTo,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Quiz updated successfully',
          ),
        ),
      );

      // Go back to Manage Quizzes
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Error updating quiz:\n$e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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

  // ================= INPUT DECORATION =================
  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: plum,
      ),
      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: plum,
          width: 1.5,
        ),
      ),
    );
  }

  // ================= DROPDOWN =================
  Widget _dropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,

      decoration: _inputDecoration(
        label,
        icon,
      ),

      items: items.map(
        (item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              item.toString(),
            ),
          );
        },
      ).toList(),

      onChanged: onChanged,
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
          'Edit Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ================= BODY =================
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ================= HEADING =================
                const Text(
                  'Edit Quiz Details',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Update the information of your quiz.',
                  style: TextStyle(
                    color: textColor.withOpacity(0.60),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 22),

                // ================= TITLE =================
                TextField(
                  controller: _titleController,
                  decoration: _inputDecoration(
                    'Quiz Title',
                    Icons.title,
                  ),
                ),

                const SizedBox(height: 16),

                // ================= SUBJECT =================
                _dropdown<String>(
                  label: 'Subject',
                  icon: Icons.menu_book_outlined,
                  value: _selectedSubject,
                  items: _subjects,

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSubject = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                // ================= TYPE =================
                _dropdown<String>(
                  label: 'Quiz Type',
                  icon: Icons.quiz_outlined,
                  value: _selectedType,
                  items: _types,

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                // ================= TIME =================
                TextField(
                  controller: _timeController,

                  keyboardType:
                      TextInputType.number,

                  decoration: _inputDecoration(
                    'Time Limit (minutes)',
                    Icons.access_time,
                  ),
                ),

                const SizedBox(height: 16),

                // ================= ASSIGN TO =================
                _dropdown<String>(
                  label: 'Assign To',
                  icon: Icons.people_outline,
                  value: _selectedAssignTo,
                  items: _assignToOptions,

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAssignTo = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 28),

                // ================= SAVE BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed:
                        _isSaving
                            ? null
                            : _saveChanges,

                    icon: _isSaving
                        ? const SizedBox(
                            width: 19,
                            height: 19,

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
                      _isSaving
                          ? 'Saving...'
                          : 'Save Changes',
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: plum,
                      foregroundColor: Colors.white,
                      elevation: 0,

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
        ),
      ),
    );
  }
}

