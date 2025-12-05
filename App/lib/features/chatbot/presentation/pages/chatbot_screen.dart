import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      ChatMessage(
        text: 'Hi! I\'m your Pet Care Assistant. How can I help you with your pet today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      _isLoading = true;
    });

    // Simulate bot response delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: _getBotResponse(message),
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
      }
    });
  }

  String _getBotResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('vaccin')) {
      return 'Vaccinations are important for your pet\'s health. Most pets need core vaccines like DHPP (dogs) or FVRCP (cats). Consult your vet for a vaccination schedule tailored to your pet.';
    } else if (lowerMessage.contains('food') || lowerMessage.contains('diet')) {
      return 'A balanced diet is crucial for your pet\'s health. Different ages and breeds have different nutritional needs. I recommend consulting your veterinarian for personalized dietary recommendations.';
    } else if (lowerMessage.contains('sick') || lowerMessage.contains('ill')) {
      return 'If your pet seems sick, it\'s best to consult a veterinarian as soon as possible. Common signs include lethargy, loss of appetite, vomiting, or diarrhea. Please seek professional help!';
    } else if (lowerMessage.contains('training') || lowerMessage.contains('behavior')) {
      return 'Pet training takes patience and consistency. Positive reinforcement works best. For specific behavioral issues, consider consulting a professional trainer or veterinary behaviorist.';
    } else if (lowerMessage.contains('exercise') || lowerMessage.contains('activity')) {
      return 'Daily exercise is essential for pets. Dogs typically need 30 minutes to 2 hours depending on breed, while cats benefit from interactive play sessions. Ensure your pet gets adequate physical activity!';
    } else if (lowerMessage.contains('vet') || lowerMessage.contains('doctor')) {
      return 'Regular vet check-ups are important. Most pets should visit the vet at least once a year, or more frequently for senior pets or those with health issues.';
    } else {
      return 'That\'s a great question! For detailed advice about your specific pet\'s needs, I recommend consulting with your veterinarian. They can provide personalized guidance based on your pet\'s health history.';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.accent,
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pet Care Assistant',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final reversedIndex = _messages.length - 1 - index;
                final message = _messages[reversedIndex];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Thinking...',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 16.h),

          // Input Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'Ask about pet care...',
                      hintStyle: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (!_isLoading) {
                        _sendMessage(value);
                      }
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: AppColors.accent,
                      size: 20.sp,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: message.isUser
              ? null
              : Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: (message.isUser ? AppColors.primary : AppColors.primary)
                  .withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: message.isUser ? AppColors.accent : AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _formatTime(message.timestamp),
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 11.sp,
                color: message.isUser
                    ? AppColors.accent.withOpacity(0.6)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
