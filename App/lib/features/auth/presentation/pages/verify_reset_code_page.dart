import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'new_password_page.dart';

class VerifyResetCodePage extends StatefulWidget {
  final String email;
  final String resetToken; // token returned from backend (in dev); in prod user types what they received by email

  const VerifyResetCodePage({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends State<VerifyResetCodePage> {
  // 6 individual digit controllers for OTP-style input
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get _enteredCode =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete => _enteredCode.length == 6;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  void _proceed() {
    if (!_isComplete) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewPasswordPage(
          email: widget.email,
          resetToken: _enteredCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF3),
      body: SafeArea(
        child: Column(
          children: [
            // Hero header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4E9F9A),
                    Color(0xFF2F6E72),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(Icons.mark_email_read_outlined,
                        color: Colors.white, size: 36.sp),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Check Your Email',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.88),
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'We sent a reset code to\n'),
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // OTP input section
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    Text(
                      'Enter 6-digit code',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 46.w,
                          height: 56.h,
                          child: RawKeyboardListener(
                            focusNode: FocusNode(),
                            onKey: (event) => _onKeyEvent(index, event),
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary, width: 2.5),
                                ),
                              ),
                              onChanged: (value) =>
                                  _onDigitChanged(index, value),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 12.h),
                    // Dev hint: show the token so user can paste it
                    if (widget.resetToken.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 16.sp, color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Dev mode — your token: ${widget.resetToken}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _isComplete ? _proceed : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          disabledBackgroundColor:
                              Theme.of(context).colorScheme.primary.withOpacity(0.35),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Verify Code',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Resend Code',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


