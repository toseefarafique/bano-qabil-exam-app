import 'Upcoming_Exam.dart';
import 'home_screen.dart';
import 'profile_user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFFBF0),
       appBar: AppBar(
   
    backgroundColor: const Color(0xFF6F435C),
    foregroundColor: const Color(0xFFFFFBF0),
    leading: IconButton(onPressed: (){
      Navigator.pop(context);
    },
     icon: Icon(Icons.arrow_back,
     size: 30,)),
     title: const Text("Quiz History",
     style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
     ),),
  ),
    body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('result')
      .where(
        'studentId',
        isEqualTo: FirebaseAuth.instance.currentUser?.uid,
      )
      .snapshots(),
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

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Text("No Quiz History Yet"),
      );
    }

    final results = snapshot.data!.docs;

    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final data =
            results[index].data() as Map<String, dynamic>;

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('quizzes')
              .where('quizId', isEqualTo: data['quizId'])
              .limit(1)
              .get(),
          builder: (context, quizSnapshot) {
            String quizTitle = "Quiz Result";

            if (quizSnapshot.hasData &&
                quizSnapshot.data!.docs.isNotEmpty) {
              final quizData =
                  quizSnapshot.data!.docs.first.data()
                      as Map<String, dynamic>;

              quizTitle = quizData['title'] ?? "Quiz Result";
            }

            return Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    quizTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF6F435C),
                    ),
                  ),
                  subtitle: Text(
                    "Score: ${data['score']}/${data['totalQuestion']}\n"
                    "Percentage: ${data['percentage']}%",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  },
),

       bottomNavigationBar: BottomNavigationBar(
      currentIndex: 2,
  
      onTap: (index){
        if(index ==0){
          Navigator.push(context, 
          MaterialPageRoute(builder: (context)=> HomeScreen()));
        }

        if(index ==1){
         Navigator.push(context, 
         MaterialPageRoute(builder: (context)=> UpcomingExam()));
          
        }
        if(index ==2){
         return;
        }
        if(index ==3){
           Navigator.push(context,
           MaterialPageRoute(builder: (context)=> profile()));
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