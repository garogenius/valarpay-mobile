import 'package:flutter/material.dart';
import 'package:valarpay/features/models/electricity.dart';

class DiscoSelectorModal extends StatelessWidget {
  final List<ElectricityPlan> discos;
  final ElectricityPlan? selectedDisco;
  final Function(ElectricityPlan) onDiscoSelected;

  const DiscoSelectorModal({
    super.key,
    required this.discos,
    required this.selectedDisco,
    required this.onDiscoSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2725) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Disco',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Disco list - Scrollable
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: discos.length,
              itemBuilder: (context, index) {
                final disco = discos[index];
                final isSelected = disco.billerCode == selectedDisco?.billerCode;

                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: disco.billerIcon != null && disco.billerIcon!.isNotEmpty
                          ? Image.network(
                              disco.billerIcon!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.flash_on),
                            )
                          : const Icon(Icons.flash_on),
                    ),
                  ),
                  title: Text(
                    disco.planName,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    disco.shortName,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? const Color(0xFFF76301) : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                                Icons.circle,
                                color: Color(0xFFF76301),
                                size: 12,
                              )
                            : null,
                  ),
                  onTap: () {
                    onDiscoSelected(disco);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
