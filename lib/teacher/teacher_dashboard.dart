import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'question_bank.dart';
import 'create_quiz.dart';
import 'attempts_results.dart';
import '../logo_screen.dart';
import 'package:bano_qabil_exam/teacher/manage_quizzes.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _currentIndex = 0;

  final Color primaryPlum = const Color(0xFF6D597A);
  final Color darkPlum = const Color(0xFF44364D);
  final Color accent = const Color(0xFFDDBEA9);
  final Color cream = const Color(0xFFF8F4F0);
  final Color lightPlum = const Color(0xFFF0EAF2);

  // ============================================================
  // CURRENT TEACHER
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> _getTeacherData() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No teacher is logged in.');
    }

    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  String _getTeacherName(Map<String, dynamic>? data) {
    if (data == null) {
      return 'Teacher';
    }

    return (data['name'] ??
            data['fullName'] ??
            data['displayName'] ??
            'Teacher')
        .toString();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty || name == 'Teacher') {
      return 'T';
    }

    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

      drawer: _buildDrawer(),

      body: IndexedStack(
        index: _currentIndex,
        children: [
          _dashboardScreen(),

          QuestionBank(
            onBack: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),

          const ManageQuizzes(),

          const AttemptsResults(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primaryPlum,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note),
            label: 'Questions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz),
            label: 'Quizzes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Attempts',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DRAWER
  // ============================================================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: cream,
      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getTeacherData(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data();

          final teacherName = _getTeacherName(data);
          final initials = _getInitials(teacherName);

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 220,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 55, 22, 20),
                decoration: BoxDecoration(
                  color: darkPlum,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: accent,
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: darkPlum,
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      teacherName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Row(
                      children: const [
                        Icon(
                          Icons.school_outlined,
                          color: Colors.white70,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Teacher',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _drawerItem(
                icon: Icons.dashboard_outlined,
                title: 'Dashboard',
                selected: _currentIndex == 0,
                onTap: () {
                  Navigator.pop(context);

                  setState(() {
                    _currentIndex = 0;
                  });
                },
              ),

              _drawerItem(
                icon: Icons.edit_note_outlined,
                title: 'Question Bank',
                selected: _currentIndex == 1,
                onTap: () {
                  Navigator.pop(context);

                  setState(() {
                    _currentIndex = 1;
                  });
                },
              ),

              _drawerItem(
                icon: Icons.add_circle_outline,
                title: 'Add Questions',
                selected: false,
                onTap: () {
                  Navigator.pop(context);

                  setState(() {
                    _currentIndex = 1;
                  });
                },
              ),

              _drawerItem(
                icon: Icons.quiz_outlined,
                title: 'Create Exam',
                selected: _currentIndex == 2,
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateQuiz()),
                  );
                },
              ),

              _drawerItem(
                icon: Icons.assessment_outlined,
                title: 'Attempts & Results',
                selected: _currentIndex == 3,
                onTap: () {
                  Navigator.pop(context);

                  setState(() {
                    _currentIndex = 3;
                  });
                },
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Divider(),
              ),

              _drawerItem(
                icon: Icons.logout,
                title: 'Logout',
                selected: false,
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LogoScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // DRAWER ITEM
  // ============================================================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: selected ? lightPlum : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? (selected ? primaryPlum : Colors.grey.shade700),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? (selected ? primaryPlum : Colors.grey.shade800),
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _dashboardScreen() {
    return SafeArea(
      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getTeacherData(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data();

          final teacherName = _getTeacherName(data);
          final initials = _getInitials(teacherName);

          return CustomScrollView(
            slivers: [
              // ==================================================
              // TOP APP BAR
              // ==================================================

              SliverAppBar(
                backgroundColor: darkPlum,
                foregroundColor: Colors.white,
                pinned: true,
                elevation: 0,

                leading: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),

                title: const Text(
                  'Teacher Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                actions: [
                  IconButton(
                    tooltip: 'Notifications',
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {},
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: accent,
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: darkPlum,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ==================================================
              // MAIN CONTENT
              // ==================================================
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ==================================================
                    // WELCOME CARD
                    // ==================================================

                    _buildWelcomeCard(teacherName, initials),

                    // REDUCED FROM 25 TO 18
                    const SizedBox(height: 18),

                    // ==================================================
                    // OVERVIEW TITLE
                    // ==================================================
                    Row(
                      children: [
                        Container(
                          height: 30,
                          width: 5,
                          decoration: BoxDecoration(
                            color: primaryPlum,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF332D35),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // COMPACT STAT CARDS
                    // ==================================================
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      crossAxisCount: 2,

                      // CHANGED FROM 1.9 TO 2.4
                      // This makes the cards noticeably shorter.
                      childAspectRatio: 2.4,

                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,

                      children: [
                        _buildStatCard(
                          icon: Icons.quiz_rounded,
                          title: 'Total Exams',
                          value: '5',
                          color: primaryPlum,
                        ),

                        _buildStatCard(
                          icon: Icons.play_circle_fill_rounded,
                          title: 'Active Exams',
                          value: '2',
                          color: Colors.green,
                        ),

                        _buildStatCard(
                          icon: Icons.people_alt_rounded,
                          title: 'Students',
                          value: '24',
                          color: Colors.blue,
                        ),

                        _buildStatCard(
                          icon: Icons.check_circle_rounded,
                          title: 'Completed',
                          value: '3',
                          color: Colors.orange,
                        ),
                      ],
                    ),

                    // REDUCED FROM 28 TO 18
                    const SizedBox(height: 18),

                    // ==================================================
                    // RECENT EXAMS
                    // ==================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Exams',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF332D35),
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            setState(() {
                              _currentIndex = 2;
                            });
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: primaryPlum,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // FIREBASE EXAMS
                    // ==================================================
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('quizzes')
                          .orderBy('createdAt', descending: true)
                          .limit(3)
                          .snapshots(),

                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoadingCard();
                        }

                        if (snapshot.hasError) {
                          return _buildErrorCard();
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyExamsCard();
                        }

                        final quizzes = snapshot.data!.docs;

                        return Column(
                          children: quizzes.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final String title =
                                (data['title'] ?? 'Untitled Quiz').toString();

                            final String subject =
                                (data['subject'] ?? 'No Subject').toString();

                            final String type = (data['type'] ?? 'Practice')
                                .toString();

                            final String status = (data['status'] ?? 'Draft')
                                .toString();

                            final Timestamp? createdAt =
                                data['createdAt'] is Timestamp
                                ? data['createdAt'] as Timestamp
                                : null;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildExamCard(
                                title: title,
                                subject: subject,
                                type: type,
                                date: _formatDate(createdAt),
                                status: status,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // CREATE EXAM BANNER
                    // ==================================================
                    _buildCreateExamBanner(),

                    const SizedBox(height: 10),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // WELCOME CARD
  // ============================================================

  Widget _buildWelcomeCard(String teacherName, String initials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkPlum, primaryPlum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: darkPlum.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: darkPlum,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back!',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 5),

                Text(
                  teacherName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Manage exams and monitor student progress.',
                  maxLines: 2,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPACT STAT CARD
  // ============================================================

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF332D35),
            ),
          ),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXAM CARD
  // ============================================================

  Widget _buildExamCard({
    required String title,
    required String subject,
    required String type,
    required String date,
    required String status,
  }) {
    final Color statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: lightPlum,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.quiz_rounded, color: primaryPlum, size: 26),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF332D35),
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons.subject_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        '$subject • $type',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CREATE EXAM BANNER
  // ============================================================

  Widget _buildCreateExamBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryPlum,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPlum.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a New Exam',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Add questions and prepare an exam.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          ElevatedButton(
            onPressed: null,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
              foregroundColor: WidgetStatePropertyAll(Color(0xFF6D597A)),
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            child: const Text(
              'Create',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING CARD
  // ============================================================

  Widget _buildLoadingCard() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  // ============================================================
  // ERROR CARD
  // ============================================================

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent, size: 38),

          SizedBox(height: 8),

          Text(
            'Unable to load recent exams.',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY EXAMS CARD
  // ============================================================

  Widget _buildEmptyExamsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(color: lightPlum, shape: BoxShape.circle),
            child: Icon(Icons.quiz_outlined, size: 30, color: primaryPlum),
          ),

          const SizedBox(height: 12),

          const Text(
            'No exams created yet',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(
            'Create your first exam to get started.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
      case 'active':
        return Colors.green;

      case 'approved':
        return Colors.blue;

      case 'scheduled':
        return primaryPlum;

      case 'locked':
        return Colors.orange;

      case 'results released':
        return Colors.teal;

      case 'draft':
      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'No date';
    }

    final date = timestamp.toDate();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
