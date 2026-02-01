import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';

class ShortReel {
  final String id;
  final String url;
  final String titleEn;
  final String titleKo;
  final String descriptionEn;
  final String descriptionKo;

  ShortReel({
    required this.id,
    required this.url,
    required this.titleEn,
    required this.titleKo,
    required this.descriptionEn,
    required this.descriptionKo,
  });
}

class ShortReelScreen extends StatefulWidget {
  const ShortReelScreen({super.key});

  @override
  State<ShortReelScreen> createState() => _ShortReelScreenState();
}

class _ShortReelScreenState extends State<ShortReelScreen> {
  final List<ShortReel> _reels = [
    ShortReel(
      id: '1',
      url: 'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-leaves-low-angle-shot-4725-large.mp4',
      titleEn: 'Nature Calm',
      titleKo: '자연의 평온',
      descriptionEn: 'Take a deep breath and look at the leaves.',
      descriptionKo: '심호흡을 하고 나뭇잎을 바라보세요.',
    ),
    ShortReel(
      id: '2',
      url: 'https://assets.mixkit.co/videos/preview/mixkit-meditation-in-a-sunny-room-48560-large.mp4',
      titleEn: 'Mindful Moment',
      titleKo: '마음챙김의 시간',
      descriptionEn: 'Find a quiet place to sit and relax.',
      descriptionKo: '조용한 장소를 찾아 편안히 앉아보세요.',
    ),
    ShortReel(
      id: '3',
      url: 'https://assets.mixkit.co/videos/preview/mixkit-waves-coming-to-the-beach-shore-at-sunset-44310-large.mp4',
      titleEn: 'Sunset Waves',
      titleKo: '노을 지는 파도',
      descriptionEn: 'Listen to the sound of the ocean.',
      descriptionKo: '바다의 소리에 귀를 기울여보세요.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        itemBuilder: (context, index) {
          return ReelItem(reel: _reels[index]);
        },
      ),
    );
  }
}

class ReelItem extends StatefulWidget {
  final ShortReel reel;
  const ReelItem({super.key, required this.reel});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.reel.url));
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );
    
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();

    return Stack(
      children: [
        if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
          Center(
            child: AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        
        // Info Overlay
        Positioned(
          bottom: 40,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.isEnglish ? widget.reel.titleEn : widget.reel.titleKo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang.isEnglish ? widget.reel.descriptionEn : widget.reel.descriptionKo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))],
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        Positioned(
          bottom: 60,
          right: 16,
          child: Column(
            children: [
              _ActionButton(icon: Icons.favorite_border, label: 'Mood +'),
              const SizedBox(height: 20),
              _ActionButton(icon: Icons.share, label: 'Share'),
              const SizedBox(height: 20),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 35),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
