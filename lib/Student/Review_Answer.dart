import 'package:flutter/material.dart';

class ReviewAnswer extends StatefulWidget {
  const ReviewAnswer({super.key});

  @override
  State<ReviewAnswer> createState() => _ReviewAnswerState();
}

class _ReviewAnswerState extends State<ReviewAnswer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFFFBF0),
      appBar: AppBar(
        backgroundColor:Color(0xFF6F435C),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        },
         icon: Icon(Icons.arrow_back,
         color: Color(0xFFFFFBF0),
         size: 30,)),
         title: Text("Review Answers",
         style: TextStyle(
          color: Color(0xFFFFFBF0),
          fontSize: 25,
          fontWeight: FontWeight.bold,
         ),),
      ),
      body:SingleChildScrollView(child: Container(
     
        color:Color(0xFFFFFBF0),
        padding: EdgeInsets.all(25),
        child: Column(
          children: [
            Card(
              elevation: 2,
              color: Colors.white,
              child: Padding(padding: EdgeInsets.all(20),
              child: Column(
                children: [
                 
                    Text("Q1: Which widget is used to create a vertical layout?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),),
                  
               
                    Row(
                      children: [
                        Text("Your Answer: B.Row ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),),
                    Icon(Icons.close,
                    color: Colors.red,
                    size: 30,),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Correct Answer: A.Column ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),),
                    Icon(Icons.verified,
                    color: Colors.green,
                    size: 30,),
                      ],
                    ),
                  ],
              
              ),),
            )
          ],
        ),
      ),)
    );
  }
}