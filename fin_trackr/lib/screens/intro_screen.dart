import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';

class IntroScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  const IntroScreen({
    super.key,
    required this.onThemeToggle,   
    required this.currentThemeMode,
  });

  void _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenManual', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => SplashScreen(
              onThemeToggle: onThemeToggle,
              currentThemeMode: currentThemeMode,
            ),
      ),
    );
  }

  PageViewModel _buildPage({
    required String imagePath,
    required String title,
    required String body,
    required BuildContext context,
  }) {
    final double imageHeight = MediaQuery.of(context).size.height * 0.35;

    return PageViewModel(
      titleWidget: Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 4),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Color(0xFF4F46E5),
          ),
        ),
      ),
      bodyWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 17,
              height: 1.5,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      image: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        height: imageHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
      decoration: const PageDecoration(
        pageColor: Colors.transparent,
        contentMargin: EdgeInsets.symmetric(vertical: 16),
        imageFlex: 4,
        bodyFlex: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0E7FF), Color(0xFFD1D5DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: IntroductionScreen(
          globalBackgroundColor: Colors.transparent,
          pages: [
            _buildPage(
              imagePath: 'lib/assets/icon/img1.jpg',
              title: 'Track Your Spending',
              body:
                  'All your income and expenses in one place to stay financially organized.',
              context: context,
            ),
            _buildPage(
              imagePath: 'lib/assets/icon/img2.jpg',
              title: 'Add a Transaction',
              body:
                  'Enter title, amount, date, and category. One tap and it’s saved!',
              context: context,
            ),
            _buildPage(
              imagePath: 'lib/assets/icon/img3.jpg',
              title: 'Filter Transactions',
              body:
                  'Sort and filter by date or category to gain deep insights.',
              context: context,
            ),
            _buildPage(
              imagePath: 'lib/assets/icon/img4.jpg',
              title: 'Backup History',
              body:
                  'Back up and restore your data whenever needed with a single tap.',
              context: context,
            ),
            _buildPage(
              imagePath: 'lib/assets/icon/img5.jpg',
              title: 'Export Your Data',
              body:
                  'Generate PDF or Excel reports instantly and professionally.',
              context: context,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),
          showSkipButton: true,
          skip: const Text(
            'Skip',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
              fontSize: 14,
            ),
          ),
          next: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Color(0xFF4F46E5),
          ),
          done: const Text(
            "Get Started",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F46E5),
              fontSize: 16,
            ),
          ),
          dotsDecorator: const DotsDecorator(
            activeColor: Color(0xFF4F46E5),
            size: Size(10.0, 10.0),
            color: Colors.grey,
            activeSize: Size(26.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
          curve: Curves.easeInOut,
          animationDuration: 500,
          scrollPhysics: const BouncingScrollPhysics(),
        ),
      ),
    );
  }
}
