import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopBar extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const TopBar({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCircleButton(Icons.menu, onTap: onMenuTap),
            const SizedBox(width: 16), // Spacing between button and text
            Expanded(
              child: Text(
                'Observatório de Estádios',
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: 12,
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

  Widget _buildCircleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }
}
