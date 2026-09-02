import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkipCashApp());
  
  _initServices();
}

Future<void> _initServices() async {
  try {
    await Firebase.initializeApp();
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint("Initialization Error: $e");
  }
}

class SkipCashApp extends StatelessWidget {
  const SkipCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkipCash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: 'Cairo',
      ),
      home: const VideoWatchDashboard(),
    );
  }
}

class VideoWatchDashboard extends StatefulWidget {
  const VideoWatchDashboard({super.key});

  @override
  State<VideoWatchDashboard> createState() => _VideoWatchDashboardState();
}

class _VideoWatchDashboardState extends State<VideoWatchDashboard> {
  late YoutubePlayerController _youtubeController;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  int _userPoints = 0;
  int _timerSeconds = 30;
  Timer? _timer;
  bool _isPlaying = false;
  bool _rewardClaimed = false;

  final String _videoId = "dQw4w9WgXcQ";

  @override
  void initState() {
    super.initState();
    _initYoutubePlayer();
    _loadBannerAd();
    _loadUserPointsFromFirebase();
  }

  void _loadUserPointsFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userPoints = doc.data()?['points'] ?? 0;
          });
        }
      } else {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (_) {}
  }

  void _initYoutubePlayer() {
    _youtubeController = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    )..addListener(_onPlayerStateChange);
  }

  void _onPlayerStateChange() {
    if (_youtubeController.value.isPlaying && !_isPlaying && !_rewardClaimed) {
      _startTimer();
    } else if (!_youtubeController.value.isPlaying && _isPlaying) {
      _pauseTimer();
    }
  }

  void _startTimer() {
    setState(() => _isPlaying = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
        _claimReward();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isPlaying = false);
  }

  void _claimReward() async {
    setState(() {
      _userPoints += 50;
      _rewardClaimed = true;
      _isPlaying = false;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'points': _userPoints,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('مبروك! تم إضافة 50 نقطة لرصيدك 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerLoaded = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    _bannerAd?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        title: const Text('SkipCash', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('رصيدك الحالي', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                    Text('$_userPoints نقطة', style: const TextStyle(color: AppColors.primaryGold, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '00:$_timerSeconds',
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: YoutubePlayer(
                controller: _youtubeController,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.primaryGold,
              ),
            ),
          ),
          const Spacer(),
          if (_isBannerLoaded)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}

