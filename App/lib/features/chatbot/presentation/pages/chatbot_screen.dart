import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bool canSend = !_isLoading && _messageController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? colorScheme.surfaceContainerHighest : colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pet Care Assistant',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? <Color>[
                      colorScheme.surface,
                      colorScheme.surfaceContainerHighest,
                    ]
                    : <Color>[
                      colorScheme.surface,
                      colorScheme.surfaceContainer,
                    ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          isDark
                              ? <Color>[
                                colorScheme.surfaceContainer,
                                colorScheme.surfaceContainerHighest,
                              ]
                              : <Color>[
                                colorScheme.surface,
                                colorScheme.surfaceContainer,
                              ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.pets_rounded,
                          color: colorScheme.primary,
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
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'For emergencies, contact a licensed vet immediately.',
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 11.sp,
                                color: colorScheme.onSurfaceVariant,
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
                              AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Thinking...',
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
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
                              color: colorScheme.onSurfaceVariant,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) {
                            if (canSend) {
                              _sendMessage(_messageController.text);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8.w),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: canSend
                              ? colorScheme.primary
                              : colorScheme.primary.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        child: IconButton(
                          tooltip: 'Send message',
                          icon: Icon(
                            Icons.send_rounded,
                            color: colorScheme.onPrimary,
                            size: 20.sp,
                          ),
                          onPressed: canSend
                              ? () => _sendMessage(_messageController.text)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPromptSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try asking',
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _quickPrompts
              .map(
                (prompt) => ActionChip(
                  backgroundColor: colorScheme.surface,
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.35),
                  ),
                  label: Text(
                    prompt,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 12.sp,
                      color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.82.sw),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color:
              message.isUser
                  ? colorScheme.primary
                  : colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(message.isUser ? 16.r : 4.r),
            bottomRight: Radius.circular(message.isUser ? 4.r : 16.r),
          ),
          border: message.isUser
              ? null
              : Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.35),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
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
                    ? colorScheme.onPrimary.withValues(alpha: 0.72)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedMessageText(String message, {required bool isUser}) {
    final colorScheme = Theme.of(context).colorScheme;

    final baseStyle = AppTextStyles.onboardingBody.copyWith(
      fontSize: 14.sp,
      color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
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