import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/language_controller.dart';

class CrisisResourcesScreen extends StatelessWidget {
  const CrisisResourcesScreen({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.isEnglish ? 'Support Resources' : '도움 안내'),
        backgroundColor: Colors.red[50],
        foregroundColor: Colors.red[900],
      ),
      body: Container(
        color: Colors.red[50],
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.favorite, size: 60, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              lang.isEnglish 
                ? "You are important, and help is available." 
                : "당신은 소중한 사람입니다. 언제든 도움을 받을 수 있어요.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              lang.isEnglish 
                ? "Please reach out to one of these free, confidential services if you're feeling overwhelmed." 
                : "마음이 너무 힘들다면 주저하지 말고 아래 연락처로 연락주세요. 모든 상담은 비밀이 보장됩니다.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            
            _ResourceCard(
              title: lang.isEnglish ? "National Suicide Prevention Lifeline" : "자살예방 상담전화",
              number: "988",
              description: lang.isEnglish ? "24/7 free and confidential support" : "24시간 무료 비밀 상담",
              onCall: () => _makeCall("988"),
              icon: Icons.support_agent,
            ),
            const SizedBox(height: 16),

            _ResourceCard(
              title: lang.isEnglish ? "Crisis Text Line" : "청소년 모바일 상담 '다 들어줄 개'",
              number: "741741",
              description: lang.isEnglish ? "Text HOME to 741741" : "문자 또는 앱을 통한 상담",
              onCall: () => _makeCall("741741"),
              icon: Icons.textsms,
            ),
            const SizedBox(height: 16),

            if (!lang.isEnglish) ...[
               _ResourceCard(
                title: "희망의 전화",
                number: "129",
                description: "보건복지부 관련 상담",
                onCall: () => _makeCall("129"),
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),
            ],

            _ResourceCard(
              title: lang.isEnglish ? "Emergency Services" : "응급 서비스",
              number: lang.isEnglish ? "911" : "119",
              description: lang.isEnglish ? "For immediate physical danger" : "위급 상황 시 신고",
              onCall: () => _makeCall(lang.isEnglish ? "911" : "119"),
              icon: Icons.local_police,
              isEmergency: true,
            ),

            const SizedBox(height: 40),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(lang.isEnglish ? "Back to Safety" : "뒤로 가기"),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String title;
  final String number;
  final String description;
  final VoidCallback onCall;
  final IconData icon;
  final bool isEmergency;

  const _ResourceCard({
    required this.title,
    required this.number,
    required this.description,
    required this.onCall,
    required this.icon,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isEmergency ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onCall,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEmergency ? Colors.red : Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isEmergency ? Colors.white : Colors.blue, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      number,
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.w900, 
                        color: isEmergency ? Colors.red : Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.phone_forwarded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
