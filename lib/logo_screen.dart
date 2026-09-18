import 'package:bano_qabil_exam/Student/home_screen.dart';
import 'package:bano_qabil_exam/Teacher/teacher_dashboard.dart';
import 'package:bano_qabil_exam/controller/controller_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  // ============================================================
  // VARIABLES
  // ============================================================

  int selectedTab = 0;

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String selectedRole = "";

  // Login controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Registration controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController registerEmailController =
  TextEditingController();
  final TextEditingController _passwordController =
  TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xFF6F435C);
  static const Color lightBackground = Color(0xFFFFFBF0);
  static const Color inputBackground = Color.fromARGB(255, 255, 227, 243);

  // ============================================================
  // LOGIN + ROLE NAVIGATION
  // ============================================================

  Future<void> _loginAndNavigate() async {
    if (selectedRole.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please select a module first."),
      backgroundColor: Colors.orange,
    ),
  );
  return;
}
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // 1. Login through Firebase Authentication
      // ----------------------------------------------------------

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception("User login failed.");
      }

      // ----------------------------------------------------------
      // 2. Get user document from Firestore
      // users/{uid}
      // ----------------------------------------------------------
String collectionName;

if (selectedRole == "Student") {
  collectionName = "student";
} else if (selectedRole == "Teacher") {
  collectionName = "teacher";
} else {
  collectionName = "controller";
}

final DocumentSnapshot userDoc = await FirebaseFirestore.instance
    .collection(collectionName)
    .doc(user.uid)
    .get();
      

      if (!userDoc.exists) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "User profile not found in Firestore.",
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      // ----------------------------------------------------------
      // 3. Read role
      // ----------------------------------------------------------

      final data = userDoc.data() as Map<String, dynamic>;

      final String role =
      (data['role'] ?? '').toString().trim().toLowerCase();
      final String selectedModule = selectedRole.trim().toLowerCase();

        if (role != selectedModule) {
       await FirebaseAuth.instance.signOut();

        if (!mounted) return;

         setState(() {
         _isLoading = false;
           });

           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
             content: Text(
            "This account is not registered as ${selectedRole}.",
               ),
             backgroundColor: Colors.red,
             ),
              );

               return;
              }

      debugPrint("Logged in user: ${user.email}");
      debugPrint("Firebase UID: ${user.uid}");
      debugPrint("Firestore role: $role");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // ----------------------------------------------------------
      // 4. Navigate according to Firestore role
      // ----------------------------------------------------------

      if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else if (role == 'teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TeacherDashboard(),
          ),
        );
      } else if (role == 'controller') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ControllerDashboard(),
          ),
        );
      } else {
        // Unknown role
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Unknown user role: ${data['role']}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message = "Login failed.";

      if (e.code == 'user-not-found') {
        message = "No account found with this email.";
      } else if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = "Invalid email or password.";
      } else if (e.code == 'invalid-email') {
        message = "Please enter a valid email.";
      } else if (e.code == 'user-disabled') {
        message = "This account has been disabled.";
      } else if (e.code == 'too-many-requests') {
        message = "Too many login attempts. Please try again later.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // REGISTRATION
  // ============================================================

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a role first."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // 1. Create Firebase Authentication account
      // ----------------------------------------------------------

      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: registerEmailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception("Registration failed.");
      }

      // ----------------------------------------------------------
      // 2. Create users/{uid} document
      // ----------------------------------------------------------

   
         String collectionName;

if (selectedRole == "Student") {
  collectionName = "student";
} else if (selectedRole == "Teacher") {
  collectionName = "teacher";
} else {
  collectionName = "controller";
}

await FirebaseFirestore.instance
    .collection(collectionName)
    .doc(user.uid)
    .set({
  'name': nameController.text.trim(),
  'email': registerEmailController.text.trim(),
  'role': selectedRole,
  'createdAt': FieldValue.serverTimestamp(),
});
         
      //     .set({
      //   'name': nameController.text.trim(),
      //   'email': registerEmailController.text.trim(),
      //   'role': selectedRole,
      //   'createdAt': FieldValue.serverTimestamp(),
      // });

      debugPrint("Registered user UID: ${user.uid}");
      debugPrint("Registered role: $selectedRole");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful!"),
          backgroundColor: Colors.green,
        ),
      );

      // ----------------------------------------------------------
      // 3. Navigate according to selected role
      // ----------------------------------------------------------

      final String role = selectedRole.trim().toLowerCase();

      if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else if (role == 'teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TeacherDashboard(),
          ),
        );
      } else if (role == 'controller') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ControllerDashboard(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message = "Registration failed.";

      if (e.code == 'email-already-in-use') {
        message = "This email is already registered.";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak.";
      } else if (e.code == 'invalid-email') {
        message = "Please enter a valid email.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DEMO NAVIGATION
  // ============================================================

 void _openStudentDemo() {
  setState(() {
    selectedRole = "Student";
  });
}

void _openTeacherDemo() {
  setState(() {
    selectedRole = "Teacher";
  });
}

void _openControllerDemo() {
  setState(() {
    selectedRole = "Controller";
  });
}
  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    registerEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        color: primary,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // ROLE CARD
  // ============================================================

  Widget _roleCard({
    required String role,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7B5E8E)
                : primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 35,
              color: primary,
            ),
            const SizedBox(height: 8),
            Text(
              role,
              style: const TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: lightBackground,
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      const Text(
                        "Bano Qabil",
                        style: TextStyle(
                          color: primary,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Text(
                        "Exam",
                        style: TextStyle(
                          color: primary,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Text(
                        "Test your knowledge",
                        style: TextStyle(
                          color: primary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Text(
                        "Build your Future",
                        style: TextStyle(
                          color: primary,
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

                // ==================================================
                // LOGIN / REGISTER TABS
                // ==================================================

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = 0;
                              _formKey.currentState?.reset();
                            });
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: selectedTab == 0
                                  ? primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: primary,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: selectedTab == 0
                                      ? Colors.white
                                      : primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = 1;
                              _formKey.currentState?.reset();
                            });
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: selectedTab == 1
                                  ? primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: primary,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Register",
                                style: TextStyle(
                                  color: selectedTab == 1
                                      ? Colors.white
                                      : primary,
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

                // ==================================================
                // LOGIN FORM
                // ==================================================

                if (selectedTab == 0)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email
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
                            AutovalidateMode.onUserInteraction,
                            keyboardType:
                            TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your email';
                              }

                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }

                              return null;
                            },
                            decoration: _inputDecoration(
                              hintText: "Enter your Email",
                              icon: Icons.email,
                            ),
                          ),
                        ),

                        // Password
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
                            AutovalidateMode.onUserInteraction,
                            obscureText: _obscurePassword,
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
                            decoration: _inputDecoration(
                              hintText: "Enter your Password",
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                    !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forget Password?",
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        // Login button
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                              _isLoading ? null : _loginAndNavigate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 25,
                                width: 25,
                                child:
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : const Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )

                // ==================================================
                // REGISTRATION FORM
                // ==================================================

                else
                  Form(
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
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Full Name
                          const Text(
                            "Full Name:",
                            style: TextStyle(
                              color: primary,
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
                            decoration: _inputDecoration(
                              hintText: "Enter your full name",
                              icon: Icons.person,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Email
                          const Text(
                            "Email:",
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 5),

                          TextFormField(
                            controller: registerEmailController,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your email';
                              }

                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }

                              return null;
                            },
                            keyboardType:
                            TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              hintText: "Enter your Email",
                              icon: Icons.email_outlined,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Password
                          const Text(
                            "Password:",
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 5),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
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
                            decoration: _inputDecoration(
                              hintText: "Enter your Password",
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                    !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Confirm Password
                          const Text(
                            "Confirm Password:",
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 5),

                          TextFormField(
                            controller:
                            _confirmPasswordController,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter your Password';
                              }

                              if (value !=
                                  _passwordController.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                            decoration: _inputDecoration(
                              hintText: "Confirm your Password",
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                    !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Role selection title
                          const Text(
                            "Select Role:",
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Role buttons
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _roleCard(
                                  role: "Student",
                                  icon: Icons.school,
                                  onTap: () {
                                    setState(() {
                                      selectedRole = "Student";
                                    });
                                  },
                                ),

                                const SizedBox(width: 10),

                                _roleCard(
                                  role: "Teacher",
                                  icon: Icons.person,
                                  onTap: () {
                                    setState(() {
                                      selectedRole = "Teacher";
                                    });
                                  },
                                ),

                                const SizedBox(width: 10),

                                _roleCard(
                                  role: "Controller",
                                  icon:
                                  Icons.admin_panel_settings,
                                  onTap: () {
                                    setState(() {
                                      selectedRole = "Controller";
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Register button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                              _isLoading ? null : _registerUser,
                              style: ElevatedButton.styleFrom(
                                elevation: 5,
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child:
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : const Text(
                                "Register",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
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
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedTab = 0;
                                    _formKey.currentState?.reset();
                                  });
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: primary,
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

                // ==================================================
                // DEMO LOGIN
                // ==================================================

                const SizedBox(height: 20),

                const Text(
                  "Demo Login (Choose Role)",
                  style: TextStyle(
                    color: primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      // Student Demo
                      _roleCard(
                        role: "Student",
                        icon: Icons.school,
                        onTap: _openStudentDemo,
                      ),

                      const SizedBox(width: 10),

                      // Teacher Demo
                      _roleCard(
                        role: "Teacher",
                        icon: Icons.person,
                        onTap: _openTeacherDemo,
                      ),

                      const SizedBox(width: 10),

                      // Controller Demo
                      _roleCard(
                        role: "Controller",
                        icon: Icons.admin_panel_settings,
                        onTap: _openControllerDemo,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}