import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/registration_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_button.dart';
import '../widgets/stepper/stepper_widget.dart';
import '../widgets/form_steps/form_steps.dart';
import '../widgets/glow_background.dart';
import '../widgets/contact_form.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  final GlobalKey _formSectionKey = GlobalKey();
  final GlobalKey _contactSectionKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToForm() {
    final context = _formSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToContact() {
    final context = _contactSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _selectPackageAndRegister(String package) {
    ref.read(registrationProvider.notifier).selectPackage(package);
    _scrollToForm();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;
    
    final regState = ref.watch(registrationProvider);
    final regNotifier = ref.read(registrationProvider.notifier);

    // Listen to submission status changes to navigate to success page
    ref.listen(registrationProvider.select((s) => s.submissionStatus), (prev, next) {
      if (next == SubmissionStatus.success) {
        Navigator.of(context).pushReplacementNamed('/success');
      }
    });

    return Scaffold(
      body: GlowBackground(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // ==========================================
              // NAVIGATION BAR
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'MUOP',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    
                    // Nav Actions
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/admin');
                          },
                          child: Text(
                            'Admin Portal',
                            style: TextStyle(
                              color: MUOPTheme.secondaryText.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: _scrollToContact,
                          child: Text(
                            'Contact Us',
                            style: TextStyle(
                              color: MUOPTheme.secondaryText.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        PremiumButton(
                          text: 'Get Started',
                          isPrimary: true,
                          onPressed: _scrollToForm,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ==========================================
              // HERO SECTION
              // ==========================================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: isMobile ? 40.0 : 80.0,
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Powered Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: MUOPTheme.border),
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF111111),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: MUOPTheme.primaryYellow,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'POWERED BY DEOPLEXIS',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: MUOPTheme.secondaryText,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'STILL APPLYING FOR JOBS',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: isMobile ? 32 : (isTablet ? 42 : 54),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'WITHOUT A PORTFOLIO?',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: isMobile ? 32 : (isTablet ? 42 : 54),
                            fontWeight: FontWeight.bold,
                            color: MUOPTheme.primaryYellow,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Subheadline
                        Text(
                          'Get a professional portfolio that showcases your skills, projects, and achievements to recruiters and clients with elite digital craftsmanship.',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: MUOPTheme.secondaryText,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),

                        // CTA Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PremiumButton(
                              text: 'Build My Portfolio 🚀',
                              isPrimary: true,
                              onPressed: _scrollToForm,
                            ),
                            const SizedBox(width: 16),
                            PremiumButton(
                              text: 'View Samples',
                              isPrimary: false,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: MUOPTheme.cardBg,
                                    title: const Text('Samples Coming Soon', style: TextStyle(color: Colors.white)),
                                    content: const Text(
                                      'We are crafting amazing sample portfolios. Feel free to register to get yours started immediately!',
                                      style: TextStyle(color: MUOPTheme.secondaryText),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text('OK', style: TextStyle(color: MUOPTheme.primaryYellow)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==========================================
              // FEATURES SECTION
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = isMobile
                            ? constraints.maxWidth
                            : (isTablet
                                ? (constraints.maxWidth - 16) / 2
                                : (constraints.maxWidth - 48) / 4);

                        final cards = [
                          _buildFeatureCard('UX', 'Based on user experience', Icons.people_outline, cardWidth),
                          _buildFeatureCard('Fast Delivery', 'Under 96 Hours', Icons.flash_on, cardWidth),
                          _buildFeatureCard('Pro Design', 'Custom Crafted', Icons.palette_outlined, cardWidth),
                          _buildFeatureCard('Responsive', 'All Screen Sizes', Icons.devices, cardWidth),
                        ];

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: cards,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // ==========================================
              // REGISTRATION SECTION
              // ==========================================
              Container(
                key: _formSectionKey,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      children: [
                        // Heading
                        const Text(
                          'Get Your Portfolio Started',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete these quick steps to launch your professional online presence.',
                          style: TextStyle(fontSize: 14, color: MUOPTheme.secondaryText.withOpacity(0.8)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Form + Stepper Container
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stepper = StepperWidget(
                              currentStep: regState.currentStep,
                              onStepTap: (step) => regNotifier.setStep(step),
                              isMobile: isMobile,
                            );

                            final formCard = GlassCard(
                              animateHover: false,
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Render active step
                                  if (regState.currentStep == 0) const StepPersonalDetails(),
                                  if (regState.currentStep == 1) const StepCareerDetails(),
                                  if (regState.currentStep == 2) const StepResumeUpload(),
                                  if (regState.currentStep == 3) const StepPackageSelection(),
                                  if (regState.currentStep == 4) const StepConfirmation(),
                                  
                                  const SizedBox(height: 32),

                                  // Submission errors if any
                                  if (regState.submissionError != null) ...[
                                    Text(
                                      regState.submissionError!,
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Navigation Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Back Button
                                      if (regState.currentStep > 0)
                                        TextButton.icon(
                                          onPressed: regNotifier.prevStep,
                                          icon: const Icon(Icons.arrow_back, color: MUOPTheme.secondaryText),
                                          label: const Text('Back', style: TextStyle(color: MUOPTheme.secondaryText)),
                                        )
                                      else
                                        const SizedBox.shrink(),

                                      // Continue/Submit Button
                                      PremiumButton(
                                        text: regState.currentStep == 4
                                            ? 'Submit Request 🚀'
                                            : (regState.currentStep == 3 ? 'Continue to Confirmation →' : 'Continue →'),
                                        isLoading: regState.submissionStatus == SubmissionStatus.loading,
                                        onPressed: () {
                                          if (regState.currentStep == 4) {
                                            regNotifier.submitRegistration();
                                          } else {
                                            regNotifier.nextStep();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );

                            if (isMobile) {
                              return Column(
                                children: [
                                  stepper,
                                  const SizedBox(height: 24),
                                  formCard,
                                ],
                              );
                            } else {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 250,
                                    child: stepper,
                                  ),
                                  const SizedBox(width: 30),
                                  Expanded(
                                    child: formCard,
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // ==========================================
              // PACKAGES SECTION (STANDALONE)
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      children: [
                        const Text(
                          'Select Your Package',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tailored solutions for every stage of your career.',
                          style: TextStyle(fontSize: 14, color: MUOPTheme.secondaryText.withOpacity(0.8)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Package Cards Row
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double cardWidth = isMobile
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 24) / 2;

                            return Wrap(
                              spacing: 24,
                              runSpacing: 24,
                              children: [
                                _buildStandalonePackageCard(
                                  title: 'Student',
                                  subtitle: 'ENTRY LEVEL',
                                  price: '₹999',
                                  features: [
                                    'Single Page Portfolio',
                                    '2 Projects Showcase',
                                    'WhatsApp Support',
                                    'Standard Delivery',
                                  ],
                                  isPopular: false,
                                  width: cardWidth,
                                  onSelect: () => _selectPackageAndRegister('Student'),
                                ),
                                _buildStandalonePackageCard(
                                  title: 'Professional',
                                  subtitle: 'CAREER GROWTH',
                                  price: '₹1499',
                                  features: [
                                    'Multi-page Experience',
                                    'Unlimited Project Space',
                                    'Priority WhatsApp + Call Support',
                                    'Custom Branding & Logo',
                                  ],
                                  isPopular: true,
                                  width: cardWidth,
                                  onSelect: () => _selectPackageAndRegister('Professional'),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==========================================
              // CONTACT FORM SECTION
              // ==========================================
              Container(
                key: _contactSectionKey,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
                child: const ContactFormWidget(),
              ),
              const SizedBox(height: 40),

              // ==========================================
              // FOOTER
              // ==========================================
              const Divider(color: MUOPTheme.border, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final footerCompact = constraints.maxWidth < 600;
                        
                        final leftPart = Column(
                          crossAxisAlignment: footerCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('DEOPLEXIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.white)),
                                Container(width: 4, height: 4, margin: const EdgeInsets.only(left: 2, bottom: 4), color: MUOPTheme.primaryYellow),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '© 2026 MUOP Portfolio Services. We Provide Freelance based Service',
                              style: TextStyle(
                                fontSize: 10,
                                color: MUOPTheme.secondaryText.withOpacity(0.5),
                              ),
                            ),
                          ],
                        );

                        final rightPart = Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 10,
                                color: MUOPTheme.secondaryText.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontSize: 10,
                                color: MUOPTheme.secondaryText.withOpacity(0.5),
                              ),
                            ),
                          ],
                        );

                        if (footerCompact) {
                          return Column(
                            children: [
                              leftPart,
                              const SizedBox(height: 16),
                              rightPart,
                            ],
                          );
                        } else {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              leftPart,
                              rightPart,
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, double width) {
    return SizedBox(
      width: width,
      child: GlassCard(
        animateHover: true,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: MUOPTheme.primaryYellow, size: 22),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: MUOPTheme.secondaryText.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandalonePackageCard({
    required String title,
    required String subtitle,
    required String price,
    required List<String> features,
    required bool isPopular,
    required double width,
    required VoidCallback onSelect,
  }) {
    return SizedBox(
      width: width,
      child: GlassCard(
        isHighlighted: isPopular,
        animateHover: !isPopular,
        padding: EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
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
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'One-time payment',
                            style: TextStyle(fontSize: 11, color: MUOPTheme.secondaryText.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Divider(color: MUOPTheme.border, height: 1),
                  const SizedBox(height: 28),
                  ...features.map((feat) => Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: MUOPTheme.primaryYellow, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feat,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: isPopular ? 'Select Professional' : 'Select Student',
                      isPrimary: isPopular,
                      onPressed: onSelect,
                    ),
                  ),
                ],
              ),
            ),
            if (isPopular)
              Positioned(
                top: -12,
                right: 32,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: MUOPTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
