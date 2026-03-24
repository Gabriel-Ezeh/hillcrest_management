import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/app/core/providers/user_local_storage_provider.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/ui/widgets/app_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../utils/constants/values.dart';

// Data structure
final List<Map<String, String>> _onboardingData = [
  {
    "imagePath": ImagePath.firstOnboardingImg,
    "title": StringConst.firstOnboardingTitle,
    "description": StringConst.firstOnboardingDescription,
  },
  {
    "imagePath": ImagePath.secondOnboardingImg,
    "title": StringConst.secondOnboardingTitle,
    "description": StringConst.secondOnboardingDescription,
  },
  {
    "imagePath": ImagePath.thirdOnboardingImg,
    "title": StringConst.thirdOnboardingTitle,
    "description": StringConst.thirdOnboardingDescription,
  },
];

@RoutePage()
class WelcomeOnboardingScreen extends ConsumerStatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  ConsumerState<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState
    extends ConsumerState<WelcomeOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_updateCurrentPage);
  }

  void _updateCurrentPage() {
    if (_pageController.page != null) {
      final newPage = _pageController.page!.round();
      if (_currentPage != newPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_updateCurrentPage);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    // Use the new centralized service to mark onboarding as seen.
    await ref.read(userLocalStorageProvider).markOnboardingAsSeen();
    // Navigate to the Sign In page, replacing the current route stack.
    context.router.replace(const SignInRoute());
  }

  Widget _buildContent() {
    return Column(
      key: ValueKey<int>(_currentPage),
      children: [
        Text(
          _onboardingData[_currentPage]['title']!,
          style: AppTextStyles.cabinBold24DarkBlue,
          textAlign: TextAlign.center,
        ),
        const SpaceH16(),
        Text(
          _onboardingData[_currentPage]['description']!,
          style: AppTextStyles.cabinRegular14MutedGray,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastSlide = _currentPage == _onboardingData.length - 1;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.55,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _onboardingData[index]['imagePath']!,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _buildContent(),
                    ),
                    const SpaceH24(),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _onboardingData.length,
                      effect: const WormEffect(
                        dotHeight: 8.0,
                        dotWidth: 8.0,
                        activeDotColor: AppColors.primaryColor,
                        dotColor: AppColors.lightGray,
                      ),
                    ),
                    const SpaceH24(),
                    AppButton(
                      text: isLastSlide ? 'Get Started' : 'Next',
                      onPressed: () {
                        if (isLastSlide) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                    ),
                    const SpaceH2(),
                    TextButton(
                      onPressed: _completeOnboarding, // Also complete if they press login
                      child: const Text('Log In', style: AppTextStyles.cabinBold14Primary),
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
