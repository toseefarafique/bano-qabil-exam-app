import 'package:flutter/material.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});


  static const Color plum = Color(0xFF6D597A);
  static const Color darkPlum = Color(0xFF44364D);
  static const Color accent = Color(0xFFDDBEA9);
  static const Color cream = Color(0xFFF8F4F0);
  static const Color textColor = Color(0xFF332D35);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,


      drawer: Drawer(
        backgroundColor: plum,
        child: SafeArea(
          child: Column(
            children: [
              // Logo / App Name
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 38,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Bano Qabil Exam",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Learn • Practice • Grow",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                color: Colors.white24,
                indent: 20,
                endIndent: 20,
              ),

              // Menu Items
              _drawerItem(
                icon: Icons.dashboard_outlined,
                title: "Dashboard",
                selected: true,
              ),

              _drawerItem(
                icon: Icons.edit_note,
                title: "Question Bank",
              ),

              _drawerItem(
                icon: Icons.menu_book_outlined,
                title: "Add Questions",
              ),

              _drawerItem(
                icon: Icons.bar_chart_outlined,
                title: "Create Exam",
              ),

              

            
              const Spacer(),

              _drawerItem(
                icon: Icons.logout,
                title: "Logout",
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),

      
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1000,
            ),
            child: CustomScrollView(
              slivers: [
                // ================= TOP BAR =================
                SliverAppBar(
                  backgroundColor: cream,
                  elevation: 0,
                  pinned: true,
                  automaticallyImplyLeading: false,

                  leading: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: textColor,
                          size: 28,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),

                  title: const Text(
                    "Dashboard",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none,
                        color: textColor,
                      ),
                    ),

                    // Profile Circle
                    Container(
                      margin: const EdgeInsets.only(
                        right: 15,
                        left: 5,
                      ),
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: plum,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          "AK",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    15,
                    18,
                    30,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Greeting
                      const Text(
                        "Good Morning,",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 3),

                      const Text(
                        "Ms. Ayesha Khan",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Here's what's happening with your exams today.",
                        style: TextStyle(
                          color: textColor.withOpacity(0.65),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 22),

                      
                      const Text(
                        "Overview",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Responsive Cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int columns = constraints.maxWidth > 650 ? 4 : 2;

                          return GridView.count(
                            crossAxisCount: columns,
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.45,
                            children: const [
                              _StatCard(
                                icon: Icons.assignment_outlined,
                                title: "Total Exams",
                                value: "5",
                                color: plum,
                              ),
                              _StatCard(
                                icon: Icons.access_time,
                                title: "Active Exams",
                                value: "2",
                                color: plum,
                              ),
                              _StatCard(
                                icon: Icons.people_outline,
                                title: "Total Students",
                                value: "24",
                                color: plum,
                              ),
                              _StatCard(
                                icon: Icons.check_circle_outline,
                                title: "Completed",
                                value: "3",
                                color: plum,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent Exams",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "View All",
                              style: TextStyle(
                                color: plum,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      _examCard(
                        icon: Icons.lock_outline,
                        title: "Flutter Basics Quiz",
                        subtitle: "Flutter  •  Practice",
                        date: "24 Aug 2025",
                        status: "Active",
                        statusColor: Colors.green,
                      ),

                      _examCard(
                        icon: Icons.menu_book_outlined,
                        title: "Web Development Test",
                        subtitle: "Web  •  Practice",
                        date: "26 Aug 2025",
                        status: "Scheduled",
                        statusColor: plum,
                      ),

                      _examCard(
                        icon: Icons.science_outlined,
                        title: "Cybersecurity Exam",
                        subtitle: "Cybersecurity  •  Official",
                        date: "28 Aug 2025",
                        status: "Draft",
                        statusColor: Colors.grey,
                      ),

                      const SizedBox(height: 22),

                      
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E7E1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Illustration Placeholder
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.circular(35),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: plum,
                                size: 35,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Create a new exam",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    "Set up questions, define time\nand publish instantly.",
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.65),
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: plum,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.add,
                                      size: 17,
                                    ),
                                    label: const Text(
                                      "Create Exam",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  static Widget _drawerItem({
    required IconData icon,
    required String title,
    bool selected = false,
  }) {
    return Builder(
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  static Widget _examCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9E1DD),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E7E1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: plum,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 18, 17, 18).withOpacity(0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Date + Status
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: textColor.withOpacity(0.55),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 7),

          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 40,
          ),
        ],
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9E1DD),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E7E1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),

          const Spacer(),

          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF332D35).withOpacity(0.6),
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF332D35),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}