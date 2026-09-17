import 'History.dart';
import 'Upcoming_Exam.dart';
import 'profile_user.dart';
import 'package:flutter/material.dart';
import 'select_subject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  Stream<QuerySnapshot> getSubjects() {
  return FirebaseFirestore.instance
      .collection('subject')
      .snapshots();
}
  Future<String> getStudentName() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return "Student";
  }

  DocumentSnapshot studentData = await FirebaseFirestore.instance
      .collection('student')
      .doc(user.uid)
      .get();

  if (studentData.exists) {
    return studentData['name'] ?? "Student";
  }

  return "Student";
}
Future<String> getLastScore() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) return "0%";

  QuerySnapshot result = await FirebaseFirestore.instance
      .collection('result')
      .where('studentId', isEqualTo: user.uid)
      .limit(1)
      .get();

  if (result.docs.isEmpty) return "0%";

  var data = result.docs.first.data() as Map<String, dynamic>;

  int score = data['score'] ?? 0;
  int total = data['totalQuestion'] ?? 0;

  if (total == 0) return "0%";

  return "${((score / total) * 100).round()}%";
}
Future<String> getPracticeStreak() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) return "0 Days";

  QuerySnapshot result = await FirebaseFirestore.instance
      .collection('result')
      .where('studentId', isEqualTo: user.uid)
      .get();

  if (result.docs.isEmpty) return "0 Days";

  Set<String> days = {};

  for (var doc in result.docs) {
    var data = doc.data() as Map<String, dynamic>;

    if (data['date'] != null) {
      Timestamp timestamp = data['date'];
      DateTime date = timestamp.toDate();

      days.add("${date.year}-${date.month}-${date.day}");
    }
  }

  return "${days.length} Days";
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
    body: SingleChildScrollView(

      child: Container(
           color:  Color(0xFFFFFBF0),
        // padding: EdgeInsets.all(20),
     child: Column(
        
        children: [
          Container(
        
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(0, 10, 15, 25),
        decoration: const BoxDecoration(
          color: Color(0xFF6F435C),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                   Row(
                    children: [
                       IconButton(onPressed: (){
              Navigator.pop(context);
               },
            icon: Icon(Icons.arrow_back,
             size: 30,
              color: Color(0xFFFFFBF0),)),
           
              Text(
                    "Bano Qabil Exam",
                    style: TextStyle(
                      color: Color(0xFFFFFBF0),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            
                    ],
                   ),
                  

                  SizedBox(height: 5),
                  Padding(padding: EdgeInsets.only(left: 45),
                   child:Text(
                    "Learn • Practice • Succeed",
                    style: TextStyle(
                      color: Color(0xFFFFFBF0),
                      fontSize: 15,
                    ),
                  ),)
                 
                ],
              ),
            ),

            // Notification button
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Color(0xFFFFFBF0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () {
                  // Notifications screen later
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF6F435C),
                  size: 29,
                ),
              ),
            ),
          ],
        ),
      ),
         
          Container(
          padding: EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                radius: 40,
                backgroundColor:Color(0xFF6F435C),
                child: Icon(Icons.person,
                color:  Color(0xFFFFFBF0),
                size: 55,),
                ),
                
               Padding(padding: EdgeInsetsGeometry.only(left: 10),
               child: Row(
                children: [
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text("Assalam-o-Alaikum",
                    style: TextStyle(
                      color: Color(0xFF6F435C),
                      fontSize: 15,
                      
                    ),),
                    FutureBuilder<String>(
                       future: getStudentName(),
                        builder: (context, snapshot) {
                        return Text(
                       snapshot.data ?? "Student",
                      style: TextStyle(
                       color: Color(0xFF6F435C),
                       fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      );
                      },
                     ),
                   
                    Text("Keep going! you're doing great!",
                    style: TextStyle(
                      color: Color(0xFF6F435C),
                      fontSize: 15,
                      
                    ),),
                  ],
                ),
                Image.asset('assets/images/girl2_pic.png',
                height: 160,
                width: 160,
                fit: BoxFit.contain,)
                ],
               ),),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(8),
          child: Card(
            elevation: 3,
            color: Colors.white,
           child: Padding(padding: EdgeInsets.all(20),
            child:Column(
              children: [
                Text("Upcoming Exams",
                style: TextStyle(
                  color: Color(0xFF6F435C),
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
        ),
        Divider(
          color: Color(0xFF6F435C),
          thickness: 2,
        ),
        Row(
         
          children: [
            Icon(Icons.menu_book,
            color: Color(0xFF6F435C),
            size: 40,
            ),
            SizedBox(width: 20),
           Expanded(child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Flutter Basics",
                style: TextStyle(
                 color: Color(0xFF6F435C),
                 fontWeight: FontWeight.bold, 
                 fontSize: 20, 
                ),),
                  Text("Tomorrow . 10:00 AM",
                style: TextStyle(
                 color: Color(0xFF6F435C),
                 fontWeight: FontWeight.bold, 
                 fontSize: 15, 
                ),),
                  Text("20 Question . 20 Minutes",
                style: TextStyle(
                 color: Color(0xFF6F435C),
                 fontWeight: FontWeight.bold, 
                 fontSize: 12, 
                ),),
              ],
            ),),
           Align(
            alignment: Alignment.centerRight,
             child:IconButton(onPressed: (){},
             icon: Icon(Icons.arrow_forward,
             color: Color(0xFF6F435C),
             size: 30,
            ))
           )
          ],
        )
              ],
            ),), 
           
          ),),
          SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 3,
              color: Colors.white,
             child: Container(
              height: 90,
              width: 200,
               child: Padding(padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(Icons.arrow_downward,
                  size: 30,
                  color: Color(0xFF6F435C),),
                  SizedBox(width: 10),
            Column(
              children: [
                Text("Last Score",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
                FutureBuilder<String>(
  future: getLastScore(),
  builder: (context, snapshot) {
    return Text(
      snapshot.data ?? "0%",
      style: TextStyle(
        color: Color(0xFF6F435C),
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    );
  },
),
             

              ],
            )      
                ],
              ),
             ),),
            ),
            SizedBox(width: 30),
            Card(
               elevation: 5,
              color: Colors.white,
            child: Container(
              width: 200,
              height: 90,
              child: Padding(padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department,
                  size: 30,
                  color: Colors.deepOrange),
            Column(
              children: [
                Text("Practice Streak",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
               
              FutureBuilder<String>(
                 future: getPracticeStreak(),
                      builder: (context, snapshot) {
                     return Text(
                   snapshot.data ?? "0 Days",
                      style: TextStyle(
                       color: Color(0xFF6F435C),
                       fontWeight: FontWeight.bold,
                      fontSize: 22,
                  ),
                  );
                       },
                       ),
              ],
            )      
                ],
              ),),
            ),
            )
          ],
        ),
    
      Align(
        alignment: Alignment.centerLeft,
         child:Text("Subject",
      style: TextStyle(
         color: Color(0xFF6F435C),
        fontSize: 27,
        fontWeight: FontWeight.bold,
      ),)
      
      ),
 
            StreamBuilder<QuerySnapshot>(
  stream: getSubjects(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Text("No Subjects Available"),
      );
    }

    return Wrap(
      children: snapshot.data!.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        String name = data['name'] ?? "Subject";
        int quizCount = data['quizCount'] ?? 0;

        IconData icon = Icons.book;

        if (name == "Flutter") {
          icon = Icons.flutter_dash;
        } else if (name == "Web") {
          icon = Icons.web;
        } else if (name == "Cybersecurity") {
          icon = Icons.security;
        }

        return Card(
          elevation: 3,
          color: Colors.white,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  SelectSubject(
                    subjectName: name,
                     subjectId: doc.id,
                  ),
                ),
              );
            },
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 35,
                    color: const Color(0xFF6F435C),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "$quizCount Quizes",
                        style: const TextStyle(
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  },
),
         
        ], 
     ),
      
        
      )
    ),
    
     bottomNavigationBar: BottomNavigationBar(
      currentIndex: 0,
      onTap: (index){
        if(index ==1){
         Navigator.push(context,
          MaterialPageRoute(builder: (context)=> UpcomingExam()));
          
        }
        if(index ==2){
          Navigator.push(context,
          MaterialPageRoute(builder: (context)=> History()));
        }
        if(index ==3){
           Navigator.push(context,
          MaterialPageRoute(builder: (context)=> 
             profile(),   
          ));
        }
      },
      selectedItemColor:  Color(0xFF6F435C),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined,),
        activeIcon: Icon(Icons.home),
        label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined),
        activeIcon: Icon(Icons.calendar_month),
        label: "Exams"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline),
        activeIcon: Icon(Icons.history),
        label: "History"),
        BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined),
        activeIcon: Icon(Icons.person_2),
        label: "Profille"),

        
      ],), 
    );
  }
}