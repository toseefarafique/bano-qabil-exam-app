import 'package:banoqabi_exam/Student/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  int selectedTab =0;
   final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
 final TextEditingController _passwordController = TextEditingController();
 final _confirmPasswordController = TextEditingController();
 String selectedRole = "";

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController nameController = TextEditingController();
final TextEditingController registerEmailController =
    TextEditingController();
   @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: SingleChildScrollView(
        child: Container(
        color: const Color(0xFFFFFBF0),
          child: Column(
            children: [
            Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
            Text("Bano Qabil",
            style: TextStyle(
              color:Color(0xFF6F435C),
              fontSize: 25,
              fontWeight: FontWeight.bold
            ),),
            Text("Exam",
            style: TextStyle(
              color: Color(0xFF6F435C),
              fontSize: 25,
              fontWeight: FontWeight.bold
            ),),
            Text("Test your knowledge",
            style: TextStyle(
              color:Color(0xFF6F435C),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),),
            Text("Build your Future",
            style: TextStyle(
              color: Color(0xFF6F435C),
              fontSize: 15,
              fontWeight: FontWeight.bold
            ),),
            Image.asset('assets/images/book_logo1.png',
            height: 110,
            width: 220,
            fit: BoxFit.contain,),
            ],
          ),
          
        ),
       Padding(padding: EdgeInsets.all(20),
        child:Row(
          children: [
            Expanded(child: GestureDetector(
              onTap:(){
                
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
                      child: Text("Login",
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
                     child: Text("Register",
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
        Container(
          child: Column(
            children: [
               Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(top: 8,left: 15),
         child: Text("Email:",
         style: TextStyle(
         fontWeight: FontWeight.bold,
         fontSize: 18),),),
        
         Padding(padding: EdgeInsets.only(left: 25,right: 25),
          child:TextFormField(
            controller: emailController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value){
              if(value==null ||value.trim().isEmpty){
                return 'Please enter a valid email';
              }
              if(!value.contains('@')){
                return 'Please enter a valid email';
              }
              return null;
            },
            
            keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            
            hintText: "Enter your Email",
            prefixIcon: Icon(Icons.email,
            color: Color(0xFF6F435C),),
            filled: true,
            fillColor:  Color.fromARGB(255, 255, 227, 243),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            )
          ),
          ),),
         Padding(padding: EdgeInsets.only(left: 15,top: 8),
         child: Text("Password:",
         style: TextStyle(
         fontWeight: FontWeight.bold,
         fontSize: 20),),),
        
       Padding(padding: EdgeInsets.only(left: 25,right: 25),

        child:TextFormField(
          controller: passwordController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if(value==null || value.trim().isEmpty){
              return 'Enter your Password';
            }
          if(value.length<6){
            return 'Password must be at least 6 characters';
          }  
     return null;
  },
  
          obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: "Enter your Password",
          prefixIcon: Icon(Icons.lock_outline,
          color:  Color(0xFF6F435C),),
          suffixIcon:IconButton(
           icon:Icon(_obscurePassword
          ?Icons.visibility_outlined
          :Icons.visibility_off_outlined,
          color: Color(0xFF6F435C),
          ),
          onPressed: (){
            setState(() {
              _obscurePassword =!_obscurePassword;
            });
          },),
          
          filled: true,
          fillColor: Color.fromARGB(255, 255, 227, 243),
           border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            )
        ),)
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: (){},
           child: Text("Forget Password?",
           style: TextStyle(color:Color(0xFF6F435C), 
           fontWeight: FontWeight.w500),)),
        ),
        Padding(padding: EdgeInsets.only(left: 20,right: 20),
       child: Align(alignment: AlignmentGeometry.center,
        child: ElevatedButton(
         onPressed: () async {
  if (_formKey.currentState!.validate()) {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";

      if (e.code == 'user-not-found') {
        message = "No account found with this email";
      } else if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = "Invalid email or password";
      } else if (e.code == 'invalid-email') {
        message = "Please enter a valid email";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
  }
},
        style: ElevatedButton.styleFrom(
          backgroundColor:Color(0xFF6F435C),
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity,52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          )
        ),
         child: Text("Login",
         style: TextStyle(
          color: Colors.white,
         fontWeight: FontWeight.bold,
         fontSize: 25),)),
        )),
              
            ],
          ),
        ),
            ],
          ),
        )
        else
        Container(
          child: Form(
        key: _formKey,
         child: Padding(padding: EdgeInsets.only(left: 18,top: 5,right: 18),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text("Please Register to Continue",
              style: TextStyle(
                color: Color(0xFF6F435C),
                fontWeight: FontWeight.bold,
              ),),
              
              Text("Full Name:",style: TextStyle(
                color: Color(0xFF6F435C),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),),
              SizedBox(height: 5,),
             TextFormField(
            controller: registerEmailController,
            validator: (value){
              if(value==null ||value.trim().isEmpty){
                return 'Please enter a valid email';
              }
             return null;
            },
          
            keyboardType: TextInputType.name,
          decoration: InputDecoration(
            
            hintText: "Enter your full name",
            prefixIcon: Icon(Icons.person,
            color: Color(0xFF6F435C),),
            filled: true,
           fillColor:  Color.fromARGB(255, 255, 227, 243),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            )
          ),
          ),

           SizedBox(height: 15),
              Text("Email:",style: TextStyle(
                color: Color(0xFF6F435C),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),),
             TextFormField(
            
            validator: (value){
              if(value==null ||value.trim().isEmpty){
                return 'Please enter a valid email';
              }
              if(!value.contains('@')){
                return 'Please anter a valid email';
              }
             return null;
            },
          
            keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            
            hintText: "Enter your Email",
            prefixIcon: Icon(Icons.email_outlined,
            color: Color(0xFF6F435C),),
            filled: true,
            fillColor:  Color.fromARGB(255, 255, 227, 243),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            )
          ),
          ),

           SizedBox(height: 15),
              Text("Password:",style: TextStyle(
                color: Color(0xFF6F435C),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),),
            TextFormField(
          
          validator: (value) {
            if(value==null || value.trim().isEmpty){
              return 'Enter your Password';
            }
          if(value.length<6){
            return 'Password must be at least 6 characters';
          }  
     return null;
  },
          controller: _passwordController,
          obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: "Enter your Password",
          prefixIcon: Icon(Icons.lock_outline,
          color: Color(0xFF6F435C),),
          suffixIcon:IconButton(
           icon:Icon(_obscurePassword
          ?Icons.visibility_outlined
          :Icons.visibility_off_outlined,
          color: Color(0xFF6F435C),
          ),
          onPressed: (){
            setState(() {
              _obscurePassword =!_obscurePassword;
            });
          },),
          
          filled: true,
          fillColor:  Color.fromARGB(255, 255, 227, 243),
           border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            )
        ),),

        SizedBox(height: 15),
              Text("Confirm Password:",style: TextStyle(
                color: Color(0xFF6F435C),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),),
            TextFormField(
          validator: (value) {
            if(value==null || value.trim().isEmpty){
              return 'Enter your Password';
            }
          if(value != _passwordController.text){
            return 'Password do not match';
          }  
     return null;
  },
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: "Confirm your Password",
          prefixIcon: Icon(Icons.lock_outline,
          color: Color(0xFF6F435C),),
          suffixIcon:IconButton(
           icon:Icon(_obscurePassword
          ?Icons.visibility_outlined
          :Icons.visibility_off_outlined,
          color: Color(0xFF6F435C),
          ),
          onPressed: (){
            setState(() {
              _obscurePassword =!_obscurePassword;
            });
          },),
          
          filled: true,
          fillColor: Color.fromARGB(255, 255, 227, 243),
           border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            )
        ),),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
  if (_formKey.currentState!.validate()) {
    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a role first"),
        ),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: registerEmailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': nameController.text.trim(),
        'email': registerEmailController.text.trim(),
        'role': selectedRole,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful!"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";

      if (e.code == 'email-already-in-use') {
        message = "This email is already registered";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak";
      } else if (e.code == 'invalid-email') {
        message = "Please enter a valid email";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
  }
},
        
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: Color(0xFF6F435C),
          foregroundColor: Colors.white,
        minimumSize: Size(double.infinity,50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          )
        ),
         child: Text("Register",style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
         ),)),
         SizedBox(height: 5),
         Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
      
            Text("Already have an account?",style: TextStyle(
              color: Color(0xFF6F435C),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),),
            TextButton(onPressed: (){
             Navigator.pop(context);
            },
             child: Text("Login",style: TextStyle(
              color: Color(0xFF6F435C),
              fontWeight: FontWeight.bold,
              fontSize: 18,
             ),))
          ],
         ),
            ],
          ),),
       ),
          
        ),
        SizedBox(height: 20),
        Text("Demo Login(Choose Role)",
        style: TextStyle(
          color: Color(0xFF6F435C),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),),
        SizedBox(height: 20),
        Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [

    // Student
    GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = "Student";
         
          });
        Navigator.push(context,
         MaterialPageRoute(builder: (context)=> HomeScreen()));
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white, // Dusty Purple
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selectedRole == "Student"
                ? const Color(0xFF7B5E8E)
                : Color(0xFF6F435C),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.school,
              size: 35,
              color: Color(0xFF6F435C),
            ),
            const SizedBox(height: 8),
            const Text(
              "Student",
              style: TextStyle(
                color: Color(0xFF6F435C),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (selectedRole == "Student")
              const Icon(
                Icons.check_circle,
                color: Color(0xFF6F435C),
                size: 18,
              ),
          ],
        ),
      ),
    ),

    // Teacher
    GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = "Teacher";
        
        });
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white, // Dusty Purple
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selectedRole == "Teacher"
                ? const Color(0xFF7B5E8E)
                :Color(0xFF6F435C),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.person,
              size: 35,
              color: Color(0xFF6F435C),
            ),
            const SizedBox(height: 8),
            const Text(
              "Teacher",
              style: TextStyle(
                color: Color(0xFF6F435C),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (selectedRole == "Teacher")
              const Icon(
                Icons.check_circle,
                color: Color(0xFF6F435C),
                size: 18,
              ),
          ],
        ),
      ),
    ),

    // Controller
    GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = "Controller";
        
        });
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,// Dusty Purple
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selectedRole == "Controller"
                ? const Color(0xFF7B5E8E)
                : Color(0xFF6F435C),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 35,
              color: Color(0xFF6F435C),
            ),
            const SizedBox(height: 8),
            const Text(
              "Controller",
              style: TextStyle(
                color: Color(0xFF6F435C),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (selectedRole == "Controller")
              const Icon(
                Icons.check_circle,
                color: Color(0xFF6F435C),
                size: 18,
              ),
          ],
        ),
      ),
    ),
  ],
)
            ],
          ),
        ),
      ),
     );
  }
}