import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/auth_service.dart'; // Fixed path
import '../teacher/teacher_panel_screen.dart';
import '../student/student_home_screen.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => LoginScreenState(); // Matches class name below
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isTeacher = true; // Default to teacher login
  bool _isLoading = false;
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // In a real app, use your auth service to handle login
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.login(
          _usernameController.text,
          _passwordController.text,
          _isTeacher,
        );
        
        // Navigate to the appropriate screen based on user type
        if (_isTeacher) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const TeacherPanelScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentHomeScreen(),
            ),
          );
        }
      } catch (e) {
        // Handle login errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאת התחברות: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('כניסה'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo or Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // User type selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Teacher Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isTeacher = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isTeacher
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                              foregroundColor: _isTeacher
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            child: const Text(AppStrings.teacherLogin),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Student Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isTeacher = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_isTeacher
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                              foregroundColor: !_isTeacher
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            child: const Text(AppStrings.studentLogin),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Username Field
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.enterUsername,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'אנא הכנס שם משתמש';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: AppStrings.enterPassword,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'אנא הכנס סיסמה';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                AppStrings.loginButtonText,
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}