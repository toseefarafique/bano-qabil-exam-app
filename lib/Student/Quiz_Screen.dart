import 'package:bano_qabil_exam/Student/Result_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selectedOption;
  int correctAnswer = 0;
  Timer? _timer;

Duration _remainingTime = const Duration(minutes: 30);
Duration _timeUsed = Duration.zero;
DateTime? _startTime;
@override
void initState() {
  super.initState();

  _startTime = DateTime.now();

  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_remainingTime.inSeconds > 0) {
      setState(() {
        _remainingTime -= const Duration(seconds: 1);
        _timeUsed = DateTime.now().difference(_startTime!);
      });
    } else {
      _submitExam();
    }
  });
}
String formatTime(Duration duration) {
  String hours = duration.inHours.toString().padLeft(2, '0');
  String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  if (duration.inHours > 0) {
    return "$hours:$minutes:$seconds";
  }

  return "$minutes:$seconds";
}
void _submitExam() {
  _timer?.cancel();

  if (_startTime != null) {
    _timeUsed = DateTime.now().difference(_startTime!);

    if (_timeUsed > const Duration(minutes: 30)) {
      _timeUsed = const Duration(minutes: 30);
    }
  }

  debugPrint("Time Used: ${formatTime(_timeUsed)}");

  // Result screen yahan open hogi
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xFF6F435C),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back,
       color:Color(0xFFFFFBF0),
       size: 30, )),

       title: Text("Question Player",
       style: TextStyle(
        fontSize: 25,
        color:Color(0xFFFFFBF0),
        fontWeight: FontWeight.bold,
       ),),

       actions: [
  Padding(
    padding: const EdgeInsets.only(right: 25),
    child: Center(
      child: Row(
        children: [
        Icon(Icons.timer,
        color: Color(0xFFFFFBF0),
        size: 28,),
        SizedBox(width: 5),
          Text(
        formatTime(_remainingTime),
        style: const TextStyle(
          fontSize: 20,
          color: Color(0xFFFFFBF0),
          fontWeight: FontWeight.bold,
        ),
      ),
        ],
      ),
    ),
  ),
],
      ),

    body: SingleChildScrollView(
      child: Container(
        color: Color(0xFFFFFBF0),
      child: Padding(padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("3/20",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF6F435C),
            ),),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: 0.35,
               minHeight: 8,
               color: Color(0xFF6F435C),
                borderRadius: BorderRadius.circular(15),
                 ),
            SizedBox(height: 20),
            Text("Q1:  Which widget is used as the root of a Flutter app?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),) ,
            SizedBox(height: 10),
       // A
GestureDetector(
  onTap: () {
    setState(() {
      selectedOption = 0;
    });
  },
  child: Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    decoration: BoxDecoration(
      color: selectedOption == 0
          ? const Color(0xFFE8D9E3)
          : Colors.transparent,
      border: Border.all(
        color: Color(0xFF6F435C),
      ),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      'A. MaterialApp',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),
),

SizedBox(height: 12),

// B
GestureDetector(
  onTap: () {
    setState(() {
      selectedOption = 1;
    });
  },
  child: Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    decoration: BoxDecoration(
      color: selectedOption == 1
          ? const Color(0xFFE8D9E3)
          : Colors.transparent,
      border: Border.all(
        color: Color(0xFF6F435C),
      ),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      'B. Builder Function',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

SizedBox(height: 12),

// C
GestureDetector(
  onTap: () {
    setState(() {
      selectedOption = 2;
    });
  },
  child: Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    decoration: BoxDecoration(
      color: selectedOption == 2
          ? const Color(0xFFE8D9E3)
          : Colors.transparent,
      border: Border.all(
        color: Color(0xFF6F435C),
      ),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      'C. Stream Builder',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

SizedBox(height: 12),

// D
GestureDetector(
  onTap: () {
    setState(() {
      selectedOption = 3;
    });
  },
  child: Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    decoration: BoxDecoration(
      color: selectedOption == 3
          ? const Color(0xFFE8D9E3)
          : Colors.transparent,
      border: Border.all(
        color: Color(0xFF6F435C),
      ),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      'D. Scaffold',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),
),
       Padding(padding: EdgeInsets.all(40),
       child:Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(onPressed:(){

          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 241, 232, 243),
            fixedSize: Size(130, 50),
            side: BorderSide(
               color: Color(0xFF6F435C),
               width: 1.5
            ),
            shape: RoundedRectangleBorder(
              
              borderRadius: BorderRadius.circular(20),
              
            ),
            
          ), child: Padding(padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flag,
              color: Color(0xFF6F435C),
              size: 25,),
              Text("Flag",
              style: TextStyle(
                color: Color(0xFF6F435C),
                fontSize: 20,
              ),),

            ],
          )),),
          SizedBox(width: 30),
         TextButton(onPressed:(){

          },
          
          style: TextButton.styleFrom(
            fixedSize: Size(130, 50),
            backgroundColor: const Color.fromARGB(255, 240, 226, 243),
            side: BorderSide(
               color: Color(0xFF6F435C),
               width: 1.5
            ),
            shape: RoundedRectangleBorder(
              
              borderRadius: BorderRadius.circular(20),
              
            ),
            
          ),
          child: Padding(padding: EdgeInsets.all(0),
           child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_upward,
              color: Color(0xFF6F435C),
              size: 25,),
              Text("Jump To",
              style: TextStyle(
                color: Color(0xFF6F435C),
                fontSize: 20,
              ),),

            ],
          )),), 
        ],
       )),
       SizedBox(height: 10),
       Padding(padding: EdgeInsets.all(20),
       child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: (){},
          style: ElevatedButton.styleFrom(
             backgroundColor: Color(0xFF6F435C),
             foregroundColor: Color(0xFFFFFBF0),
             elevation: 2,
             fixedSize: Size(160, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )   
          ),
           child: Text("Previous",
           style: TextStyle(
              
          fontSize: 22,
          fontWeight: FontWeight.w700,
            ),
           ),),
          SizedBox(width: 80),
           ElevatedButton(onPressed: (){
            Navigator.push(context,
            MaterialPageRoute(builder: (context)=> ResultScreen() ));
             if (selectedOption == null) {
              debugPrint("Please select an option");
      return;
    }

    if (selectedOption == correctAnswer) {
      debugPrint("Correct Answer");
    } else {
      debugPrint("Wrong Answer");
    }
           },
          style: ElevatedButton.styleFrom(
             backgroundColor: Color(0xFF6F435C),
             foregroundColor: Color(0xFFFFFBF0),
             elevation: 2,
             fixedSize: Size(160, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )   
          ),
           child: Text("Next",
           style: TextStyle(
              
          fontSize: 22,
          fontWeight: FontWeight.w700,
            ),
           ),)

        ],
       ),)
            
          ],
        ),
      ),
    ),
    ),  
    );
  }
  @override
void dispose() {
  _timer?.cancel();
  super.dispose();
}
}