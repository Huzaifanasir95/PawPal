import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/payment_methods_repository.dart';

class StripeCardFormScreen extends StatefulWidget {
  final PaymentMethodsRepository repo;

  const StripeCardFormScreen({
    super.key,
    required this.repo,
  });

  @override
  State<StripeCardFormScreen> createState() => _StripeCardFormScreenState();
}

class _StripeCardFormScreenState extends State<StripeCardFormScreen> {
  final _cardholderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _setAsDefault = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvcController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    final cardNumber = _cardNumberController.text.trim();
    final expiryMonth = _expiryMonthController.text.trim();
    final expiryYear = _expiryYearController.text.trim();
    final cvc = _cvcController.text.trim();
    final cardholder = _cardholderController.text.trim();

    if (cardNumber.isEmpty || expiryMonth.isEmpty || expiryYear.isEmpty || cvc.isEmpty || cardholder.isEmpty) {
      _showSnackBar('Please fill in all card details', isError: true);
      return;
    }

    if (cardNumber.length < 13 || cardNumber.length > 19) {
      _showSnackBar('Invalid card number', isError: true);
      return;
    }

    if (cvc.length < 3 || cvc.length > 4) {
      _showSnackBar('Invalid CVC', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final expiryMonthInt = int.tryParse(expiryMonth) ?? 0;
      final expiryYearInt = int.tryParse(expiryYear) ?? 0;

      if (expiryMonthInt < 1 || expiryMonthInt > 12) {
        _showSnackBar('Invalid expiry month', isError: true);
        return;
      }

      if (expiryYearInt < 2024) {
        _showSnackBar('Card has expired', isError: true);
        return;
      }

      await widget.repo.addPaymentMethod(
        cardholderName: cardholder,
        cardNumber: cardNumber,
        expiryMonth: expiryMonthInt,
        expiryYear: expiryYearInt,
        cvv: cvc,
        nickname: _nicknameController.text.trim().isEmpty
            ? null
            : _nicknameController.text.trim(),
        setAsDefault: _setAsDefault,
      );

      if (!mounted) return;
      _showSnackBar('Card saved successfully');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  Widget _buildCardField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.mulish(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.mulish(
              color: colorScheme.onSurfaceVariant,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.24),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Card',
          style: GoogleFonts.mulish(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Form Title
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.credit_card_rounded,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Card Details',
                        style: GoogleFonts.mulish(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Your card information is secure',
                        style: GoogleFonts.mulish(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // Cardholder Name
            _buildCardField(
              controller: _cardholderController,
              label: 'Cardholder Name',
              hint: 'John Doe',
            ),
            SizedBox(height: 16.h),
            // Card Number
            _buildCardField(
              controller: _cardNumberController,
              label: 'Card Number',
              hint: '1234 5678 9012 3456',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            // Expiry and CVC
            Row(
              children: [
                Expanded(
                  child: _buildCardField(
                    controller: _expiryMonthController,
                    label: 'Expiry Month',
                    hint: 'MM',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildCardField(
                    controller: _expiryYearController,
                    label: 'Expiry Year',
                    hint: 'YYYY',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildCardField(
                    controller: _cvcController,
                    label: 'CVC',
                    hint: '123',
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Card Nickname
            _buildCardField(
              controller: _nicknameController,
              label: 'Card Nickname (optional)',
              hint: 'Personal Visa',
            ),
            SizedBox(height: 16.h),
            // Set as default toggle
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _setAsDefault,
              onChanged: (value) => setState(() => _setAsDefault = value),
              title: Text(
                'Set as default card',
                style: GoogleFonts.mulish(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Security info
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_rounded,
                    size: 18.sp,
                    color: colorScheme.primary,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Your card details are securely masked on our servers.',
                      style: GoogleFonts.mulish(
                        fontSize: 12.sp,
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: CircularProgressIndicator(
                          color: colorScheme.onPrimary,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Save Card',
                        style: GoogleFonts.mulish(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
