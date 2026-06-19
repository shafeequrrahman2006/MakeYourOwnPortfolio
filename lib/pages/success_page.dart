import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../providers/registration_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_button.dart';
import '../widgets/glow_background.dart';

class SuccessPage extends ConsumerWidget {
  const SuccessPage({super.key});

  Future<void> _launchWhatsApp(String requestId, String name) async {
    final message = Uri.encodeComponent(
      'Hi MUOP Team! My name is $name. I have successfully submitted my portfolio request with ID: $requestId. Please guide me forward. 🚀',
    );
    final url = Uri.parse('https://wa.me/919943431749?text=$message');
    
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationProvider);
    final request = state.submittedRequest;
    final requestId = request?.requestId ?? 'MUOP-2026-001';
    final fullName = request?.fullName ?? state.fullName;

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Navbar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          height: 28,
                          width: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'MUOP',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Success Card
                    GlassCard(
                      animateHover: false,
                      isHighlighted: false,
                      hoverBorderColor: MUOPTheme.primaryYellow,
                      hoverGlowColor: MUOPTheme.glowColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Circular success icon with glow
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: MUOPTheme.primaryYellow,
                              boxShadow: MUOPTheme.glowShadow(
                                color: MUOPTheme.primaryYellow.withOpacity(0.4),
                                radius: 20,
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Welcome Title
                          const Text(
                            '🎉 Welcome to MUOP!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),

                          // Subtext
                          Text(
                            'Your registration has been submitted successfully.\nOur team will contact you shortly.',
                            style: TextStyle(
                              fontSize: 14,
                              color: MUOPTheme.secondaryText.withOpacity(0.8),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),

                          // Request ID Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161616),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: MUOPTheme.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'REQUEST ID: ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: MUOPTheme.secondaryText,
                                  ),
                                ),
                                Text(
                                  requestId,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: MUOPTheme.primaryYellow,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Side by side metric boxes
                          Row(
                            children: [
                              // Status Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF161616),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: MUOPTheme.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.flash_on, color: MUOPTheme.primaryYellow, size: 18),
                                      const SizedBox(height: 12),
                                      Text(
                                        'STATUS',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: MUOPTheme.secondaryText.withOpacity(0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Active',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Response Time Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF161616),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: MUOPTheme.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.access_time, color: MUOPTheme.primaryYellow, size: 18),
                                      const SizedBox(height: 12),
                                      Text(
                                        'RESPONSE TIME',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: MUOPTheme.secondaryText.withOpacity(0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        '< 24 Hours',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Chat on WhatsApp Button
                          SizedBox(
                            width: double.infinity,
                            child: PremiumButton(
                              text: 'Chat on WhatsApp',
                              icon: const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 18),
                              onPressed: () => _launchWhatsApp(requestId, fullName),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Return to Portfolio Button
                          TextButton(
                            onPressed: () {
                              ref.read(registrationProvider.notifier).resetForm();
                              Navigator.of(context).pushReplacementNamed('/');
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back, color: MUOPTheme.secondaryText, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Return to Portfolio',
                                  style: TextStyle(
                                    color: MUOPTheme.secondaryText,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Trusted Developers tag
                    Text(
                      'TRUSTED BY DEVELOPERS WORLDWIDE',
                      style: TextStyle(
                        color: MUOPTheme.secondaryText.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '© 2026 MUOP Portfolio Services. All rights reserved.',
                            style: TextStyle(
                              fontSize: 10,
                              color: MUOPTheme.secondaryText.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 10,
                                color: MUOPTheme.secondaryText.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontSize: 10,
                                color: MUOPTheme.secondaryText.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
