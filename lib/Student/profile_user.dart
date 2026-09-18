
import 'package:bano_qabil_exam/Student/notification.dart';

import 'History.dart';
import 'Upcoming_Exam.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class profile extends StatefulWidget {
   const profile({super.key});

  //  final String patientName;

  // const profile({
  //   super.key,
  //   required this.patientName,
  // });

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
String studentName = "Student";
  @override
void initState() {
  super.initState();
  _loadStudentName();
}

 Future<void> _loadStudentName() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final query = await FirebaseFirestore.instance
      .collection('student')
      .where('email', isEqualTo: user.email)
      .limit(1)
      .get();

  if (query.docs.isNotEmpty) {
    setState(() {
      studentName = query.docs.first.data()['name'] ?? "Student";
    });
  }
}

 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFBF0),

      body: Center(
        child: Container(
          width: 600,
          height: 1100,
          clipBehavior: Clip.hardEdge,

          decoration: BoxDecoration(
            color: Color(0xFFFFFBF0),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),

          child: SingleChildScrollView(
            child: Column(
              children: [
                // ==================================================
                // PROFILE HEADER
                // ==================================================

                Container(
                  width: double.infinity,
                  height: 190,

                  decoration: const BoxDecoration(
                    color:  Color(0xFF6F435C),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 30, 25, 20),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // ==================================================
                        // BACK BUTTON
                        // ==================================================

                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFFFFFBF0),
                            size: 30,
                          ),
                        ),

                        const SizedBox(width: 5),

                        // Header Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: const [
                              Text(
                                "Profile",
                                style: TextStyle(
                                  color: Color(0xFFFFFBF0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),

                              SizedBox(height: 5),

                              Text(
                                "Manage your Account and Setting",
                                style: TextStyle(
                                  color:Color(0xFFFFFBF0),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Notification
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.notifications,
                            color: Color(0xFFFFFBF0),
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // PROFILE CARD
                // ==================================================
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 25),

                  child: Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),

                      border: Border.all(color: Colors.grey.shade200),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        // ==================================================
                        // PROFILE IMAGE
                        // ==================================================

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Color.fromARGB(255, 230, 214, 223),

                              child: const Icon(
                                Icons.person,
                                size: 65,
                                color:  Color(0xFF6F435C),
                              ),
                            ),

                            Positioned(
                              bottom: 0,
                              right: 0,

                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF6F435C),

                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 23,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 25),

                        // ==================================================
                        // USER INFORMATION
                        // ==================================================
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,


                            children: [
                              Text(
                                studentName,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),


                              const SizedBox(height: 5),

                              const Text(
                                "Student",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(height: 5),

                              const Text(
                              "Keep learning and improving",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // ACCOUNT SETTINGS
                // ==================================================
                Padding(
                  padding: const EdgeInsets.all(30),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Account Settings",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _settingTile(
                        onTap: (){},
                        icon: Icons.person_outline,
                        title: "Personal Information",
                        subtitle: "Manage your personal details",
                      ),

                      _settingTile(
                        onTap: (){},
                        icon: Icons.lock_outline,
                        title: "Change Password",
                        subtitle: "Update your account password",
                      ),

                      _settingTile(
                        onTap: (){
                           Navigator.push(
                             context,
                        MaterialPageRoute(
                            builder: (context) => NotificationScreen(),
                             ),
                             );
                        },
                        icon: Icons.notifications_none,
                        title: "Notifications",
                        subtitle: "Manage notification settings",
                    
                      ),

                      _settingTile(
                        onTap: (){},
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        subtitle: "Get help with the application",
                      ),

                      _settingTile(
                        onTap: (){},
                        icon: Icons.logout,
                        title: "Logout",
                        subtitle: "Sign out from your account",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
                height: 65,

                child: BottomNavigationBar(
                  currentIndex: 3,

                  onTap: (index) {
                    // HOME
                    if (index == 0) {
                      Navigator.push(context
                      ,MaterialPageRoute(builder: (context)=>HomeScreen()));
                    }

                    // APPOINTMENTS
                    if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          UpcomingExam()
                        ),
                      );
                    }
                    if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          History()
                        ),
                      );
                    }
                  
                    if (index == 3) {
                     return;
                    }
                  },

                  selectedItemColor:  Color(0xFF6F435C),
                  unselectedItemColor: Colors.grey,

                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  elevation: 8,

                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: "Home",
                    ),

                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_month_outlined),
                      activeIcon: Icon(Icons.calendar_month),
                      label: "Exams",
                    ),

                    BottomNavigationBarItem(
                      icon: Icon(Icons.history_outlined),
                      activeIcon: Icon(Icons.history),
                      label: "History",
                    ),

                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_2_outlined),
                      activeIcon: Icon(Icons.person_2),
                      label: "Profile",
                    ),
                  ],
                ),
              ),
    );
  }

  // ============================================================
  // SETTING TILE
  // ============================================================

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
      required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),

        leading: CircleAvatar(
          backgroundColor:  Color.fromARGB(255, 230, 214, 223),

          child: Icon(icon, color:  Color(0xFF6F435C),)
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          color:  Color(0xFF6F435C),
          size: 17,
        ),

     onTap: onTap, 
      ),
    );
  }
}
