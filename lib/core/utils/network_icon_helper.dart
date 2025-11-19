import 'package:flutter/material.dart';

class NetworkIconHelper {
  /// Get network provider icon based on network name
  static IconData getNetworkIcon(String? network) {
    if (network == null) return Icons.phone;

    final networkLower = network.toLowerCase();

    if (networkLower.contains('mtn') || networkLower.contains('9mobile')) {
      return Icons.phone; // MTN/9mobile
    } else if (networkLower.contains('airtel')) {
      return Icons.phone_android; // Airtel
    } else if (networkLower.contains('glo') ||
        networkLower.contains('globacom')) {
      return Icons.language; // Globacom
    } else if (networkLower.contains('idea')) {
      return Icons.phonelink; // Idea (rarely used in Nigeria)
    } else if (networkLower.contains('vodafone')) {
      return Icons.phone; // Vodafone
    }

    return Icons.phone; // Default
  }

  /// Get network provider color based on network name
  static Color getNetworkColor(String? network) {
    if (network == null) return const Color(0xFFF76301);

    final networkLower = network.toLowerCase();

    if (networkLower.contains('mtn')) {
      return const Color(0xFFFFD700); // MTN Yellow
    } else if (networkLower.contains('9mobile')) {
      return const Color(0xFF00A651); // 9mobile Green
    } else if (networkLower.contains('airtel')) {
      return const Color(0xFFEB0029); // Airtel Red
    } else if (networkLower.contains('glo') ||
        networkLower.contains('globacom')) {
      return const Color(0xFF00A86B); // Globacom Green
    } else if (networkLower.contains('idea')) {
      return const Color(0xFF8B0000); // Idea Maroon
    } else if (networkLower.contains('vodafone')) {
      return const Color(0xFFDD0000); // Vodafone Red
    }

    return const Color(0xFFF76301); // Default
  }

  /// Get network provider name in title case
  static String getNetworkDisplayName(String? network) {
    if (network == null) return 'Unknown';

    final networkLower = network.toLowerCase();

    if (networkLower.contains('mtn')) {
      return 'MTN';
    } else if (networkLower.contains('9mobile')) {
      return '9mobile';
    } else if (networkLower.contains('airtel')) {
      return 'Airtel';
    } else if (networkLower.contains('glo') ||
        networkLower.contains('globacom')) {
      return 'Globacom';
    } else if (networkLower.contains('idea')) {
      return 'Idea';
    } else if (networkLower.contains('vodafone')) {
      return 'Vodafone';
    }

    return network;
  }
}
