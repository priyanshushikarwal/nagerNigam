import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple onboarding walkthrough - local UI state only
class OnboardingWalkthrough extends StatefulWidget {
  final Widget child;

  const OnboardingWalkthrough({super.key, required this.child});

  @override
  State<OnboardingWalkthrough> createState() => _OnboardingWalkthroughState();
}

class _OnboardingWalkthroughState extends State<OnboardingWalkthrough> {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  bool _showOnboarding = false;
  int _currentStep = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Welcome to DISCOM Bill Manager',
      description: 'Manage your bills, payments, and tenders efficiently',
      icon: FluentIcons.home,
    ),
    OnboardingStep(
      title: 'Quick Add Bills',
      description: 'Press Ctrl+N to quickly add a new bill from anywhere',
      icon: FluentIcons.add,
    ),
    OnboardingStep(
      title: 'Search Everything',
      description: 'Press Ctrl+F to search bills, payments, and tenders',
      icon: FluentIcons.search,
    ),
    OnboardingStep(
      title: 'Client Firm Management',
      description: 'Organize bills by your client firms for better tracking',
      icon: FluentIcons.company_directory,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_keyOnboardingCompleted) ?? false;
    if (!completed && mounted) {
      setState(() => _showOnboarding = true);
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    // If onboarding is not showing, just return the child without Stack overhead
    if (!_showOnboarding) {
      return widget.child;
    }

    return Stack(
      children: [
        // Make the underlying content non-interactive while onboarding is active
        IgnorePointer(ignoring: _showOnboarding, child: widget.child),
        if (_showOnboarding)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _steps[_currentStep].icon,
                      size: 64,
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _steps[_currentStep].title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _steps[_currentStep].description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[100]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_steps.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                index == _currentStep
                                    ? const Color(0xFF2563EB)
                                    : Colors.grey[60],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          Button(
                            onPressed: () {
                              setState(() => _currentStep--);
                            },
                            child: const Text('Previous'),
                          )
                        else
                          const SizedBox(),
                        FilledButton(
                          onPressed: () {
                            if (_currentStep < _steps.length - 1) {
                              setState(() => _currentStep++);
                            } else {
                              _completeOnboarding();
                            }
                          },
                          child: Text(
                            _currentStep < _steps.length - 1
                                ? 'Next'
                                : 'Get Started',
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
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
