import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/rewards_controller.dart';
import '../../controllers/language_controller.dart';

class RewardsShopScreen extends StatelessWidget {
  const RewardsShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    final rewards = context.watch<RewardsController>();
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang.isEnglish ? 'SINO Shop' : 'SINO 상점'),
          bottom: TabBar(
            tabs: [
              Tab(text: lang.isEnglish ? 'Character Skins' : '캐릭터 스킨'),
              Tab(text: lang.isEnglish ? 'Coupons' : '쿠폰'),
            ],
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${rewards.points}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _SkinsShop(rewards: rewards, lang: lang),
            _CouponsShop(rewards: rewards, lang: lang),
          ],
        ),
      ),
    );
  }
}

class _SkinsShop extends StatelessWidget {
  final RewardsController rewards;
  final LanguageController lang;

  const _SkinsShop({required this.rewards, required this.lang});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rewards.skins.length,
      itemBuilder: (context, index) {
        final skin = rewards.skins[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
               backgroundColor: Colors.grey[200],
               child: const Icon(Icons.person), // Placeholder for asset
            ),
            title: Text(skin.name),
            subtitle: Text(skin.isUnlocked 
              ? (lang.isEnglish ? 'Owned' : '보유중') 
              : '${skin.cost} Points'),
            trailing: skin.isUnlocked
                ? const Icon(Icons.check_circle, color: Colors.green)
                : ElevatedButton(
                    onPressed: rewards.points >= skin.cost 
                      ? () => rewards.purchaseSkin(skin.id)
                      : null,
                    child: Text(lang.isEnglish ? 'Buy' : '구매'),
                  ),
          ),
        );
      },
    );
  }
}

class _CouponsShop extends StatelessWidget {
  final RewardsController rewards;
  final LanguageController lang;

  const _CouponsShop({required this.rewards, required this.lang});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rewards.coupons.length,
      itemBuilder: (context, index) {
        final coupon = rewards.coupons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.confirmation_number_outlined, color: Colors.purple),
            title: Text(coupon.name),
            subtitle: Text('${coupon.cost} Points'),
            children: [
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                     Text(coupon.description, style: const TextStyle(color: Colors.grey)),
                     const SizedBox(height: 16),
                     if (coupon.isPurchased)
                       Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: Colors.green[50],
                           border: Border.all(color: Colors.green),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Column(
                           children: [
                              Text(
                                lang.isEnglish ? 'READY TO USE' : '사용 가능',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // In real app, show QR code or confirmation
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(lang.isEnglish ? 'Redeem Coupon?' : '쿠폰을 사용하시겠습니까?'),
                                      content: Text(lang.isEnglish ? 'This action cannot be undone.' : '이 작업은 취소할 수 없습니다.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text(lang.isEnglish ? 'Cancel' : '취소'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            rewards.redeemCoupon(coupon.id);
                                            Navigator.pop(ctx);
                                          },
                                          child: Text(lang.isEnglish ? 'Redeem' : '사용하기'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: Text(lang.isEnglish ? 'Use Now' : '지금 사용하기'),
                              ),
                           ],
                         ),
                       )
                     else
                       ElevatedButton(
                          onPressed: rewards.points >= coupon.cost
                            ? () => rewards.purchaseCoupon(coupon.id)
                            : null,
                          child: Text(lang.isEnglish ? 'Purchase for ${coupon.cost} Pts' : '${coupon.cost} 포인트로 구매'),
                       ),
                   ],
                 ),
               ),
            ],
          ),
        );
      },
    );
  }
}
