import 'package:flutter/material.dart';
import '../../../../models/betting_models.dart';

class BettingProviderSelectorModal extends StatelessWidget {
  final List<BettingPlatformModel> platforms;
  final BettingPlatformModel? selectedPlatform;
  final Function(BettingPlatformModel) onPlatformSelected;

  const BettingProviderSelectorModal({
    super.key,
    required this.platforms,
    this.selectedPlatform,
    required this.onPlatformSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2725) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
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
                    'Select Provider',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Providers list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: platforms.length,
                padding: const EdgeInsets.only(bottom: 20),
                itemBuilder: (context, index) {
                  final platform = platforms[index];
                  final isSelected = platform.code == selectedPlatform?.code;

                  return ListTile(
                    leading: platform.logoUrl.isNotEmpty
                        ? Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                platform.logoUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.sports_soccer,
                                    color: Color(0xFFF76301),
                                    size: 24,
                                  );
                                },
                              ),
                            ),
                          )
                        : const Icon(Icons.sports_soccer, color: Color(0xFFF76301)),
                    title: Text(
                      platform.name,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
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
                      child: isSelected
                          ? const Icon(
                              Icons.circle,
                              color: Color(0xFFF76301),
                              size: 12,
                            )
                          : null,
                    ),
                    onTap: () {
                      onPlatformSelected(platform);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
