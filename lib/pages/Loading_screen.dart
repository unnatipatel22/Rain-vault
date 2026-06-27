import 'package:flutter/material.dart';
import 'dart:ui';
import 'login_page.dart'; // Import your actual login page

class SplashScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkTheme;

  const SplashScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkTheme,
  });
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Color?> _gradientStartAnimation;
  late Animation<Color?> _gradientEndAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.6, end: 1.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_animationController);

    _textFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _gradientStartAnimation = ColorTween(
      begin: Colors.cyan.shade800,
      end: Colors.blue.shade900,
    ).animate(_animationController);

    _gradientEndAnimation = ColorTween(
      begin: Colors.cyanAccent.shade200,
      end: Colors.blueAccent.shade400,
    ).animate(_animationController);

    _animationController.forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) =>  LoginPage()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Shader _createTextGradient(Rect bounds, Color c1, Color c2) {
    return LinearGradient(
      colors: [c1, c2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds);
  }

  @override
  Widget build(BuildContext context) {
    // yaha theme ka primary aur secondary color le liya
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _gradientStartAnimation.value ?? primary,
                  _gradientEndAnimation.value ?? secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glowing Logo
                  ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: secondary.withOpacity(0.7),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(30),
                      child: Icon(
                        Icons.water_drop_rounded,
                        size: 90,
                        color: primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Gradient Text
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          _createTextGradient(bounds, secondary, primary),
                      child: Text(
                        "RainVault",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // fallback
                          letterSpacing: 2,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(2, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Stylish Loader
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(secondary),
                      strokeWidth: 4,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
