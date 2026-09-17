import 'package:bano_qabil_exam/Student/home_screen.dart';
import 'package:bano_qabil_exam/controller/controller_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'teacher/teacher_dashboard.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  int selectedTab = 0;

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController registerEmailController =
      TextEditingController();

  String selectedRole = "";

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    registerEmailController.dispose();

    super.dispose();
  }

  // ================= LOGIN FUNCTION =================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!mounted) return;

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User profile not found"),
          ),
        );
        return;
      }

      final data = userDoc.data();

      final role = data?['role'];

      // ================= TEACHER =================

      if (role == "Teacher") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TeacherDashboard(),
          ),
        );
      }

      // ================= CONTROLLER =================

      else if (role == "Controller") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ControllerDashboard(),
          ),
        );
      }

      // ================= STUDENT =================

      else if (role == "Student") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }

      // ================= INVALID ROLE =================

      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid user role"),
          ),
        );
      }
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
  }

  // ================= REGISTER FUNCTION =================

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
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

      // After registration go to correct dashboard
      if (selectedRole == "Teacher") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TeacherDashboard(),
          ),
        );
      } else if (selectedRole == "Controller") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ControllerDashboard(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";

      if (e.code == 'email-already-in-use') {
        message = "This email is already registered";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak";
      } else if (e.code == 'invalid-email') {
        message = "Please enter a valid email";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFFFFBF0),
          child: Column(
            children: [
              // ================= LOGO / TITLE =================

              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      "Bano Qabil",
                      style: TextStyle(
                        color: Color(0xFF6F435C),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      "Exam",
                      style: TextStyle(
                        color: Color(0xFF6F435C),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      "Test your knowledge",
                      style: TextStyle(
                        color: Color(0xFF6F435C),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      "Build your Future",
                      style: TextStyle(
                        color: Color(0xFF6F435C),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Image.asset(
                      'assets/images/book_logo1.png',
                      height: 110,
                      width: 220,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              // ================= LOGIN / REGISTER TABS =================

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // LOGIN TAB
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = 0;
                          });
                        },
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: selectedTab == 0
                                ? const Color(0xFF6F435C)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF6F435C),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: selectedTab == 0
                                    ? Colors.white
                                    : const Color(0xFF6F435C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    // REGISTER TAB
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = 1;
                          });
                        },
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: selectedTab == 1
                                ? const Color(0xFF6F435C)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF6F435C),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Register",
                              style: TextStyle(
                                color: selectedTab == 1
                                    ? Colors.white
                                    : const Color(0xFF6F435C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =========================================================
              // LOGIN FORM
              // =========================================================

              if (selectedTab == 0)
                Container(
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // EMAIL
                            const Padding(
                              padding: EdgeInsets.only(
                                top: 8,
                                left: 15,
                              ),
                              child: Text(
                                "Email:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(
                                left: 25,
                                right: 25,
                              ),
                              child: TextFormField(
                                controller: emailController,
                                autovalidateMode:
                                    AutovalidateMode
                                        .onUserInteraction,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter a valid email';
                                  }

                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }

                                  return null;
                                },
                                keyboardType:
                                    TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: "Enter your Email",
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Color(0xFF6F435C),
                                  ),
                                  filled: true,
                                  fillColor: const Color.fromARGB(
                                    255,
                                    255,
                                    227,
                                    243,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),

                            // PASSWORD
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 15,
                                top: 8,
                              ),
                              child: Text(
                                "Password:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(
                                left: 25,
                                right: 25,
                              ),
                              child: TextFormField(
                                controller: passwordController,
                                autovalidateMode:
                                    AutovalidateMode
                                        .onUserInteraction,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Enter your Password';
                                  }

                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }

                                  return null;
                                },
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: "Enter your Password",
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF6F435C),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF6F435C),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword =
                                            !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: const Color.fromARGB(
                                    255,
                                    255,
                                    227,
                                    243,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),

                            // FORGOT PASSWORD
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Forget Password?",
                                  style: TextStyle(
                                    color: Color(0xFF6F435C),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // LOGIN BUTTON
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF6F435C),
                                  foregroundColor: Colors.white,
                                  minimumSize:
                                      const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )

              // =========================================================
              // REGISTER FORM
              // =========================================================

              else
                Container(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 18,
                        top: 5,
                        right: 18,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Please Register to Continue",
                            style: TextStyle(
                              color: Color(0xFF6F435C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // FULL NAME
                          const Text(
                            "Full Name:",
                            style: TextStyle(
                              color: Color(0xFF6F435C),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 5),

                          TextFormField(
                            controller: nameController,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your full name';
                              }

                              return null;
                            },
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              hintText: "Enter your full name",
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Color(0xFF6F435C),
                              ),
                              filled: true,
                              fillColor: const Color.fromARGB(
                                255,
                                255,
                                227,
                                243,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // EMAIL
                          const Text(
                            "Email:",
                            style: TextStyle(
                              color: Color(0xFF6F435C),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          TextFormField(
                            controller: registerEmailController,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter a valid email';
                              }

                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }

                              return null;
                            },
                            keyboardType:
                                TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "Enter your Email",
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Color(0xFF6F435C),
                              ),
                              filled: true,
                              fillColor: const Color.fromARGB(
                                255,
                                255,
                                227,
                                243,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // PASSWORD
                          const Text(
                            "Password:",
                            style: TextStyle(
                              color: Color(0xFF6F435C),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          TextFormField(
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter your Password';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: "Enter your Password",
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF6F435C),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF6F435C),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                        !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color.fromARGB(
                                255,
                                255,
                                227,
                                243,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // CONFIRM PASSWORD
                          const Text(
                            "Confirm Password:",
                            style: TextStyle(
                              color: Color(0xFF6F435C),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          TextFormField(
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter your Password';
                              }

                              if (value !=
                                  _passwordController.text) {
                                return 'Password do not match';
                              }

                              return null;
                            },
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: "Confirm your Password",
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF6F435C),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF6F435C),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                        !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color.fromARGB(
                                255,
                                255,
                                227,
                                243,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // REGISTER BUTTON
                          ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              elevation: 5,
                              backgroundColor:
                                  const Color(0xFF6F435C),
                              foregroundColor: Colors.white,
                              minimumSize:
                                  const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: Color(0xFF6F435C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedTab = 0;
                                  });
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Color(0xFF6F435C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // ================= DEMO LOGIN =================
                  
              const Text(
                "Demo Login (Choose Role)",
                style: TextStyle(
                  color: Color(0xFF6F435C),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  // ================= STUDENT =================

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRole = "Student";
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const HomeScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(15),
                        border: Border.all(
                          color: selectedRole == "Student"
                              ? const Color(0xFF7B5E8E)
                              : const Color(0xFF6F435C),
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

                  // ================= TEACHER =================
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TeacherDashboard(),
      ),
    );
  },
  child: Container(
    width: 120,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: const Color(0xFF6F435C),
        width: 2,
      ),
    ),
    child: const Column(
      children: [
        Icon(
          Icons.person,
          size: 35,
          color: Color(0xFF6F435C),
        ),

        SizedBox(height: 8),

        Text(
          "Teacher",
          style: TextStyle(
            color: Color(0xFF6F435C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),

                  // ================= CONTROLLER =================

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRole = "Controller";
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ControllerDashboard(),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(15),
                        border: Border.all(
                          color: selectedRole == "Controller"
                              ? const Color(0xFF7B5E8E)
                              : const Color(0xFF6F435C),
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
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}