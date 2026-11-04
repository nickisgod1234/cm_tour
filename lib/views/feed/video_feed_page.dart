import 'package:cm_tour/models/catalog.dart';
import 'package:cm_tour/state/app_controller.dart';
import 'package:cm_tour/utils/tool_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videos = context.watch<AppController>().videos;
    return ColoredBox(
      color: Colors.black,
      child: PageView.builder(
        controller: _page,
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (context, index) {
          return _VideoPane(
            video: videos[index],
            active: index == _index,
          );
        },
      ),
    );
  }
}

class _VideoPane extends StatefulWidget {
  const _VideoPane({required this.video, required this.active});

  final FeedVideo video;
  final bool active;

  @override
  State<_VideoPane> createState() => _VideoPaneState();
}

class _VideoPaneState extends State<_VideoPane> {
  VideoPlayerController? _controller;
  var _playing = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(covariant _VideoPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.id != widget.video.id ||
        (oldWidget.video.errorText != null && widget.video.errorText == null)) {
      _disposePlayer();
      _prepare();
      return;
    }
    if (widget.active && !_playing) {
      _controller?.play();
      _playing = true;
    } else if (!widget.active && _playing) {
      _controller?.pause();
      _playing = false;
    }
  }

  Future<void> _prepare() async {
    final url = widget.video.videoUrl;
    if (url == null || widget.video.errorText != null) return;
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted || _controller != controller) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(true);
      if (widget.active) {
        await controller.play();
        _playing = true;
      }
      setState(() {});
    } catch (error) {
      if (_controller == controller) {
        widget.video.errorText = '$error';
      }
      if (mounted) setState(() {});
    }
  }

  void _disposePlayer() {
    _controller?.dispose();
    _controller = null;
    _playing = false;
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final missing = video.videoUrl == null || video.videoUrl!.isEmpty;
    final failed = missing || video.errorText != null;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!failed && _controller?.value.isInitialized == true)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          )
        else if (!failed)
          const ColoredBox(color: Color(0xFF111111))
        else
          _ErrorBody(video: video),
        if (!failed)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 80, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.author, style: ToolUtility.prompt(16, color: Colors.white, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(video.title, style: ToolUtility.prompt(14, color: Colors.white)),
                ],
              ),
            ),
          ),
        Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: _ActionRail(video: video),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.video});

  final FeedVideo video;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 80, 72, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF8E8E8E), size: 72),
          const SizedBox(height: 18),
          Text(
            'iOS: ไม่สามารถโหลดวิดีโอได้\n(AVPlayer)',
            textAlign: TextAlign.center,
            style: ToolUtility.prompt(20, color: Colors.white, weight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            '🍎  iOS โดยปกติทำงานได้ดี - อาจเป็นปัญหาเครือข่าย',
            textAlign: TextAlign.center,
            style: ToolUtility.prompt(13, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF5A1E24),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF7A3038)),
            ),
            child: Text(
              video.errorText ?? 'ไม่มีไฟล์วิดีโอ',
              style: ToolUtility.prompt(13, color: const Color(0xFFFFB4B4)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ลองแล้ว ${video.attempts}/${video.maxAttempts} ครั้ง',
            style: ToolUtility.prompt(14, color: const Color(0xFFBDBDBD)),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => app.retryVideo(video),
            style: FilledButton.styleFrom(
              backgroundColor: ToolUtility.colorRetry,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Text('ลองใหม่', style: ToolUtility.prompt(16, color: Colors.white)),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(video.author, style: ToolUtility.prompt(16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({required this.video});

  final FeedVideo video;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppController>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Action(
          icon: video.liked ? Icons.favorite : Icons.favorite_border,
          color: video.liked ? ToolUtility.colorRetry : Colors.white,
          label: '${video.likes}',
          onTap: () => app.toggleLike(video),
        ),
        _Action(
          icon: Icons.share,
          label: '',
          onTap: () => _share(context),
        ),
        _Action(
          icon: Icons.chat_bubble_outline,
          label: '${video.comments.length}',
          onTap: () => _comments(context),
        ),
        _Action(
          icon: Icons.remove_red_eye_outlined,
          label: '${video.views}',
          onTap: () => app.addView(video),
        ),
        _Action(
          icon: Icons.outlined_flag,
          label: '',
          onTap: () => _report(context),
        ),
      ],
    );
  }

  Future<void> _share(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: '${video.title} ${video.author}'));
    if (!context.mounted) return;
    ToolUtility.toast(context, true, 'คัดลอกลิงก์คลิปแล้ว');
  }

  Future<void> _comments(BuildContext context) async {
    final app = context.read<AppController>();
    final input = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1C),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SizedBox(
            height: 360,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text('ความคิดเห็น', style: ToolUtility.prompt(16, color: Colors.white)),
                Expanded(
                  child: ListView(
                    children: [
                      if (video.comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'ยังไม่มีความคิดเห็น',
                            textAlign: TextAlign.center,
                            style: ToolUtility.prompt(14, color: Colors.white70),
                          ),
                        ),
                      for (final comment in video.comments)
                        ListTile(
                          title: Text(comment, style: ToolUtility.prompt(14, color: Colors.white)),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: input,
                          style: ToolUtility.prompt(14, color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'แสดงความคิดเห็น',
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          app.addComment(video, input.text);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    input.dispose();
  }

  Future<void> _report(BuildContext context) async {
    final app = context.read<AppController>();
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        const reasons = ['เนื้อหาไม่เหมาะสม', 'สแปม', 'ละเมิดลิขสิทธิ์', 'อื่นๆ'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('รายงานคลิป', style: ToolUtility.prompt(16, weight: FontWeight.w700)),
              for (final item in reasons)
                ListTile(
                  title: Text(item, style: ToolUtility.prompt(15)),
                  onTap: () => Navigator.pop(context, item),
                ),
            ],
          ),
        );
      },
    );
    if (reason == null || !context.mounted) return;
    app.report(video);
    ToolUtility.toast(context, true, 'ส่งรายงานแล้ว: $reason');
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.onTap,
    this.label = '',
    this.color = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            if (label.isNotEmpty)
              Text(label, style: ToolUtility.prompt(12, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
