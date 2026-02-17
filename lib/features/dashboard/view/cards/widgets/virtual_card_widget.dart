import 'package:flutter/material.dart';
import 'package:valarpay/features/models/vcard_models.dart';
import 'package:valarpay/core/themes/color_utils.dart';

class VirtualCardWidget extends StatelessWidget {
  final VirtualCardModel? card;
  final bool showDetails;

  const VirtualCardWidget({
    super.key,
    this.card,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF76301),
            Color(0xFFFF8C38),
            Color(0xFFFFAD71),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // World Map Pattern (Simplified with Icons for now)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.public, size: 300, color: Colors.white),
              ),
            ),
            
            // Logos Row
            Positioned(
              top: 24,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/images/logo.png', width: 20, height: 20, errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_wallet, size: 16, color: Color(0xFFF76301))),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'VALARPAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'BeyondBank',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Chip
            Positioned(
              top: 80,
              left: 24,
              child: Container(
                width: 45,
                height: 35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Stack(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Positioned(
                        top: 8.0 * i + 8,
                        left: 0,
                        right: 0,
                        child: Container(height: 1, color: Colors.black12),
                      ),
                    for (int i = 0; i < 3; i++)
                      Positioned(
                        left: 14.0 * i + 14,
                        top: 0,
                        bottom: 0,
                        child: Container(width: 1, color: Colors.black12),
                      ),
                  ],
                ),
              ),
            ),
            
            // Contactless
            Positioned(
              top: 85,
              right: 24,
              child: Transform.rotate(
                angle: 1.57,
                child: const Icon(Icons.wifi, color: Colors.white70, size: 24),
              ),
            ),
            
            // Card Number
            Positioned(
              bottom: 80,
              left: 24,
              child: Text(
                card != null 
                  ? (showDetails ? _formatCardNumber(card!.cardNumber) : '****   ****   ****   ${card!.last4Digits}')
                  : '****   ****   ****   ****',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  fontFamily: 'Courier',
                ),
              ),
            ),
            
            // Expiry
            Positioned(
              bottom: 50,
              left: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VALID THRU',
                    style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    card != null ? '${card!.expiryMonth}/${card!.expiryYear.substring(card!.expiryYear.length - 2)}' : '**/ **',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // Name
            Positioned(
              bottom: 24,
              left: 24,
              child: Text(
                card?.cardholderName.toUpperCase() ?? 'HOLDER NAME',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            
            // Verve Logo
            Positioned(
              bottom: 20,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE31E24),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Verve',
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
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

  String _formatCardNumber(String number) {
    String cleanNumber = number.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < cleanNumber.length; i++) {
        if (i > 0 && i % 4 == 0) formatted += '   ';
        formatted += cleanNumber[i];
    }
    return formatted;
  }
}
