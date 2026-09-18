import 'package:cloud_firestore/cloud_firestore.dart';
import 'History.dart';
import 'home_screen.dart';
import 'profile_user.dart';
import 'package:flutter/material.dart';
import 'Quiz_Screen.dart';

class UpcomingExam extends StatefulWidget {
  const UpcomingExam({super.key});

  @override
  State<UpcomingExam> createState() => _UpcomingExamState();
}

class _UpcomingExamState extends State<UpcomingExam> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6F435C),
      appBar: AppBar(
           backgroundColor: Color(0xFFFFFBF0),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, 
        icon: Icon(Icons.arrow_back,
        color: Color(0xFF6F435C),
        size: 30,
        )),
        title: Text("Upcoming Exams",
        style: TextStyle(
        color: Color(0xFF6F435C),
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),),
      ),
    //  
    body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('quizzes')
      .where('status', isEqualTo: 'upcoming')
      .snapshots(),
  builder: (context, snapshot) {

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Text(
          "No Upcoming Exams",
          style: TextStyle(
            color: Color(0xFFFFFBF0),
            fontSize: 18,
          ),
        ),
      );
    }

    final quizzes = snapshot.data!.docs;

    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {

        final quiz = quizzes[index].data() as Map<String, dynamic>;

        return Card(
          color: const Color(0xFFFFFBF0),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  quiz['title'] ?? 'Untitled Quiz',
                  style: const TextStyle(
                    color: Color(0xFF6F435C),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "${quiz['totalQuestion'] ?? 0} Questions • "
                  "${quiz['duration'] ?? 0} Minutes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                         quizId: quizzes[index].id,
                          ),
                        ),
                      );
                    },
                     style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F435C),
                        foregroundColor: const Color(0xFFFFFBF0),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    child: const Text("Start",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  },
),
       bottomNavigationBar: BottomNavigationBar(
      currentIndex: 1,
  
      onTap: (index){
        if(index ==0){
          Navigator.push(context, 
          MaterialPageRoute(builder: (context)=> HomeScreen()));
        }

        if(index ==1){
         return;
          
        }
        if(index ==2){
          Navigator.push(context,
          MaterialPageRoute(builder: (context)=> History()));
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