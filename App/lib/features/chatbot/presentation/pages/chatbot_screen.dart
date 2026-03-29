import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/chatbot_repository.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ChatbotRepository _chatbotRepo = getIt<ChatbotRepository>();
  bool _isLoading = false;
  static const List<String> _quickPrompts = [
    'My pet is not eating. What should I do?',
    'Create a basic vaccination reminder checklist.',
    'What are warning signs that need an emergency vet?',
    'Suggest a healthy routine for a 2-year-old cat.',
  ];

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

  void _sendMessage(String message) async {
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
    _scrollToBottom();

    try {
      // Call real RAG chatbot API
      final response = await _chatbotRepo.query(message);
      
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: response.answer,
              isUser: false,
              timestamp: DateTime.now(),
              sources: response.sources
                  .map((s) => s.metadata['source']?.toString() ?? '')
                  .where((s) => s.isNotEmpty)
                  .toList(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Sorry, I encountered an error. Please try again.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canSend = !_isLoading && _messageController.text.trim().isNotEmpty;

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
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.45)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pets_rounded,
                        color: AppColors.darkTeal,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI assistant for everyday pet care',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'For emergencies, contact a licensed vet immediately.',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            if (_messages.length == 1)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                child: _buildQuickPromptSection(),
              ),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 8.h),
                child: Row(
                  children: [
                    SizedBox(
                      height: 16.w,
                      width: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.darkTeal),
                      ),
                    ),
                    SizedBox(width: 10.w),
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
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isLoading,
                      maxLines: 3,
                      minLines: 1,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.send,
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
                            color: AppColors.darkTeal.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide(
                            color: AppColors.darkTeal.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide(
                            color: AppColors.darkTeal,
                            width: 1.6,
                          ),
                        ),
                      ),
                      onSubmitted: (_) {
                        if (canSend) {
                          _sendMessage(_messageController.text);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: canSend
                          ? AppColors.darkTeal
                          : AppColors.darkTeal.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: IconButton(
                      tooltip: 'Send message',
                      icon: Icon(
                        Icons.send_rounded,
                        color: AppColors.surface,
                        size: 20.sp,
                      ),
                      onPressed:
                          canSend ? () => _sendMessage(_messageController.text) : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPromptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try asking',
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _quickPrompts
              .map(
                (prompt) => ActionChip(
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.45)),
                  label: Text(
                    prompt,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onPressed: _isLoading ? null : () => _sendMessage(prompt),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.82.sw),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.darkTeal : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(message.isUser ? 16.r : 4.r),
            bottomRight: Radius.circular(message.isUser ? 4.r : 16.r),
          ),
          border: message.isUser
              ? null
              : Border.all(
                  color: AppColors.primary.withOpacity(0.35),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormattedMessageText(message.text, isUser: message.isUser),
            SizedBox(height: 4.h),
            Text(
              _formatTime(message.timestamp),
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 11.sp,
                color: message.isUser
                    ? AppColors.surface.withOpacity(0.72)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedMessageText(String message, {required bool isUser}) {
    final baseStyle = AppTextStyles.onboardingBody.copyWith(
      fontSize: 14.sp,
      color: isUser ? AppColors.surface : AppColors.textPrimary,
      height: 1.45,
    );
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.w700);
    final pattern = RegExp(r'(\*\*.*?\*\*)');
    final parts = message.split(pattern);
    final matches = pattern.allMatches(message).map((m) => m.group(0)!).toList();
    final spans = <TextSpan>[];

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i], style: baseStyle));
      }

      if (i < matches.length) {
        final raw = matches[i];
        final boldText = raw.substring(2, raw.length - 2);
        spans.add(TextSpan(text: boldText, style: boldStyle));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
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
  final List<String>? sources;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources,
  });
}