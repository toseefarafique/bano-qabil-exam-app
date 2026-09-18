import 'Quiz_Screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectSubject extends StatefulWidget {
  final String subjectName;
  final String subjectId;
  const SelectSubject({
    super.key,
    required this.subjectName,
    required this.subjectId,
  });

  @override
  State<SelectSubject> createState() => _SelectSubjectState();
}

class _SelectSubjectState extends State<SelectSubject> {
 
  int selectedTab =0;
  Stream<QuerySnapshot> getQuizzes() {
  return FirebaseFirestore.instance
      .collection('quizzes')
      .where('subjectId', isEqualTo: widget.subjectId)
      .snapshots();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFBF0),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        },
         icon: Icon(Icons.arrow_back,
         color: Color(0xFF6F435C),
         size: 30,)),
        title: Text(widget.subjectName,
        style: TextStyle(
          color: Color(0xFF6F435C),
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),), 
        actions: [
          Padding(padding: EdgeInsets.only(right: 15),
          child:IconButton(onPressed: (){},
           icon: Icon(Icons.search,
           color: Color(0xFF6F435C),
           size: 35,)))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFFFFBF0),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(20),
        child:Row(
          children: [
            Expanded(child: GestureDetector(
              onTap:(){
                setState(() {
                  selectedTab =0;
                });
              },
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: selectedTab ==0 
                      ?Color(0xFF6F435C): Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: BoxBorder.all(
                        color: Color(0xFF6F435C),
                      )
              ),
               child: Center(
                      child: Text("Quizzes",
                      style: TextStyle(
                        color: selectedTab == 0
                        ?Colors.white: Color(0xFF6F435C),
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
            ),  
            )),
            SizedBox(width: 15),
                Expanded(child: GestureDetector(
                  onTap: (){
                    setState(() {
                      selectedTab =1;
                    });
                  },
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: selectedTab ==1
                      ? Color(0xFF6F435C) : Colors.white,
                     borderRadius:BorderRadius.circular(10),
                     border: BoxBorder.all(
                      color: Color(0xFF6F435C))
                    ),
                   child: Center(
                     child: Text("History",
                    style: TextStyle(
                      color: selectedTab ==1
                      ? Colors.white : Color(0xFF6F435C),
                      fontWeight: FontWeight.bold,
                    ),),
                   ),
                  ),
                )),
          ],
        ),

        ),
        if(selectedTab ==0)
          StreamBuilder<QuerySnapshot>(
  stream: getQuizzes(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("No Quizzes Available"),
      );
    }

    return Column(
      children: snapshot.data!.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        String title = data['title'] ?? "Quiz";
        int totalQuestion = data['totalQuestion'] ?? 0;
        int duration = data['duration'] ?? 0;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 2,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Practice . $totalQuestion Questions . $duration Minutes",
                    style: const TextStyle(
                      fontSize: 15,
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
                               quizId: doc.id,
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
                      child: const Text(
                        "Start",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  },
)
else
  StreamBuilder<QuerySnapshot>(
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
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Text("No Quiz History Yet"),
        );
      }

      final results = snapshot.data!.docs;

      return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: results.map((doc) {
            final data =
                doc.data() as Map<String, dynamic>;

            return Card(
              elevation: 2,
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.quiz),
                title: Text(
                  data['quizId'] ?? 'Quiz',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Score: ${data['score']}/${data['totalQuestion']}",
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${data['percentage']}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Completed",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    },
  ),
    
     
 
   
            ],
          )
          
        ),
      ),
    );
  }
}