import 'package:banoqabi_exam/Upcoming_Exam.dart';
import 'package:banoqabi_exam/home_screen.dart';
import 'package:banoqabi_exam/profile_user.dart';
import 'package:flutter/material.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
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