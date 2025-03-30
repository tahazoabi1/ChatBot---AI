// lib/screens/student/student_home_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/notification_widget.dart';
import 'student_chat_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: AppColors.primary,
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'מסך ראשי',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'שלום, נועם! מה ברצונך לשאול?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LearnoBot Logo or Image
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(75),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.smart_toy,
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Start Conversation Button
                    ElevatedButton.icon(
                      onPressed: () {
                        _showModeSelectionDialog(context);
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        AppStrings.startChat,
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30, 
                          vertical: 15,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Upload Task Button
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentChatScreen(
                              initialMode: 'capture',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text(
                        AppStrings.uploadTask,
                        style: TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30, 
                          vertical: 12,
                        ),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Info
            Container(
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              child: const Text(
                'לחץ "התחל שיחה" כדי לקבל עזרה עם משימה',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showModeSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'בחר מצב שיחה',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Practice Mode Button
              _buildModeButton(
                context,
                title: AppStrings.practiceMode,
                icon: Icons.school,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentChatScreen(
                        initialMode: 'practice',
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 15),
              
              // Test Mode Button
              _buildModeButton(
                context,
                title: AppStrings.testMode,
                icon: Icons.quiz,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentChatScreen(
                        initialMode: 'test',
                      ),
                    ),
                  );
                },
                isLocked: true,
              ),
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('ביטול'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildModeButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return Material(
      color: isLocked ? Colors.grey.shade200 : AppColors.primaryLight.withOpacity(0.2),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLocked ? Colors.grey : AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isLocked ? Colors.grey : AppColors.textDark,
                  ),
                ),
              ),
              if (isLocked)
                const Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
