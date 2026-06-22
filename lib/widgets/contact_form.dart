import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/contact_form_provider.dart';
import 'glass_card.dart';
import 'premium_button.dart';

/// A premium, responsive Contact Form Widget integrated with FirestoreService
/// and state-managed via Riverpod.
class ContactFormWidget extends ConsumerStatefulWidget {
  const ContactFormWidget({super.key});

  @override
  ConsumerState<ContactFormWidget> createState() => _ContactFormWidgetState();
}

class _ContactFormWidgetState extends ConsumerState<ContactFormWidget>
    with SingleTickerProviderStateMixin {
  // 1. TextEditingControllers connected to input fields (Requirement 1)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedService = 'Portfolio Development';

  // Animation controller for the smooth success transition (Requirement 5)
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize success animation assets
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Clears all input controllers, resets dropdown, and wipes validation state.
  void _resetForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _messageController.clear();
    setState(() {
      _selectedService = 'Portfolio Development';
    });
    ref.read(contactFormProvider.notifier).reset();
  }

  /// Triggers validation, displays loading state, and calls Firestore write.
  Future<void> _submitForm() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Call submit lead to initiate validation and firestore write (Requirement 3 & 7)
    final isSuccess = await ref.read(contactFormProvider.notifier).submitLead(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          service: _selectedService,
          message: _messageController.text,
        );

    if (isSuccess) {
      // 5. On successful save: Show success snackbar (Requirement 5)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.black, size: 20),
              SizedBox(width: 10),
              Text(
                'Inquiry submitted successfully!',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          backgroundColor: MUOPTheme.primaryYellow,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );

      // Play success animation (Requirement 5)
      _animationController.forward(from: 0.0);
    } else {
      // 6. On failure: Show error snackbar (Requirement 6)
      final formState = ref.read(contactFormProvider);
      final errMsg = formState.errorMessage ?? 'Failed to send message. Please check details.';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errMsg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(contactFormProvider);
    final isLoading = formState.status == ContactFormStatus.loading;
    final isSuccess = formState.status == ContactFormStatus.success;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        child: GlassCard(
          animateHover: false,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: isSuccess
                ? _buildSuccessAnimation()
                : _buildForm(formState, isLoading),
          ),
        ),
      ),
    );
  }

  /// Builds the form fields and labels.
  Widget _buildForm(ContactFormState formState, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Get in Touch',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Have questions or want custom designs? Send us an inquiry and we will get back to you.',
          style: TextStyle(
            fontSize: 14,
            color: MUOPTheme.secondaryText.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 28),

        // Name Field
        const Text(
          'Full Name',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: MUOPTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            errorText: formState.nameError,
          ),
        ),
        const SizedBox(height: 18),

        // Email & Phone in a row for desktop, column for mobile
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 500;
            
            final emailField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: MUOPTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'name@example.com',
                    errorText: formState.emailError,
                  ),
                ),
              ],
            );

            final phoneField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: MUOPTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'e.g. +91 98765 43210',
                    errorText: formState.phoneError,
                  ),
                ),
              ],
            );

            if (isNarrow) {
              return Column(
                children: [
                  emailField,
                  const SizedBox(height: 18),
                  phoneField,
                ],
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: emailField),
                  const SizedBox(width: 16),
                  Expanded(child: phoneField),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 18),

        // Service Dropdown
        const Text(
          'Interested Service',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: MUOPTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedService,
          dropdownColor: MUOPTheme.cardBg,
          items: const [
            DropdownMenuItem(
              value: 'Portfolio Development',
              child: Text('Portfolio Development'),
            ),
            DropdownMenuItem(
              value: 'Website Redesign',
              child: Text('Website Redesign'),
            ),
            DropdownMenuItem(
              value: 'Mobile App Development',
              child: Text('Mobile App Development'),
            ),
            DropdownMenuItem(
              value: 'Consulting / Strategy',
              child: Text('Consulting / Strategy'),
            ),
            DropdownMenuItem(
              value: 'Other',
              child: Text('Other'),
            ),
          ],
          onChanged: isLoading
              ? null
              : (val) {
                  if (val != null) {
                    setState(() {
                      _selectedService = val;
                    });
                  }
                },
        ),
        const SizedBox(height: 18),

        // Message field
        const Text(
          'Your Message',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: MUOPTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          enabled: !isLoading,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: 'Tell us about your project/requirements...',
            errorText: formState.messageError,
          ),
        ),
        const SizedBox(height: 28),

        // Submit Button (disables automatically during loading - Requirement 3)
        Align(
          alignment: Alignment.centerRight,
          child: PremiumButton(
            text: 'Send Message 🚀',
            isLoading: isLoading,
            onPressed: isLoading ? null : _submitForm,
          ),
        ),
      ],
    );
  }

  /// Builds a smooth success animation.
  Widget _buildSuccessAnimation() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MUOPTheme.primaryYellow,
                  boxShadow: MUOPTheme.glowShadow(
                    color: MUOPTheme.primaryYellow.withOpacity(0.4),
                    radius: 24,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.black,
                  size: 44,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your message has been sent successfully!\nOur team will review your inquiry and reach out shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: MUOPTheme.secondaryText.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              PremiumButton(
                text: 'Send Another Message',
                isPrimary: false,
                onPressed: _resetForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
