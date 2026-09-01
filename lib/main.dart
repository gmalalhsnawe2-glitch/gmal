import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userPoints = doc.data()?['points'] ?? 0;
        });
      }
    }
  }

  void _initYoutubePlayer() {
    _youtubeController = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    )..addListener(_onPlayerStateChange);
  }

  void _onPlayerStateChange() {
    if (_youtubeController.value.isPlaying && !_isPlaying && !_rewardClaimed) {
      _startRewardTimer();
    } else if (!_youtubeController.value.isPlaying && _isPlaying) {
      _pauseRewardTimer();
    }
  }

  void _startRewardTimer() {
    setState(() => _isPlaying = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
        _addPointsToFirebase(50);
      }
    });
  }

  void _pauseRewardTimer() {
    _timer?.cancel();
    setState(() => _isPlaying = false);
  }

  void _addPointsToFirebase(int points) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.set({
        'points': FieldValue.increment(points),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _userPoints += points;
        _rewardClaimed = true;
        _isPlaying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة $points نقطة لحسابك بنجاح!'), backgroundColor: Colors.green),
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
    _timer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SkipCash | مشاهدة وربح', style: TextStyle(color: AppColors.textWhite)),
        backgroundColor: AppColors.cardBg,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('رصيدك في السيرفر', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('$_userPoints نقطة', style: const TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('الوقت المتبقي', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('$_timerSeconds ثانية', style: TextStyle(color: _timerSeconds == 0 ? Colors.green : AppColors.primaryRed, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: YoutubePlayer(
                controller: _youtubeController,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.primaryRed,
              ),
            ),
          ),
          const Spacer(),
          if (_isBannerLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
