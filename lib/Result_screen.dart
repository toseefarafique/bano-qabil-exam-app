import 'package:banoqabi_exam/Review_Answer.dart';
import 'package:banoqabi_exam/home_screen.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xFFFFFBF0),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back,
        color: Color(0xFF6F435C),
        size: 30)),
        
        title: Text("Quiz Result",
          style: TextStyle(
             color: Color(0xFF6F435C),
             fontSize: 25,
             fontWeight: FontWeight.bold,
          ),),
         
      ),
      body: SingleChildScrollView(
        child: Container(
         color:Color(0xFFFFFBF0),
          padding: EdgeInsets.all(5),
          child: Center(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             Text("🏆",
             style: TextStyle(
              fontSize: 90,
             ),),
             Text("Great Job!",
             style: TextStyle(
              color: Color(0xFF6F435C),
             fontSize: 28,
             fontWeight: FontWeight.bold,
             ),),
             Text("You have completed the Quiz.",
             style: TextStyle(
              color: Color(0xFF6F435C),
             fontSize: 18,
             fontWeight: FontWeight.bold,
             ),),
             SizedBox(height: 15),
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 2,
                  color: Colors.white,
                child: Container(
                  width: 150,
                  child: Padding(padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Score",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                       color: Color(0xFF6F435C),
                    ),),
                     Text("16/20",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                       color: Color(0xFF6F435C),
                    ),),
                  ],
                ),),  
                ),
                ),
                SizedBox(width: 30),
                 Card(
                  elevation: 2,
                  color: Colors.white,
                child: Container(
                  width: 150,
                  child: Padding(padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Percentage",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                       color: Color(0xFF6F435C),
                    ),),
                     Text("80%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                       color: Color(0xFF6F435C),
                    ),),
                  ],
                ),),  
                ),
                ),
              ],
             ),
             Padding(padding: EdgeInsets.all(20),
             child:Card(
              elevation: 2,
              color: const Color.fromARGB(255, 205, 241, 206),
             child:Padding(padding: EdgeInsets.all(20),
             child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified,
                color: Colors.green,
                size: 70,),
                SizedBox(width: 10),
              Column(
                children: [
                  Text("Status",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                  ),),
                   Text("Pass",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),),
                ],
              )  
              ],
             ),) ,
             )),
             Padding(padding: EdgeInsets.only(left: 20,right: 20),
             child: Card(
              elevation: 2,
              color: Colors.white,
              child: Container(
                width: double.infinity,
                child: Padding(padding: EdgeInsets.all(20),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Time Used",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6F435C),
                  ),),
                   Text("16m 56s",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6F435C),
                  ),),
                ],
              ),),
              ),
             ),),
             SizedBox(height: 20),
             ElevatedButton(onPressed: (){
              Navigator.push(context,
              MaterialPageRoute(builder: (context)=> ReviewAnswer()));
             },
             
             style: ElevatedButton.styleFrom(
              
              fixedSize: Size(320, 55),
              backgroundColor:Color(0xFF6F435C), 
              foregroundColor: Color(0xFFFFFBF0),
              shape: RoundedRectangleBorder(
                
                borderRadius: BorderRadius.circular(10)
              )
             ),
              child: Padding(padding: EdgeInsets.all(10),
              child: Text("Review Answers",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),)),),
              Padding(padding: EdgeInsets.all(20),
               child:ElevatedButton(onPressed: (){
                Navigator.push(context,
                 MaterialPageRoute(builder: (context)=> HomeScreen()));
               },
             
             style: ElevatedButton.styleFrom(
              
              fixedSize: Size(320, 55),
              backgroundColor:Color(0xFF6F435C), 
              foregroundColor: Color(0xFFFFFBF0),
              shape: RoundedRectangleBorder(
                
                borderRadius: BorderRadius.circular(10)
              )
             ),
              child: Padding(padding: EdgeInsets.all(10),
              child: Text("Back to Home",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),)),)
              )
            ],
          ),
          ),
        ),
      ),
    );
  }
}