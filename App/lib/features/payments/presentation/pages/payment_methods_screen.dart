import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/repositories/payment_methods_repository.dart';
import 'stripe_card_form_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _repo = PaymentMethodsRepository();

  bool _isLoading = true;
  List<PaymentMethodModel> _methods = const [];

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMethods() async {
    setState(() => _isLoading = true);
    try {
      final methods = await _repo.getPaymentMethods();
      if (!mounted) return;
      setState(() => _methods = methods);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  Future<void> _removeMethod(String id) async {
    try {
      await _repo.deletePaymentMethod(id);
      if (!mounted) return;
      await _loadMethods();
      _showSnackBar('Payment method removed');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  Future<void> _setDefault(String id) async {
    try {
      await _repo.setDefaultPaymentMethod(id);
      if (!mounted) return;
      await _loadMethods();
      _showSnackBar('Default payment method updated');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  void _openAddCardSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StripeCardFormScreen(repo: _repo),
      ),
    ).then((_) {
      _loadMethods();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.mulish()),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
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
        title: Text(
          'Card Details',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
        ),
        actions: [
          IconButton(
            onPressed: _openAddCardSheet,
            icon: Icon(Icons.add_card_rounded, color: colorScheme.primary),
            tooltip: 'Add Card',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadMethods,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_outlined, color: colorScheme.primary),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'For security, only the card brand, last 4 digits, and expiry date are saved. No raw card numbers or CVV values are stored.',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 13.sp,
                              color: colorScheme.onSurface,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Saved Cards',
                        style: AppTextStyles.onboardingTitle.copyWith(
                          fontSize: 18.sp,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _openAddCardSheet,
                        icon: Icon(Icons.add, size: 18.sp),
                        label: const Text('Add Card'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  if (_methods.isEmpty)
                    Container(
                      padding: EdgeInsets.all(22.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.credit_card_off_outlined,
                            size: 36.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'No payment methods saved yet',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 15.sp,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Add a card to use the demo checkout flow for marketplace, bookings, caregivers, and vet appointments.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 12.sp,
                              color: colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._methods.map(
                      (method) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: method.isDefault
                                  ? colorScheme.primary.withValues(alpha: 0.35)
                                  : colorScheme.outline.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                method.displayLabel,
                                                style: AppTextStyles.onboardingBody.copyWith(
                                                  fontSize: 15.sp,
                                                  color: colorScheme.onSurface,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            if (method.isDefault)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 4.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(999.r),
                                                ),
                                                child: Text(
                                                  'Default',
                                                  style: AppTextStyles.onboardingBody.copyWith(
                                                    fontSize: 10.sp,
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          method.displayMask,
                                          style: AppTextStyles.onboardingBody.copyWith(
                                            fontSize: 12.sp,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                '${method.brand} • Expires ${method.expiryMonth.toString().padLeft(2, '0')}/${method.expiryYear}',
                                style: AppTextStyles.onboardingBody.copyWith(
                                  fontSize: 12.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  if (!method.isDefault)
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _setDefault(method.id),
                                        child: const Text('Set Default'),
                                      ),
                                    ),
                                  if (!method.isDefault) SizedBox(width: 10.w),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _removeMethod(method.id),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: colorScheme.error,
                                        side: BorderSide(
                                          color: colorScheme.error.withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCardSheet,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Add Card'),
      ),
    );
  }
}