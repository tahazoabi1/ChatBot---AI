// lib/screens/student/student_chat_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/chat_message.dart';
import '../../widgets/chat_bubble.dart';

class StudentChatScreen extends StatefulWidget {
  final String initialMode;
  
  const StudentChatScreen({
    Key? key,
    this.initialMode = 'practice',
  }) : super(key: key);

  @override
  State<StudentChatScreen> createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;
  late String _currentMode;
  File? _capturedImage;
  bool _showAssistanceOptions = false;
  bool _isTyping = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentMode = widget.initialMode;
    
    // Add welcome message
    _addBotMessage('היי! איך אני יכול לעזור לך היום?');
    
    // If initial mode is capture, open camera
    if (_currentMode == 'capture') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _captureTask();
      });
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Stop recording if app goes to background
      if (_isRecording) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _addBotMessage(String content) {
    if (!mounted) return;
    
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: content,
          timestamp: DateTime.now(),
          sender: SenderType.bot,
        ),
      );
    });
    _scrollToBottom();
  }
  
  void _addUserMessage(String content, {MessageType type = MessageType.text}) {
    if (!mounted) return;
    
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: content,
          timestamp: DateTime.now(),
          sender: SenderType.student,
          type: type,
        ),
      );
    });
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = _messageController.text.trim();
      _addUserMessage(message);
      _messageController.clear();
      
      // Simulate AI response
      _processBotResponse(message);
    }
  }
  
  void _processBotResponse(String userMessage) {
    if (!mounted) return;
    
    // Show typing indicator
    setState(() {
      _isTyping = true;
      _messages.add(
        ChatMessage(
          id: 'typing-${DateTime.now().millisecondsSinceEpoch}',
          content: 'typing',
          timestamp: DateTime.now(),
          sender: SenderType.bot,
          type: MessageType.systemMessage,
        ),
      );
    });
    _scrollToBottom();
    
    // Simulate processing delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      // Remove typing indicator
      setState(() {
        _isTyping = false;
        _messages.removeWhere((message) => 
          message.type == MessageType.systemMessage && 
          message.content == 'typing'
        );
      });
      
      // Add response based on user message
      String response;
      if (userMessage.contains('?') || userMessage.toLowerCase().contains('שאלה') || 
          userMessage.toLowerCase().contains('עזרה')) {
        response = 'אני אשמח לעזור לך. האם תוכל להסביר יותר על המשימה?';
        setState(() {
          _showAssistanceOptions = true;
        });
      } else if (userMessage.toLowerCase().contains('תודה') || 
                userMessage.toLowerCase().contains('הבנתי')) {
        response = 'בשמחה! האם יש משהו נוסף שאוכל לעזור בו?';
        setState(() {
          _showAssistanceOptions = false;
        });
      } else {
        response = 'הבנתי את השאלה שלך. בוא ננסה להבין את המשימה ביחד. האם תוכל לספר לי יותר על מה שאתה צריך לעשות?';
        setState(() {
          _showAssistanceOptions = true;
        });
      }
      
      _addBotMessage(response);
      
      // Ask for feedback after bot response
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _showFeedbackDialog();
      });
    });
  }
  
  void _handleAssistanceOption(String option) {
    if (!mounted) return;
    
    late String userMessage;
    late String botResponse;
    
    switch (option) {
      case 'breakdown':
        userMessage = 'אנא פרק את המשימה לשלבים';
        botResponse = 'בוודאי! הנה המשימה מפורקת לשלבים קטנים:\n\n1. קרא את המשימה בעיון\n2. הבן מה נדרש ממך\n3. תכנן את השלבים לפתרון\n4. פתור כל שלב בנפרד\n5. בדוק את עבודתך';
        break;
      case 'demonstrate':
        userMessage = 'תן לי דוגמה בבקשה';
        botResponse = 'הנה דוגמה לפתרון המשימה: [כאן תופיע דוגמה מפורטת של המשימה הספציפית]';
        break;
      case 'explain':
        userMessage = 'אנא הסבר את המשימה';
        botResponse = 'בשמחה! המשימה מבקשת ממך לבצע את הפעולות הבאות: [כאן יופיע הסבר מפורט של המשימה הספציפית]';
        break;
      default:
        return;
    }
    
    _addUserMessage(userMessage);
    
    // Simulate AI processing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _addBotMessage(botResponse);
      
      // Ask for feedback
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _showFeedbackDialog();
      });
    });
  }
  
  Future<void> _captureTask() async {
    if (!mounted) return;
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null && mounted) {
        final File imageFile = File(image.path);
        setState(() {
          _capturedImage = imageFile;
        });
        
        // Add task image to chat
        _addUserMessage(
          'תמונת משימה',
          type: MessageType.taskCapture,
        );
        
        // Simulate text extraction
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          _addBotMessage('אני מעבד את המשימה שצילמת...');
          
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            _addBotMessage('זיהיתי את המשימה הבאה: \n\nכתוב חיבור בנושא "לאהוב את הטבע שמסביבנו" בהיקף של 30-40 שורות. לאחר מכן ענה על שאלות הבנה הקשורות לנושא.');
            
            Future.delayed(const Duration(seconds: 1), () {
              if (!mounted) return;
              setState(() {
                _showAssistanceOptions = true;
              });
            });
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה בצילום המשימה: $e')),
        );
      }
    }
  }
  
  void _showFeedbackDialog() {
    // Don't show feedback dialog if it's already showing or screen is not mounted
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('משוב'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(AppStrings.satisfaction),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeedbackOption(dialogContext, 1, AppStrings.poor),
                _buildFeedbackOption(dialogContext, 2, ''),
                _buildFeedbackOption(dialogContext, 3, AppStrings.average),
                _buildFeedbackOption(dialogContext, 4, ''),
                _buildFeedbackOption(dialogContext, 5, AppStrings.excellent),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeedbackOption(BuildContext context, int rating, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            rating <= 2 ? Icons.sentiment_dissatisfied : 
            rating == 3 ? Icons.sentiment_neutral : 
            Icons.sentiment_satisfied,
            color: rating <= 2 ? Colors.red : 
                  rating == 3 ? Colors.amber : 
                  Colors.green,
            size: 30,
          ),
          onPressed: () {
            // Save feedback
            debugPrint('User rated response: $rating/5');
            Navigator.of(context).pop();
          },
        ),
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('שיחה עם לרנובוט'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Cloud-like background
            Container(
              height: 80,
              width: double.infinity,
              color: AppColors.skyBackground,
              child: Stack(
                children: [
                  // Cloud shapes
                  Positioned(
                    left: 20,
                    top: 10,
                    child: _buildCloud(70),
                  ),
                  Positioned(
                    right: 40,
                    top: 5,
                    child: _buildCloud(90),
                  ),
                  Positioned(
                    left: 130,
                    top: 30,
                    child: _buildCloud(60),
                  ),
                  // Mode indicator
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentMode == 'practice' ? AppStrings.practiceMode :
                        _currentMode == 'test' ? AppStrings.testMode : 'צילום משימה',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Chat Messages
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.skyBackground,
                      AppColors.background,
                    ],
                  ),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(15),
                  itemCount: _messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final message = _messages[index];
                    
                    // Typing indicator
                    if (message.type == MessageType.systemMessage && 
                        message.content == 'typing') {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15, bottom: 15),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.botBubble,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const SizedBox(
                              width: 50,
                              child: Center(
                                child: Text('...'),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    
                    // Task capture message
                    if (message.type == MessageType.taskCapture) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ChatBubble(
                              message: message,
                              showAvatar: index == 0 || 
                                _messages[index - 1].sender != message.sender,
                            ),
                            if (_capturedImage != null) ...[
                              const SizedBox(height: 5),
                              Container(
                                margin: const EdgeInsets.only(left: 50),
                                height: 150,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primary),
                                  image: DecorationImage(
                                    image: FileImage(_capturedImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                    
                    // Regular chat message
                    return ChatBubble(
                      key: ValueKey(message.id),
                      message: message,
                      showAvatar: index == 0 || 
                        _messages[index - 1].sender != message.sender,
                    );
                  },
                ),
              ),
            ),
            
            // Assistance options (Breakdown, Demonstrate, Explain)
            if (_showAssistanceOptions)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAssistanceButton(
                      'פירוק לשלבים',
                      Icons.format_list_numbered,
                      () => _handleAssistanceOption('breakdown'),
                    ),
                    _buildAssistanceButton(
                      'הדגמה',
                      Icons.play_circle_outline,
                      () => _handleAssistanceOption('demonstrate'),
                    ),
                    _buildAssistanceButton(
                      'הסבר',
                      Icons.lightbulb_outline,
                      () => _handleAssistanceOption('explain'),
                    ),
                  ],
                ),
              ),
            
            // Message Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  // Navigation button (back)
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left),
                    onPressed: () => Navigator.of(context).maybePop(),
                    color: AppColors.primary,
                  ),
                  
                  // Text input
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          hintText: AppStrings.enterQuestion,
                          hintTextDirection: TextDirection.rtl,
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        textInputAction: TextInputAction.send,
                        keyboardType: TextInputType.text,
                        enableSuggestions: true,
                      ),
                    ),
                  ),
                  
                  // Send button
                  IconButton(
                    icon: const Icon(Icons.send, size: 22),
                    onPressed: _sendMessage,
                    color: AppColors.primary,
                  ),
                  
                  // Emoji button
                  IconButton(
                    icon: const Icon(Icons.sentiment_satisfied_alt),
                    onPressed: () {
                      // Show emoji picker or reaction options
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('תכונת אימוג׳י תהיה זמינה בקרוב'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            
            // Bottom actions
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              color: AppColors.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Voice record button
                  IconButton(
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isRecording = !_isRecording;
                      });
                      
                      if (_isRecording) {
                        // Show recording indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('מקליט...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        // Simulate voice recognition
                        _addUserMessage('הודעה קולית');
                        _processBotResponse('האם אתה יכול לעזור לי עם המשימה?');
                      }
                    },
                  ),
                  
                  // Camera button
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    onPressed: _captureTask,
                  ),
                  
                  // Call teacher button
                  IconButton(
                    icon: const Icon(
                      Icons.school,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('הודעה נשלחה למורה'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCloud(double size) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
  
  Widget _buildAssistanceButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}