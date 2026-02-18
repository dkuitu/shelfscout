import 'package:flutter/material.dart';
import '../../../config/theme.dart';

enum PinStatus { unscouted, scouted, crowned, contested }

class StorePin extends StatelessWidget {
  final PinStatus status;
  final String? chain;
  final VoidCallback? onTap;

  const StorePin({
    super.key,
    this.status = PinStatus.unscouted,
    this.chain,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 48,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Pin shadow
            Positioned(
              bottom: 0,
              child: Container(
                width: 12,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            // Pin body
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _pinGradient,
                    border: Border.all(
                      color: Colors.white.withAlpha(200),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _pinColor.withAlpha(100),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _pinIcon,
                  ),
                ),
                // Pin pointer
                CustomPaint(
                  size: const Size(10, 8),
                  painter: _PinPointerPainter(_pinColor),
                ),
              ],
            ),
            // Crown badge for crowned stores
            if (status == PinStatus.crowned)
              const Positioned(
                top: -2,
                right: 0,
                child: Text(
                  '\u{1F451}',
                  style: TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color get _pinColor {
    switch (status) {
      case PinStatus.crowned:
        return AppTheme.goldColor;
      case PinStatus.scouted:
        return AppTheme.conquestGreen;
      case PinStatus.contested:
        return AppTheme.dangerRed;
      case PinStatus.unscouted:
        return Colors.grey;
    }
  }

  LinearGradient get _pinGradient {
    switch (status) {
      case PinStatus.crowned:
        return AppTheme.goldGradient;
      case PinStatus.scouted:
        return AppTheme.greenGradient;
      case PinStatus.contested:
        return AppTheme.dangerGradient;
      case PinStatus.unscouted:
        return const LinearGradient(
          colors: [Color(0xFF78909C), Color(0xFF546E7A)],
        );
    }
  }

  Widget get _pinIcon {
    switch (status) {
      case PinStatus.crowned:
        return const Icon(Icons.emoji_events, color: Colors.black87, size: 18);
      case PinStatus.scouted:
        return const Icon(Icons.check, color: Colors.black87, size: 18);
      case PinStatus.contested:
        return const Icon(Icons.bolt, color: Colors.white, size: 18);
      case PinStatus.unscouted:
        return const Icon(Icons.store, color: Colors.white, size: 18);
    }
  }
}

class _PinPointerPainter extends CustomPainter {
  final Color color;
  _PinPointerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
