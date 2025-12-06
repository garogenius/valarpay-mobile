import 'package:flutter/material.dart';

class PlanSelectorModal extends StatelessWidget {
  final String selectedPlan;
  final Function(String, String) onPlanSelected;

  const PlanSelectorModal({
    super.key,
    required this.selectedPlan,
    required this.onPlanSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final plans = [
      {'name': 'Plan A', 'rate': '₦500'},
      {'name': 'Plan B', 'rate': '₦1000'}, 
      {'name': 'Plan C', 'rate': '₦1500'},
      {'name': 'Plan D', 'rate': '₦2000'},
      {'name': 'Plan E', 'rate': '₦2500'},
    ];

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
                  'Select Plan',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Plans list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final isSelected = plan['name'] == selectedPlan;

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
                    plan['name']!,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.star,
                          color: Color(0xFFF76301),
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    onPlanSelected(plan['name']!, plan['rate']!);
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
