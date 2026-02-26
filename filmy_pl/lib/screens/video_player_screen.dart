import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/video.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Video video;
  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _playerLoading = true;
  String? _playerError;

  // Lajki
  bool _liked = false;
  int _likeCount = 0;
  bool _likeLoading = false;

  // Komentarze
  List<Comment> _comments = [];
  bool _commentsLoading = true;
  final _commentCtrl = TextEditingController();
  bool _sendingComment = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _loadLikes();
    _loadComments();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    _userEmail = await AuthService.getEmail();
  }

  Future<void> _initPlayer() async {
    try {
      final token = await AuthService.getToken();
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.url),
        httpHeaders: {'Authorization': 'Bearer $token'},
      );
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF39D3FF),
          handleColor: const Color(0xFF39D3FF),
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      );
      if (mounted) setState(() => _playerLoading = false);
    } catch (e) {
      if (mounted) setState(() {
        _playerError = 'Nie można załadować filmu';
        _playerLoading = false;
      });
    }
  }

  Future<void> _loadLikes() async {
    try {
      final result = await ApiService.getLikeStatus(widget.video.filename);
      if (mounted) setState(() {
        _liked = result['liked'] ?? false;
        _likeCount = result['count'] ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _toggleLike() async {
    if (_likeLoading) return;
    setState(() => _likeLoading = true);
    try {
      final result = await ApiService.toggleLike(widget.video.filename);
      if (mounted) setState(() {
        _liked = result['liked'] ?? false;
        _likeCount = result['count'] ?? 0;
      });
    } catch (_) {}
    if (mounted) setState(() => _likeLoading = false);
  }

  Future<void> _loadComments() async {
    setState(() => _commentsLoading = true);
    try {
      final comments = await ApiService.getComments(widget.video.filename);
      if (mounted) setState(() => _comments = comments);
    } catch (_) {}
    if (mounted) setState(() => _commentsLoading = false);
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _sendingComment) return;
    setState(() => _sendingComment = true);
    try {
      final result = await ApiService.addComment(widget.video.filename, text);
      if (result['success'] == true && mounted) {
        _commentCtrl.clear();
        FocusScope.of(context).unfocus();
        await _loadComments();
      }
    } catch (_) {}
    if (mounted) setState(() => _sendingComment = false);
  }

  Future<void> _deleteComment(int id) async {
    try {
      await ApiService.deleteComment(widget.video.filename, id);
      await _loadComments();
    } catch (_) {}
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.video.displayName,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          // Player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _playerLoading
                  ? const Center(child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF39D3FF))))
                  : _playerError != null
                      ? Center(child: Text(_playerError!,
                          style: const TextStyle(color: Colors.white70)))
                      : Chewie(controller: _chewieController!),
            ),
          ),

          // Reszta scrollowalna
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tytuł + lajk
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.video.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Przycisk lajka
                      GestureDetector(
                        onTap: _toggleLike,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _liked
                                ? const Color(0xFFFF6B7A).withOpacity(0.2)
                                : Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _liked
                                  ? const Color(0xFFFF6B7A).withOpacity(0.6)
                                  : Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _liked ? Icons.favorite : Icons.favorite_border,
                                color: _liked
                                    ? const Color(0xFFFF6B7A)
                                    : Colors.white54,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$_likeCount',
                                style: TextStyle(
                                  color: _liked
                                      ? const Color(0xFFFF6B7A)
                                      : Colors.white54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (widget.video.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      widget.video.description,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13,
                          height: 1.6),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),

                  // Nagłówek komentarzy
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          color: Color(0xFF39D3FF), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Komentarze (${_comments.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Pole dodawania komentarza
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          maxLines: 3,
                          minLines: 1,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: 'Napisz komentarz...',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 13),
                            counterStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 10),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _sendComment,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF39D3FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: _sendingComment
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        Color(0xFF0A0C12)),
                                  ),
                                )
                              : const Icon(Icons.send_rounded,
                                  color: Color(0xFF0A0C12), size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Lista komentarzy
                  if (_commentsLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF39D3FF)),
                        ),
                      ),
                    )
                  else if (_comments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Brak komentarzy. Bądź pierwszy!',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_comments.length, (i) {
                      final c = _comments[i];
                      final isOwn = _userEmail == c.email;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E1320),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.07)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF39D3FF).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFF39D3FF).withOpacity(0.3)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      c.email.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF39D3FF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    c.shortEmail,
                                    style: const TextStyle(
                                      color: Color(0xFF39D3FF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  c.createdAt.substring(0, 16),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.25),
                                    fontSize: 10,
                                  ),
                                ),
                                if (isOwn) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor: const Color(0xFF0E1320),
                                        title: const Text('Usuń komentarz',
                                            style: TextStyle(color: Colors.white)),
                                        content: const Text('Na pewno usunąć?',
                                            style: TextStyle(color: Colors.white70)),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Anuluj',
                                                style: TextStyle(color: Colors.white54)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _deleteComment(c.id);
                                            },
                                            child: const Text('Usuń',
                                                style: TextStyle(color: Color(0xFFFF6B7A))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: Icon(Icons.delete_outline,
                                        color: Colors.white.withOpacity(0.25),
                                        size: 16),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              c.content,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
