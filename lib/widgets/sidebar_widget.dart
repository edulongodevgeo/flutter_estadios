import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SidebarWidget extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onClose;

  const SidebarWidget({
    super.key,
    required this.animationController,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const double sidebarWidth = 280.0;

    final Animation<Offset> slideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    final Animation<double> backdropAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        );

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        if (animationController.value == 0) {
          return const SizedBox.shrink();
        }
        return Stack(
          children: [
            // Backdrop with fade
            GestureDetector(
              onTap: onClose,
              child: Opacity(
                opacity: backdropAnimation.value,
                child: Container(color: Colors.black.withValues(alpha: 0.3)),
              ),
            ),
            // Sliding Sidebar
            SlideTransition(
              position: slideAnimation,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: sidebarWidth,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(5, 0),
                        ),
                      ],
                      border: Border(
                        right: BorderSide(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 20),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildMenuItem(
                                    icon: Icons.home_rounded,
                                    title: 'Home',
                                    onTap: onClose,
                                    isActive: true,
                                  ),
                                  _buildMenuItem(
                                    icon: Icons.leaderboard_rounded,
                                    title: 'Rankings',
                                    onTap: onClose,
                                  ),
                                  _buildMenuItem(
                                    icon: Icons.business_rounded,
                                    title: 'SAFs',
                                    onTap: onClose,
                                  ),
                                  _buildMenuItem(
                                    icon: Icons.coffee_rounded,
                                    title: 'Cafézinho',
                                    onTap: onClose,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF69F0AE),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFF69F0AE).withValues(alpha: 0.3),
        highlightColor: const Color(0xFF69F0AE).withValues(alpha: 0.1),
        child: Container(
          decoration: isActive
              ? BoxDecoration(
                  border: Border(
                    left: BorderSide(color: const Color(0xFF69F0AE), width: 4),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF69F0AE).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.black87 : Colors.black54,
                size: 26,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? Colors.black87 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        'Versão 1.0.0',
        style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black38),
      ),
    );
  }
}
