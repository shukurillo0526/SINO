import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/consent_controller.dart';
import '../../controllers/language_controller.dart';
import '../../core/language/strings.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final consent = context.watch<ConsentController>();
    final lang = context.watch<LanguageController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.isEnglish ? 'Privacy & Consent' : '개인정보 및 동의'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoSection(context, lang),
          const SizedBox(height: 24),
          _buildToggle(
            context,
            title: lang.isEnglish ? 'Share Mood with Parents' : '부모님과 기분 공유',
            subtitle: lang.isEnglish 
                ? 'Allow parents to see your emotional trends.' 
                : '부모님이 나의 감정 변화를 볼 수 있도록 허용합니다.',
            value: consent.shareMood,
            onChanged: (val) => consent.toggleShareMood(val),
          ),
          _buildToggle(
            context,
            title: lang.isEnglish ? 'Share Academic Progress' : '학습 진행 상황 공유',
            subtitle: lang.isEnglish 
                ? 'Allow parents to see your timetable and tasks.' 
                : '부모님이 나의 시간표와 할 일을 볼 수 있도록 허용합니다.',
            value: consent.shareAcademics,
            onChanged: (val) => consent.toggleShareAcademics(val),
          ),
          _buildToggle(
            context,
            title: lang.isEnglish ? 'Share App Activity' : '앱 활동 공유',
            subtitle: lang.isEnglish 
                ? 'Allow parents to see which features you use.' 
                : '부모님이 내가 어떤 기능을 사용하는지 볼 수 있도록 허용합니다.',
            value: consent.shareActivity,
            onChanged: (val) => consent.toggleShareActivity(val),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => _showWipeDataDialog(context, lang),
            icon: const Icon(Icons.delete_forever),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            label: Text(lang.isEnglish ? 'Wipe All Local Data' : '모든 로컬 데이터 삭제'),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              lang.isEnglish 
                  ? 'Your data is encrypted and stored locally.' 
                  : '귀하의 데이터는 암호화되어 로컬에 저장됩니다.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, LanguageController lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                lang.isEnglish ? 'Your Privacy Matters' : '귀하의 개인정보는 소중합니다',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lang.isEnglish 
                ? 'SINO only shares what you allow. You can change these settings at any time.' 
                : 'SINO는 귀하가 허용한 정보만 공유합니다. 이 설정은 언제든지 변경할 수 있습니다.',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).primaryColor,
    );
  }

  void _showWipeDataDialog(BuildContext context, LanguageController lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.isEnglish ? 'Wipe All Data?' : '모든 데이터를 삭제할까요?'),
        content: Text(lang.isEnglish 
            ? 'This will permanently delete all your local mood history, settings, and progress. This action cannot be undone.' 
            : '이 작업은 모든 로컬 기분 내역, 설정 및 진행 상황을 영구적으로 삭제합니다. 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.isEnglish ? 'Cancel' : '취소'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<ConsentController>().wipeAllData();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: Text(
              lang.isEnglish ? 'Delete Everything' : '모두 삭제',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
