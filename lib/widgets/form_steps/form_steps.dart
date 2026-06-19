import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/registration_provider.dart';
import '../glass_card.dart';

// ==========================================
// STEP 1: PERSONAL DETAILS
// ==========================================
class StepPersonalDetails extends ConsumerStatefulWidget {
  const StepPersonalDetails({super.key});

  @override
  ConsumerState<StepPersonalDetails> createState() => _StepPersonalDetailsState();
}

class _StepPersonalDetailsState extends ConsumerState<StepPersonalDetails> {
  late TextEditingController _nameController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(registrationProvider);
    _nameController = TextEditingController(text: state.fullName);
    _whatsappController = TextEditingController(text: state.whatsapp);
    _emailController = TextEditingController(text: state.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Please enter your name and contact details so we can reach out.',
          style: TextStyle(fontSize: 14, color: MUOPTheme.secondaryText.withOpacity(0.8)),
        ),
        const SizedBox(height: 24),
        
        // Full Name
        Text(
          'Full Name',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MUOPTheme.secondaryText),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'John Doe',
            errorText: state.fullNameError,
          ),
          onChanged: (val) => ref.read(registrationProvider.notifier).updateFullName(val),
        ),
        const SizedBox(height: 18),

        // WhatsApp Number
        Text(
          'WhatsApp Number',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MUOPTheme.secondaryText),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _whatsappController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+91 00000 00000',
            errorText: state.whatsappError,
          ),
          onChanged: (val) => ref.read(registrationProvider.notifier).updateWhatsapp(val),
        ),
        const SizedBox(height: 18),

        // Email Address
        Text(
          'Email Address',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MUOPTheme.secondaryText),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'john@example.com',
            errorText: state.emailError,
          ),
          onChanged: (val) => ref.read(registrationProvider.notifier).updateEmail(val),
        ),
      ],
    );
  }
}

// ==========================================
// STEP 2: CAREER DETAILS
// ==========================================
class StepCareerDetails extends ConsumerStatefulWidget {
  const StepCareerDetails({super.key});

  @override
  ConsumerState<StepCareerDetails> createState() => _StepCareerDetailsState();
}

class _StepCareerDetailsState extends ConsumerState<StepCareerDetails> {
  late TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(registrationProvider);
    _roleController = TextEditingController(text: state.desiredRole);
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Career Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us about your current status and desired role.',
          style: TextStyle(fontSize: 14, color: MUOPTheme.secondaryText.withOpacity(0.8)),
        ),
        const SizedBox(height: 24),

        // Current Status Dropdown
        Text(
          'Status',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MUOPTheme.secondaryText),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: state.status,
          dropdownColor: MUOPTheme.cardBg,
          decoration: const InputDecoration(),
          items: const [
            DropdownMenuItem(value: 'Student', child: Text('Student')),
            DropdownMenuItem(value: 'Fresher', child: Text('Fresher')),
            DropdownMenuItem(value: 'Professional', child: Text('Professional')),
          ],
          onChanged: (val) {
            if (val != null) {
              ref.read(registrationProvider.notifier).updateStatus(val);
            }
          },
        ),
        const SizedBox(height: 18),

        // Desired Role
        Text(
          'Desired Role',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MUOPTheme.secondaryText),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _roleController,
          decoration: InputDecoration(
            hintText: 'e.g. Senior Product Designer',
            errorText: state.desiredRoleError,
          ),
          onChanged: (val) => ref.read(registrationProvider.notifier).updateDesiredRole(val),
        ),
      ],
    );
  }
}

// ==========================================
// STEP 3: RESUME UPLOAD
// ==========================================
class StepResumeUpload extends ConsumerWidget {
  const StepResumeUpload({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationProvider);
    final notifier = ref.read(registrationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resume Upload',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload your resume in PDF, DOC, or DOCX format. Max size 10MB.',
          style: TextStyle(fontSize: 14, color: MUOPTheme.secondaryText.withOpacity(0.8)),
        ),
        const SizedBox(height: 24),

        if (state.resumeBytes == null && !state.isUploading) ...[
          // Upload Area
          InkWell(
            onTap: notifier.pickResume,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.resumeError != null ? Colors.redAccent : MUOPTheme.border,
                  style: BorderStyle.values[1], // Dashed border
                  width: 1.5,
                ),
                color: const Color(0xFF111111),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: MUOPTheme.primaryYellow,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Click or drag your resume here',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Maximum file size 10MB',
                      style: TextStyle(fontSize: 12, color: MUOPTheme.secondaryText.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (state.resumeError != null) ...[
            const SizedBox(height: 8),
            Text(
              state.resumeError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
        ] else if (state.isUploading) ...[
          // Uploading State
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MUOPTheme.border),
              color: MUOPTheme.cardBg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description, color: MUOPTheme.primaryYellow, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.resumeFileName ?? 'Uploading resume...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.uploadProgress,
                    backgroundColor: const Color(0xFF1E1E1E),
                    valueColor: const AlwaysStoppedAnimation<Color>(MUOPTheme.primaryYellow),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Uploading...',
                      style: TextStyle(fontSize: 12, color: MUOPTheme.secondaryText.withOpacity(0.7)),
                    ),
                    Text(
                      '${(state.uploadProgress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 12, color: MUOPTheme.primaryYellow, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          // Uploaded / Success State
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4CAF50)),
              color: const Color(0xFF1B5E20).withOpacity(0.1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.resumeFileName ?? 'resume.pdf',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Uploaded successfully',
                            style: TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: notifier.pickResume,
                      icon: const Icon(Icons.sync, size: 16, color: MUOPTheme.secondaryText),
                      label: const Text('Replace', style: TextStyle(color: MUOPTheme.secondaryText)),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: notifier.removeResume,
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                      label: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ==========================================
// STEP 4: PACKAGE SELECTION
// ==========================================
class StepPackageSelection extends ConsumerWidget {
  const StepPackageSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationProvider);
    final notifier = ref.read(registrationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Package',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the package that fits your needs. You can change this later.',
          style: TextStyle(fontSize: 14, color: MUOPTheme.secondaryText.withOpacity(0.8)),
        ),
        const SizedBox(height: 24),

        // Package Cards Grid/Column
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            
            final studentCard = _buildPackageCard(
              title: 'Student',
              subtitle: 'ENTRY LEVEL',
              price: '₹999',
              features: [
                'Single Page Portfolio',
                '2 Projects Showcase',
                'WhatsApp Support',
                'Standard Delivery',
              ],
              isSelected: state.selectedPackage == 'Student',
              isPopular: false,
              onSelect: () => notifier.selectPackage('Student'),
            );

            final professionalCard = _buildPackageCard(
              title: 'Professional',
              subtitle: 'CAREER GROWTH',
              price: '₹1499',
              features: [
                'Multi-page Experience',
                'Unlimited Project Space',
                'Priority WhatsApp + Call Support',
                'Custom Branding & Logo',
              ],
              isSelected: state.selectedPackage == 'Professional',
              isPopular: true,
              onSelect: () => notifier.selectPackage('Professional'),
            );

            if (isMobile) {
              return Column(
                children: [
                  studentCard,
                  const SizedBox(height: 20),
                  professionalCard,
                ],
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: studentCard),
                  const SizedBox(width: 20),
                  Expanded(child: professionalCard),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String subtitle,
    required String price,
    required List<String> features,
    required bool isSelected,
    required bool isPopular,
    required VoidCallback onSelect,
  }) {
    return GlassCard(
      isHighlighted: isSelected,
      animateHover: !isSelected,
      padding: EdgeInsets.zero,
      onTap: onSelect,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPopular) const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: MUOPTheme.primaryYellow, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'One-time payment',
                          style: TextStyle(fontSize: 10, color: MUOPTheme.secondaryText.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: MUOPTheme.border, height: 1),
                const SizedBox(height: 24),
                ...features.map((feat) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: MUOPTheme.primaryYellow, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feat,
                          style: const TextStyle(fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isSelected 
                        ? MUOPTheme.primaryYellow 
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.transparent : MUOPTheme.border,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isSelected ? 'Selected' : 'Select Package',
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -10,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: MUOPTheme.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// STEP 5: CONFIRMATION
// ==========================================
class StepConfirmation extends ConsumerWidget {
  const StepConfirmation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Please verify your registration information before final submission.',
          style: TextStyle(fontSize: 14, color: MUOPTheme.secondaryText.withOpacity(0.8)),
        ),
        const SizedBox(height: 24),

        // Details list
        _buildInfoRow('Full Name', state.fullName),
        _buildInfoRow('Email Address', state.email),
        _buildInfoRow('WhatsApp Number', state.whatsapp),
        _buildInfoRow('Current Status', state.status),
        _buildInfoRow('Desired Role', state.desiredRole),
        _buildInfoRow('Selected Package', '${state.selectedPackage} Package'),
        _buildInfoRow('Uploaded Resume', state.resumeFileName ?? 'No file uploaded'),

        const SizedBox(height: 12),
        const Text(
          'By clicking submit, you request MUOP to create your custom digital portfolio. Our team will contact you on WhatsApp to discuss details.',
          style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: MUOPTheme.primaryYellow, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFF1E1E1E), height: 1),
        ],
      ),
    );
  }
}
