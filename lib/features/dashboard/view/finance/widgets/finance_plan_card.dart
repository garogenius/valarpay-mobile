import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum FinancePlanType { target, easylife, fixed }

class FinancePlanCard extends StatelessWidget {
  final String title;
  final double amount;
  final double? targetAmount;
  final String status;
  final DateTime date; // Start date or creation date
  final int? durationDays;
  final VoidCallback onTap;
  final FinancePlanType type;

  const FinancePlanCard({
    super.key,
    required this.title,
    required this.amount,
    this.targetAmount,
    required this.status,
    required this.date,
    this.durationDays,
    required this.onTap,
    this.type = FinancePlanType.target,
  });

  // Backward compatibility factory/constructor if needed, but we'll just update usages
  factory FinancePlanCard.fromFixedDeposit({
    required String title,
    required double amount,
    required double targetAmount,
    required String status,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return FinancePlanCard(
      title: title,
      amount: amount,
      targetAmount: targetAmount,
      status: status,
      date: date,
      onTap: onTap,
      type: FinancePlanType.fixed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (targetAmount != null && targetAmount! > 0) ? (amount / targetAmount!).clamp(0.0, 1.0) : 0.0;

    // Determine colors and gradients based on type
    List<Color> gradientColors;
    IconData typeIcon;

    switch (type) {
      case FinancePlanType.easylife:
        gradientColors = [const Color(0xFF1A567E), const Color(0xFF133E5B)];
        typeIcon = Icons.auto_awesome_outlined;
        break;
      case FinancePlanType.fixed:
        gradientColors = [const Color(0xFF4338CA), const Color(0xFF3730A3)];
        typeIcon = Icons.lock_outline;
        break;
      case FinancePlanType.target:
      default:
        gradientColors = [const Color(0xFF0D47A1), const Color(0xFF1565C0)];
        typeIcon = Icons.track_changes;
        break;
    }

    // Calculate days left
    int daysLeft = 0;
    if (durationDays != null) {
      final expiryDate = date.add(Duration(days: durationDays!));
      daysLeft = expiryDate.difference(DateTime.now()).inDays;
    } else {
      // Fallback: estimate if it's a fixed deposit or target (usually 30-365 days)
      // For demo/UI consistency, we'll use a calculated value if not provided
      daysLeft = 90 - DateTime.now().difference(date).inDays;
    }
    if (daysLeft < 0) daysLeft = 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern/Illustration
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Hero(
                  tag: 'card_icon_$title',
                  child: Icon(typeIcon, size: 140, color: Colors.white),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Amount Saved', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '₦${NumberFormat('#,###.##').format(amount)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                      if (targetAmount != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Goal Amount', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              '₦${NumberFormat('#,###.##').format(targetAmount!)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Bar with dynamic width
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            height: 6,
                            width: constraints.maxWidth * progress,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF76301), // Brighter orange accent
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF76301).withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}% achieved',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$daysLeft Days left',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

