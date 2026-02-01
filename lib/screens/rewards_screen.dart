import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/rewards_controller.dart';
import '../controllers/language_controller.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rewardsController = context.watch<RewardsController>();
    final lang = context.watch<LanguageController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.isEnglish ? 'SINO Shop' : 'SINO 상점'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${rewardsController.points}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  lang.isEnglish ? 'Customize your SINO' : 'SINO를 꾸며보세요',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  lang.isEnglish 
                    ? 'Earn points by tracking your mood and completing tasks!' 
                    : '기분을 기록하고 과제를 완료해서 포인트를 모으세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.disabledColor),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: rewardsController.skins.length,
              itemBuilder: (context, index) {
                final skin = rewardsController.skins[index];
                final isSelected = rewardsController.selectedSkinId == skin.id;
                
                return _SkinCard(
                  skin: skin,
                  isSelected: isSelected,
                  onTap: () {
                    if (skin.isUnlocked) {
                      rewardsController.selectSkin(skin.id);
                    } else if (rewardsController.points >= skin.cost) {
                      _showPurchaseDialog(context, skin, rewardsController);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang.isEnglish ? 'Not enough points!' : '포인트가 부족합니다!')),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, RewardSkin skin, RewardsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unlock ${skin.name}'),
        content: Text('Purchase this skin for ${skin.cost} points?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.purchaseSkin(skin.id);
              Navigator.pop(context);
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }
}

class _SkinCard extends StatelessWidget {
  final RewardSkin skin;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkinCard({
    required this.skin,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForSkin(skin.id),
                        size: 64,
                        color: skin.isUnlocked ? theme.primaryColor : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        skin.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      if (skin.isUnlocked)
                        Text(
                          isSelected ? 'Selected' : 'Owned',
                          style: TextStyle(color: theme.primaryColor, fontSize: 12),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.stars, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${skin.cost}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForSkin(String id) {
    switch (id) {
      case 'scientist': return Icons.science;
      case 'hero': return Icons.bolt;
      case 'traditional': return Icons.temple_buddhist;
      case 'confu': return Icons.auto_awesome;
      default: return Icons.face;
    }
  }
}
