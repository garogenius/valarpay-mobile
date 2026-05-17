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

  // 1. Midnight Executive
  Widget _buildMidnightExecutive(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [Color(0xFF0D1D2A), Color(0xFF041521)],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 6)),
        ],
        border: Border.all(color: const Color(0xFFFFB596).withOpacity(0.15), width: 1),
      ),
      child: Stack(
        children: [
          _buildNoiseOverlay(),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card?.label ?? 'My Valarpay Virtual Card',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'EXECUTIVE EDITION',
                            style: TextStyle(color: const Color(0xFFFFB596).withOpacity(0.8), fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Valarpay',
                      style: TextStyle(
                        color: Color(0xFFF76301),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFE9C349), Color(0xFFCCA72F)]),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: CustomPaint(painter: ChipPainter()),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.wifi, color: Colors.white24, size: 20),
                  ],
                ),
                _buildCardBottomInfo(textColor: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Quantum Grid
  Widget _buildQuantumGrid(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF76301),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: GridPainter()),
          ),
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Valarpay', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                          Text('QUANTUM EDITION', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFE9C349), Color(0xFFCCA72F)]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: CustomPaint(painter: ChipPainter()),
                    ),
                  ],
                ),
                _buildCardBottomInfo(textColor: Colors.white, showBrand: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Titanium Edge
  Widget _buildTitaniumEdge(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D1D2A),
                    ),
                    child: CustomPaint(painter: CarbonFiberPainter()),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF273644), Color(0xFF0D1D2A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: CustomPaint(painter: DiagonalSplitPainter()),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TITANIUM EDGE', style: TextStyle(color: const Color(0xFFF76301).withOpacity(0.8), fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                            const Text('Valarpay USD', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFF76301), Color(0xFFA33F00)]),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [BoxShadow(color: const Color(0xFFF76301).withOpacity(0.3), blurRadius: 4)],
                        ),
                        child: const Icon(Icons.bolt, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFE9C349), Color(0xFFCCA72F)]),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: CustomPaint(painter: ChipPainter()),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.contactless_outlined, color: Colors.white24, size: 22),
                    ],
                  ),
                  _buildCardBottomInfo(textColor: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Ethereal Flow
  Widget _buildEtherealFlow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF010816),
        border: Border.all(color: const Color(0xFFA98A7D).withOpacity(0.15)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF76301).withOpacity(0.12),
                ),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: const SizedBox()),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE9C349).withOpacity(0.08),
                ),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: const SizedBox()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('VALARPAY', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                            const Text('ETHEREAL FLOW', style: TextStyle(color: Color(0xFFFFB596), fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Text('PLATINUM', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFD9E2FF), Color(0xFFA9B8E0)]),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: CustomPaint(painter: ChipPainter(color: Colors.black12)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.contactless, color: Colors.white38, size: 22),
                    ],
                  ),
                  _buildCardBottomInfo(textColor: Colors.white, showBrand: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Solar Velocity
  Widget _buildSolarVelocity(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFF76301), Color(0xFFA33F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white24),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: MicroGridPainter()),
            ),
            Positioned(
              top: -40,
              left: -15,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: const SizedBox()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Valarpay', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                            Text('SOLAR VELOCITY', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 8, letterSpacing: 1.5)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Text('USD PLATINUM', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.white30, Colors.white10]),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: CustomPaint(painter: ChipPainter(color: Colors.white24)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.wifi, color: Colors.white38, size: 22),
                    ],
                  ),
                  _buildCardBottomInfo(textColor: Colors.white, showBrand: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Prism Digital
  Widget _buildPrismDigital(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1C2B39).withOpacity(0.4),
        border: Border.all(color: const Color(0xFFA98A7D).withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Valarpay Virtual Card', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('USD', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('VISA', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                  ],
                ),
                _buildCardBottomInfo(textColor: Colors.white.withOpacity(0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoiseOverlay() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: Image.network(
          'https://www.transparenttextures.com/patterns/cubes.png',
          repeat: ImageRepeat.repeat,
          errorBuilder: (_, __, ___) => const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildCardBottomInfo({required Color textColor, bool showBrand = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            card != null 
                ? (showDetails ? _formatCardNumber(card!.cardNumber) : '**** **** **** ${card!.last4Digits}')
                : '**** **** **** 4821',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('CARD HOLDER', style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 8, letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Text(
                    card?.cardholderName.toUpperCase() ?? 'ALEXANDER VAUGHN',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('EXPIRES', style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 8, letterSpacing: 1.5)),
                    const SizedBox(height: 2),
                    Text(
                      card != null ? '${card!.expiryMonth}/${card!.expiryYear.length == 4 ? card!.expiryYear.substring(2) : card!.expiryYear}' : '12/28',
                      style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (showBrand) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 32,
                    height: 20,
                    child: Stack(
                      children: [
                        Positioned(right: 12, child: Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.8)))),
                        Positioned(right: 0, child: Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.yellow.withOpacity(0.8)))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
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

class ChipPainter extends CustomPainter {
  final Color color;
  ChipPainter({this.color = Colors.black12});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(Offset(0, size.height * 0.33), Offset(size.width * 0.3, size.height * 0.33), paint);
    canvas.drawLine(Offset(0, size.height * 0.66), Offset(size.width * 0.3, size.height * 0.66), paint);
    
    canvas.drawLine(Offset(size.width, size.height * 0.33), Offset(size.width * 0.7, size.height * 0.33), paint);
    canvas.drawLine(Offset(size.width, size.height * 0.66), Offset(size.width * 0.7, size.height * 0.66), paint);
    
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.2, size.height * 0.2, size.width * 0.6, size.height * 0.6), const Radius.circular(2)), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 15) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 15) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CarbonFiberPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF11212E);
    for (double x = 0; x < size.width; x += 6) {
      for (double y = 0; y < size.height; y += 6) {
        if ((x / 6 + y / 6) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, 3, 3), paint);
        } else {
          canvas.drawRect(Rect.fromLTWH(x + 3, y + 3, 3, 3), paint);
        }
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiagonalSplitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, Color(0x99F76301), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(size.width / 2 - 2, 0, 4, size.height))
      ..strokeWidth = 1.5;
    
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(0.26); 
    canvas.drawLine(Offset(0, -size.height), Offset(0, size.height), paint);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MicroGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 6) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 6) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
