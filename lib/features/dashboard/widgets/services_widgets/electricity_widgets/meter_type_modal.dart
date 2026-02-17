import 'package:flutter/material.dart';
import 'package:valarpay/features/models/electricity.dart';

class MeterTypeModal extends StatelessWidget {
  final List<ElectricityBillInfo> meterTypes;
  final ElectricityBillInfo? selectedType;
  final Function(ElectricityBillInfo) onTypeSelected;

  const MeterTypeModal({
    super.key,
    required this.meterTypes,
    required this.selectedType,
    required this.onTypeSelected,
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
                  'Meter Type',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Meter type list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: meterTypes.length,
              itemBuilder: (context, index) {
                final type = meterTypes[index];
                final isSelected = type.itemCode == selectedType?.itemCode && type.itemCode.isNotEmpty;

                return ListTile(
                  leading: Container(
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
                    child: isSelected
                        ? const Icon(
                            Icons.circle,
                            color: Color(0xFFF76301),
                            size: 12,
                          )
                        : null,
                  ),
                  title: Text(
                    type.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '₦${type.fee.toStringAsFixed(0)} fee',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    onTypeSelected(type);
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
