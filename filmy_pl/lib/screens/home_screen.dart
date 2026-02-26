import 'package:flutter/material.dart';
import '../models/video.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'video_player_screen.dart';
import '../widgets/video_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Video> _videos = [];
  List<Video> _filtered = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _email = await AuthService.getEmail();
    await _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() { _loading = true; _error = null; });
    try {
      final videos = await ApiService.getVideos();
      if (!mounted) return;
      setState(() {
        _videos = videos;
        _filtered = videos;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearch(String q) {
    setState(() {
      _search = q;
      if (q.isEmpty) {
        _filtered = _videos;
      } else {
        _filtered = _videos
            .where((v) =>
                v.displayName.toLowerCase().contains(q.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            snap: true,
            pinned: true,
            backgroundColor: const Color(0xFF0E1320),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎬 Filmy PL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (_email != null)
                    Text(
                      _email!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _loadVideos,
                tooltip: 'Odśwież',
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: _logout,
                tooltip: 'Wyloguj',
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
        body: RefreshIndicator(
          color: const Color(0xFF39D3FF),
          backgroundColor: const Color(0xFF0E1320),
          onRefresh: _loadVideos,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    onChanged: _onSearch,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Szukaj filmów...',
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFFA2A8B8)),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Color(0xFFA2A8B8), size: 18),
                              onPressed: () {
                                _onSearch('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation(Color(0xFF39D3FF)),
                    ),
                  ),
                )
              else if (_error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFFF6B7A), size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Błąd ładowania filmów',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(_error!,
                              style: const TextStyle(
                                  color: Color(0xFFA2A8B8), fontSize: 13),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadVideos,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Spróbuj ponownie'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie_filter_outlined,
                            color: Colors.white.withOpacity(0.2), size: 64),
                        const SizedBox(height: 16),
                        Text(
                          _search.isNotEmpty
                              ? 'Brak wyników dla "$_search"'
                              : 'Brak filmów',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final video = _filtered[index];
                        return VideoCard(
                          video: video,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    VideoPlayerScreen(video: video),
                              ),
                            );
                          },
                        );
                      },
                      childCount: _filtered.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
