import 'package:banoqabi_exam/History.dart';
import 'package:banoqabi_exam/home_screen.dart';
import 'package:banoqabi_exam/profile_user.dart';
import 'package:flutter/material.dart';

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
      body: SingleChildScrollView(
        child: Container(
          child:Padding(padding: EdgeInsets.all(20),
          child: Column(
            children: [
             Card(
          elevation: 2,
          color:  Color(0xFFFFFBF0),
         child: Padding(padding: EdgeInsets.all(20),
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Flutter Widgets",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),),
            SizedBox(height: 8),
            Text("Practice . 20 Questions . 20 Minutes",
            style: TextStyle(
              fontSize: 15,
            ),),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(onPressed: (){},
              style: ElevatedButton.styleFrom(
                backgroundColor:  Color(0xFF6F435C),
                foregroundColor: Color(0xFFFFFBF0),
                elevation: 3,
                
              shape:RoundedRectangleBorder(
                
                borderRadius: BorderRadius.circular(10),
              ) 
              ),
               child: Text("Start",
               style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
               ),)),
            )
          ],
         ),), 
        ),
        SizedBox(height: 10),
        Card(
          elevation: 2,
            color:  Color(0xFFFFFBF0),
         child: Padding(padding: EdgeInsets.all(20),
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Flutter Widgets",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),),
            SizedBox(height: 8),
            Text("Practice . 20 Questions . 20 Minutes",
            style: TextStyle(
              fontSize: 15,
            ),),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(onPressed: (){},
              style: ElevatedButton.styleFrom(
                backgroundColor:  Color(0xFF6F435C),
                foregroundColor: Color(0xFFFFFBF0),
                elevation: 3,
                
              shape:RoundedRectangleBorder(
                
                borderRadius: BorderRadius.circular(10),
              ) 
              ),
               child: Text("Start",
               style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
               ),)),
            )
          ],
         ),), 
        )
            ],
          ),),
        ),
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