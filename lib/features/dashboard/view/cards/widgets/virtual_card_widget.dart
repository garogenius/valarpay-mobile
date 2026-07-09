import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:valarpay/features/models/vcard_models.dart';

class VirtualCardWidget extends StatelessWidget {
  final VirtualCardModel? card;
  final bool showDetails;
  final String designTheme;

  const VirtualCardWidget({
    super.key,
    this.card,
    this.showDetails = false,
    this.designTheme = 'Midnight Executive',
  });

  @override
  Widget build(BuildContext context) {
    String theme = card?.color ?? designTheme;
    if (theme.isEmpty) theme = 'Midnight Executive';

    return AspectRatio(
      aspectRatio: 1.586, // Exact ATM Card Aspect Ratio
      child: _buildCardTheme(context, theme),
    );
  }

  Widget _buildCardTheme(BuildContext context, String theme) {
    switch (theme) {
      case '#F76301':
      case 'Quantum Grid':
        return _buildQuantumGrid(context);
      case '#273644':
      case 'Titanium Edge':
        return _buildTitaniumEdge(context);
      case '#010816':
      case 'Ethereal Flow':
        return _buildEtherealFlow(context);
      case '#A33F00':
      case 'Solar Velocity':
        return _buildSolarVelocity(context);
      case '#1C2B39':
      case 'Prism Digital':
        return _buildPrismDigital(context);
      case '#0D1D2A':
      case 'Midnight Executive':
      default:
        return _buildMidnightExecutive(context);
    }
  }

  // Common card contents layout structure
  Widget _buildCardBase({
    required Decoration decoration,
    required CustomPainter backgroundPainter,
    required Color textColor,
    List<Widget> backgroundDecoration = const [],
  }) {
    return Container(
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background decorations (e.g. blurs or color patches)
          ...backgroundDecoration,
          
          // Background pattern custom painter
          Positioned.fill(
            child: CustomPaint(
              painter: backgroundPainter,
            ),
          ),
          
          // Foreground components
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValarPayLogo(),
                _buildCardDetails(textColor),
                _buildCardBottomRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Midnight Executive (Deep Premium Navy/Black)
  Widget _buildMidnightExecutive(BuildContext context) {
    return _buildCardBase(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [Color(0xFF0F1E36), Color(0xFF070F1A)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      backgroundPainter: MidnightExecutivePainter(color: Colors.white.withOpacity(0.12)),
      textColor: Colors.white,
    );
  }

  // 2. Quantum Grid (Sleek digital/tech dot matrix grid)
  Widget _buildQuantumGrid(BuildContext context) {
    return _buildCardBase(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF13C296), Color(0xFF0CA47E)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF13C296).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      backgroundPainter: QuantumGridPainter(color: Colors.white.withOpacity(0.18)),
      textColor: Colors.white,
    );
  }

  // 3. Titanium Edge (Luxury Matte Charcoal)
  Widget _buildTitaniumEdge(BuildContext context) {
    return _buildCardBase(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E3238), Color(0xFF15181C)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      backgroundPainter: TitaniumEdgePainter(color: Colors.white.withOpacity(0.12)),
      textColor: Colors.white,
    );
  }

  // 4. Ethereal Flow (Rich Violet/Glow)
  Widget _buildEtherealFlow(BuildContext context) {
    return _buildCardBase(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C1A42), Color(0xFF0E0716)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C1A42).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      backgroundPainter: EtherealFlowPainter(color: Colors.white.withOpacity(0.12)),
      textColor: Colors.white,
    );
  }

  // 5. Solar Velocity (Sunset Orange)
  Widget _buildSolarVelocity(BuildContext context) {
    return _buildCardBase(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF76301), Color(0xFFC74F00)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF76301).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      backgroundPainter: SolarVelocityPainter(color: Colors.white.withOpacity(0.18)),
      textColor: Colors.white,
    );
  }

  // 6. Prism Digital (Glassmorphic Frosted Glass)
  Widget _buildPrismDigital(BuildContext context) {
    return _buildCardBase(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E2E3D).withOpacity(0.4),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      backgroundPainter: PrismDigitalPainter(color: Colors.white.withOpacity(0.15)),
      textColor: Colors.white,
      backgroundDecoration: [
        // Colorful blurred glow elements visible behind the glass card
        Positioned(
          top: -30,
          left: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF76301).withOpacity(0.15),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          right: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF13C296).withOpacity(0.1),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }

  // ValarPay Logo top-left
  Widget _buildValarPayLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            'assets/images/logo.png',
            width: 18,
            height: 18,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.2),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'ValarPay',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  // Show card details when showDetails is true and card is not null
  Widget _buildCardDetails(Color textColor) {
    if (!showDetails || card == null) {
      return const Spacer(); // Keep middle section empty/simple when details are hidden or it is a sample card (card is null)
    }

    final rawNumber = card?.cardNumber ?? '5399238492834821';
    final formattedNum = _formatCardNumber(rawNumber);
    final expiry = card != null 
        ? '${card!.expiryMonth}/${card!.expiryYear.length == 4 ? card!.expiryYear.substring(2) : card!.expiryYear}' 
        : '12/28';
    final cvvVal = card?.cvv ?? '123';

    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formattedNum,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card?.cardholderName.toUpperCase() ?? 'ALEXANDER VAUGHN',
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'EXP: $expiry',
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'CVV: $cvvVal',
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card bottom info
  Widget _buildCardBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Virtual Card',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        _buildBrandLogo(),
      ],
    );
  }

  // Card brand logo helper
  Widget _buildBrandLogo() {
    final provider = card?.providerType?.toUpperCase() ?? '';
    final brand = card?.metadata?['brand']?.toString().toUpperCase() ?? '';

    bool isVisa = provider.contains('VISA') || brand.contains('VISA');
    bool isMastercard = provider.contains('MASTERCARD') || brand.contains('MASTERCARD');

    if (isVisa) {
      return const Text(
        'VISA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.5,
        ),
      );
    } else if (isMastercard) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.9),
            ),
          ),
          Transform.translate(
            offset: const Offset(-6, 0),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.9),
              ),
            ),
          ),
        ],
      );
    } else {
      // Verve Logo (exactly as in the OPay sample!)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE31B23), // Verve Red
            ),
            alignment: Alignment.center,
            child: const Text(
              'V',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'verve',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
        ],
      );
    }
  }

  String _formatCardNumber(String number) {
    String cleanNumber = number.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < cleanNumber.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += cleanNumber[i];
    }
    return formatted;
  }
}

// 1. Midnight Executive Custom Painter (Sophisticated concentric waves)
class MidnightExecutivePainter extends CustomPainter {
  final Color color;
  MidnightExecutivePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final center = Offset(0, size.height);
    const steps = 12;
    final baseRadius = size.width * 0.1;
    final maxRadius = size.width * 1.2;

    for (int i = 0; i < steps; i++) {
      final radius = baseRadius + (maxRadius - baseRadius) * (i / steps);
      paint.color = color.withOpacity((0.8 - (i / steps) * 0.7) * color.opacity);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Quantum Grid Custom Painter (Futuristic digital dot matrix)
class QuantumGridPainter extends CustomPainter {
  final Color color;
  QuantumGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double spacing = 14.0;
    final int cols = (size.width / spacing).ceil();
    final int rows = (size.height / spacing).ceil();

    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        final double x = c * spacing + spacing / 2;
        final double y = r * spacing + spacing / 2;
        
        final dx = size.width - x;
        final dy = y;
        final dist = (dx * dx + dy * dy);
        final maxDist = (size.width * size.width + size.height * size.height);
        final factor = 1.0 - (dist / maxDist).clamp(0.0, 1.0);
        
        if (factor > 0.1) {
          paint.color = color.withOpacity(factor * 0.35 * color.opacity);
          canvas.drawCircle(Offset(x, y), 1.2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. Titanium Edge Custom Painter (Metallic brushed diagonal edge slices)
class TitaniumEdgePainter extends CustomPainter {
  final Color color;
  TitaniumEdgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const steps = 8;
    const double spacing = 24.0;

    for (int i = 0; i < steps; i++) {
      final path = Path();
      final double offset = i * spacing;
      path.moveTo(offset, 0);
      path.lineTo(offset + size.height, size.height);
      
      paint.color = color.withOpacity((1.0 - (i / steps) * 0.8) * 0.25 * color.opacity);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. Ethereal Flow Custom Painter (Organic flowing bezier curves/waves)
class EtherealFlowPainter extends CustomPainter {
  final Color color;
  EtherealFlowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final double yOffset = size.height * (0.3 + i * 0.15);
      final double controlY1 = size.height * (0.1 + i * 0.2);
      final double controlY2 = size.height * (0.9 - i * 0.1);
      
      path.moveTo(0, yOffset);
      path.cubicTo(
        size.width * 0.35, controlY1,
        size.width * 0.65, controlY2,
        size.width, yOffset - 20,
      );

      paint.color = color.withOpacity((1.0 - i * 0.3) * 0.25 * color.opacity);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 5. Solar Velocity Custom Painter (Sweeping solar orbit paths)
class SolarVelocityPainter extends CustomPainter {
  final Color color;
  SolarVelocityPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width * 0.85, size.height * 0.15);
    const steps = 10;
    final baseRadius = size.height * 0.2;
    final maxRadius = size.width * 1.1;

    for (int i = 0; i < steps; i++) {
      final radius = baseRadius + (maxRadius - baseRadius) * (i / steps);
      paint.color = color.withOpacity((1.0 - (i / steps) * 0.85) * 0.3 * color.opacity);
      
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, 0.5, 4.0, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 6. Prism Digital Custom Painter (Multi-faceted geometric glass polygons)
class PrismDigitalPainter extends CustomPainter {
  final Color color;
  PrismDigitalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.8, 0)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..close();

    final path2 = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(0, size.height)
      ..close();

    final path3 = Path()
      ..moveTo(size.width, size.height * 0.2)
      ..lineTo(size.width * 0.6, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    paint.color = color.withOpacity(0.08 * color.opacity);
    canvas.drawPath(path1, paint);
    
    paint.color = color.withOpacity(0.05 * color.opacity);
    canvas.drawPath(path2, paint);
    
    paint.color = color.withOpacity(0.06 * color.opacity);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




































































