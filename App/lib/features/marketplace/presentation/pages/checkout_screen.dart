import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/marketplace_models.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedPayment = 'cash_on_delivery';

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal =>
      widget.cartItems.fold(0.0, (s, i) => s + i.totalPrice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF191D21),
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.mulish(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF191D21),
          ),
        ),
      ),
      body: BlocListener<CartCubit, CartState>(
        listener: (context, state) {
          if (state.lastOrder != null) {
            _showOrderSuccessDialog(context, state.lastOrder!);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!, style: GoogleFonts.mulish()),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckoutHeader(),

                SizedBox(height: 14.h),

                // Order summary card
                _buildSection(
                  title: 'Order Summary',
                  icon: Icons.receipt_long_outlined,
                  child: Column(
                    children: [
                      ...widget.cartItems.map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 9.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F6F2),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.product?.name ?? 'Product',
                                    style: GoogleFonts.mulish(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.22),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    'x${item.quantity}',
                                    style: GoogleFonts.mulish(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2C6E69),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'PKR ${item.totalPrice.toStringAsFixed(0)}',
                                  style: GoogleFonts.mulish(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF191D21),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(color: const Color(0xFFE0E0E0), height: 1.h),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: GoogleFonts.mulish(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'PKR ${_subtotal.toStringAsFixed(0)}',
                            style: GoogleFonts.mulish(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF191D21),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery',
                            style: GoogleFonts.mulish(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'PKR 150',
                            style: GoogleFonts.mulish(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF191D21),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.mulish(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF191D21),
                            ),
                          ),
                          Text(
                            'PKR ${(_subtotal + 150).toStringAsFixed(0)}',
                            style: GoogleFonts.mulish(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2C6E69),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Shipping address
                _buildSection(
                  title: 'Delivery Address',
                  icon: Icons.location_on_outlined,
                  subtitle: 'Where should we deliver your order?',
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _addressController,
                        hint:
                            'Street, Area, City (e.g. House 12, Block B, DHA, Lahore)',
                        maxLines: 3,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your delivery address';
                          }
                          if (val.trim().length < 10) {
                            return 'Please enter a more detailed address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _phoneController,
                        hint: 'Phone number (e.g. 0300-1234567)',
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Payment method
                _buildSection(
                  title: 'Payment Method',
                  icon: Icons.payment_outlined,
                  subtitle: 'Choose your preferred payment option',
                  child: Column(
                    children: [
                      _buildPaymentOption(
                        value: 'cash_on_delivery',
                        label: 'Cash on Delivery',
                        subtitle: 'Pay when your order arrives',
                        icon: Icons.money_outlined,
                      ),
                      SizedBox(height: 8.h),
                      _buildPaymentOption(
                        value: 'bank_transfer',
                        label: 'Bank Transfer',
                        subtitle: 'Transfer to our account',
                        icon: Icons.account_balance_outlined,
                      ),
                      SizedBox(height: 8.h),
                      _buildPaymentOption(
                        value: 'easypaisa',
                        label: 'Easypaisa',
                        subtitle: 'Pay via Easypaisa mobile wallet',
                        icon: Icons.phone_android_outlined,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Notes (optional)
                _buildSection(
                  title: 'Order Notes (Optional)',
                  icon: Icons.note_outlined,
                  subtitle: 'Mention any delivery preferences',
                  child: _buildTextField(
                    controller: _notesController,
                    hint: 'Any special instructions for your order...',
                    maxLines: 2,
                  ),
                ),

                SizedBox(height: 24.h),

                // Place order button
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            state.isPlacingOrder
                                ? null
                                : () => _placeOrder(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C6E69),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child:
                            state.isPlacingOrder
                                ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.white,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Place Order',
                                      style: GoogleFonts.mulish(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: const Color(0xFF2C6E69)),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.mulish(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF191D21),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: GoogleFonts.mulish(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckoutHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.24),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              size: 18.sp,
              color: const Color(0xFF2C6E69),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Checkout',
                  style: GoogleFonts.mulish(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191D21),
                  ),
                ),
                Text(
                  'Review your details and place order confidently',
                  style: GoogleFonts.mulish(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.mulish(
        fontSize: 14.sp,
        color: const Color(0xFF191D21),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.mulish(
          fontSize: 13.sp,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F6F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF2C6E69), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String label,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color:
              selected
                  ? const Color(0xFF2C6E69).withOpacity(0.08)
                  : const Color(0xFFF8F6F2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? const Color(0xFF2C6E69) : const Color(0xFFE0E0E0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color:
                    selected
                        ? const Color(0xFF2C6E69)
                        : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 18.sp,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.mulish(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF191D21),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.mulish(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      selected
                          ? const Color(0xFF2C6E69)
                          : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child:
                  selected
                      ? Center(
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2C6E69),
                          ),
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final shippingAddress = _addressController.text.trim();
    final shippingPhone = _phoneController.text.trim();

    final request = PlaceOrderRequest(
      shippingAddress: shippingAddress,
      shippingPhone: shippingPhone,
      paymentMethod: _selectedPayment,
      notes:
          _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
    );

    context.read<CartCubit>().placeOrder(request);
  }

  void _showOrderSuccessDialog(BuildContext context, order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 40.sp,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Order Placed!',
                    style: GoogleFonts.mulish(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191D21),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your order has been placed successfully. We\'ll notify you when it\'s confirmed.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mulish(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context); // close dialog
                            Navigator.pop(context); // close checkout
                            Navigator.pop(context); // close cart
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2C6E69)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.mulish(
                              color: const Color(0xFF2C6E69),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // close dialog
                            Navigator.pop(context); // close checkout
                            Navigator.pop(context); // close cart
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrdersScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C6E69),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            elevation: 0,
                          ),
                          child: Text(
                            'My Orders',
                            style: GoogleFonts.mulish(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
