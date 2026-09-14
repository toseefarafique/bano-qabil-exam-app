import 'package:banoqabi_exam/History.dart';
import 'package:banoqabi_exam/Upcoming_Exam.dart';
import 'package:banoqabi_exam/profile_user.dart';
import 'package:flutter/material.dart';
import 'select_subject.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
       backgroundColor: Color(0xFF6F435C),
      leading: IconButton(onPressed: (){
        Navigator.pop(context);
      },
       icon: Icon(Icons.arrow_back,
       size: 30,
       color: Color(0xFFFFFBF0),)),
     
      title: 
       Text("Bano Qabil Exam",
      style: TextStyle(
        color:  Color(0xFFFFFBF0),
        fontWeight: FontWeight.bold,
        fontSize: 30,
      ),
      
    ),
     
      actions: [
        Padding(padding: EdgeInsets.only(right: 10),
        child:IconButton(onPressed: (){

        },
         icon: Icon(Icons.notifications,
         size: 35,
         color:Color(0xFFFFFBF0),))
        ),
      ],
    ),
    body: SingleChildScrollView(
      child: Container(
           color:  Color(0xFFFFFBF0),
        padding: EdgeInsets.all(20),
     child: Column(
        
        children: [
          Container(
          
            child: Row(
              children: [
                CircleAvatar(
                radius: 40,
                backgroundColor:Color(0xFF6F435C),
                child: Icon(Icons.person,
                color:  Color(0xFFFFFBF0),
                size: 55,),
                ),
                
               Padding(padding: EdgeInsetsGeometry.only(left: 20),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text("Assalam-o-Alaikum",
                    style: TextStyle(
                      color: Color(0xFF6F435C),
                      fontSize: 15,
                      
                    ),),
                    Text("Ayesha Khan",
                    style: TextStyle(
                      color: Color(0xFF6F435C),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),),
                    Text("Keep going! you're doing great!",
                    style: TextStyle(
                      color: Color(0xFF6F435C),
                      fontSize: 15,
                      
                    ),),
                  ],
                )),
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
                
               Text("80%",
                style: TextStyle(
                   color: Color(0xFF6F435C),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),),  

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
               
               Text("5 Days",
                style: TextStyle(
                   color: Color(0xFF6F435C),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),),  
              
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
       Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
               
              elevation: 3,
              color: Colors.white,
             child: InkWell(
                 onTap: () {
                   Navigator.push(context,
                    MaterialPageRoute(builder: (context)=> SelectSubject()));
                 },
              child: Container(
              width: 200,
              
               child: Padding(padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.flutter_dash,
                  
                  size: 35,
                  color: Color(0xFF6F435C),),
                  SizedBox(width: 25),
            Column(
              children: [
                Text("Flutter",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
               Text("3 Quizes",
                style: TextStyle(
                   color: Colors.black38,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),),  

              ],
            )      
                ],
              ),
             ),),
             ), 
             
            ),
            SizedBox(width: 30),
            Card(
               elevation: 5,
              color: Colors.white,
            child: Container(
              width: 200,
              
              child: Padding(padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.web_asset_sharp,
                  size: 35,
                  color: Colors.deepPurple),
                  SizedBox(width: 30),
            Column(
              children: [
                Text("Web",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
               Text("2 Quizes",
                style: TextStyle(
                   color: Colors.black38,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),),  
              
              ],
            )      
                ],
              ),),
            ),
            )
          ],
        ), 
         Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 3,
              color: Colors.white,
             child: Container(
              width: 200,
               child: Padding(padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.security,
                  size: 35,
                  color: Colors.blueAccent),
                  SizedBox(width: 20),
            Column(
              children: [
                Text("Cybersecurity",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
               Text("2 Quizes",
                style: TextStyle(
                   color: Colors.black38,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),),  

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
              
              child: Padding(padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.whatshot,
                  size: 35,
                  color: Colors.deepOrange),
            Column(
              children: [
                Text("Practice Streak",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
               Text("5 Days",
                style: TextStyle(
                   color: Colors.black38,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),),  
              
              ],
            )      
                ],
              ),),
            ),
            )
          ],
        ),
         Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 3,
              color: Colors.white,
             child: Container(
              width: 200,
               child: Padding(padding: EdgeInsets.all(10),
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
               Text("80%",
                style: TextStyle(
                   color: Colors.black38,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),),  

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
               Text("5 Days",
                style: TextStyle(
                   color: Color(0xFF6F435C),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),),  
              
              ],
            )      
                ],
              ),),
            ),
            )
          ],
        ), 
        ], 
     ),
      ),
     
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