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
    debugPrint("Init Error: $e");
  }
}

class SkipCashApp extends StatelessWidget {
  const SkipCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkipCash Global',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.backgroundColor,
        colorScheme: const ColorScheme.dark(primary: AppColors.primaryGold),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  void _loadUserPoints() async {
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

  void _addPoints(int amount) async {
    setState(() {
      _userPoints += amount;
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
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      TikTokVideoFeed(onRewardEarned: () => _addPoints(50)),
      AdRewardScreen(onRewardEarned: (pts) => _addPoints(pts)),
      WalletScreen(userPoints: _userPoints, onDeductPoints: (pts) => _addPoints(-pts)),
      ProfileScreen(userPoints: _userPoints),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBg,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill), label: 'الفيديوهات'),
          BottomNavigationBarItem(icon: Icon(Icons.ads_click), label: 'الإعلانات'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'المحفظة'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

// ---------------- 1. TIKTOK / REELS FEED ----------------
class TikTokVideoFeed extends StatefulWidget {
  final VoidCallback onRewardEarned;
  const TikTokVideoFeed({super.key, required this.onRewardEarned});

  @override
  State<TikTokVideoFeed> createState() => _TikTokVideoFeedState();
}

class _TikTokVideoFeedState extends State<TikTokVideoFeed> {
  final List<String> _videoIds = [
    "dQw4w9WgXcQ",
    "L_LUpnjgPso",
    "3JZ_D3ELwOQ",
    "fJ9rUzIMcZQ",
  ];

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: _pageController,
      itemCount: _videoIds.length,
      itemBuilder: (context, index) {
        return TikTokVideoCard(
          videoId: _videoIds[index],
          videoIndex: index + 1,
          onRewardEarned: widget.onRewardEarned,
        );
      },
    );
  }
}

class TikTokVideoCard extends StatefulWidget {
  final String videoId;
  final int videoIndex;
  final VoidCallback onRewardEarned;

  const TikTokVideoCard({
    super.key,
    required this.videoId,
    required this.videoIndex,
    required this.onRewardEarned,
  });

  @override
  State<TikTokVideoCard> createState() => _TikTokVideoCardState();
}

class _TikTokVideoCardState extends State<TikTokVideoCard> {
  late YoutubePlayerController _controller;
  int _timerSeconds = 30;
  Timer? _timer;
  bool _isPlaying = false;
  bool _rewardClaimed = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    )..addListener(_onPlayerState);
  }

  void _onPlayerState() {
    if (_controller.value.isPlaying && !_isPlaying && !_rewardClaimed) {
      _startTimer();
    } else if (!_controller.value.isPlaying && _isPlaying) {
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

  void _claimReward() {
    setState(() {
      _rewardClaimed = true;
      _isPlaying = false;
    });
    widget.onRewardEarned();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 مبروك! ربحت 50 نقطة لمشاهدة الفيديو'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.primaryGold,
          ),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
            child: Text('00:$_timerSeconds', style: const TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
            child: Text('فيديو #${widget.videoIndex}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

// ---------------- 2. AD REWARD CENTER ----------------
class AdRewardScreen extends StatefulWidget {
  final Function(int) onRewardEarned;
  const AdRewardScreen({super.key, required this.onRewardEarned});

  @override
  State<AdRewardScreen> createState() => _AdRewardScreenState();
}

class _AdRewardScreenState extends State<AdRewardScreen> {
  RewardedAd? _rewardedAd;
  bool _isAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isAdReady = true;
          });
        },
        onAdFailedToLoad: (error) {
          setState(() => _isAdReady = false);
        },
      ),
    );
  }

  void _showAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        widget.onRewardEarned(100);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 حصلت على 100 نقطة لمشاهدة الإعلان!'), backgroundColor: Colors.green),
        );
        _loadRewardedAd();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مركز الإعلانات والربح'), backgroundColor: AppColors.cardBg),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: AppColors.cardBg,
              child: ListTile(
                leading: const Icon(Icons.video_library, color: AppColors.primaryGold, size: 36),
                title: const Text('شاهد إعلان مكافأة'),
                subtitle: const Text('ربح +100 نقطة عن كل إعلان كامل'),
                trailing: ElevatedButton(
                  onPressed: _isAdReady ? _showAd : null,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                  child: Text(_isAdReady ? 'مشاهدة' : 'تحميل...'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 3. WALLET & WITHDRAW SCREEN ----------------
class WalletScreen extends StatefulWidget {
  final int userPoints;
  final Function(int) onDeductPoints;

  const WalletScreen({super.key, required this.userPoints, required this.onDeductPoints});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _selectedMethod = 'زين كاش';
  final TextEditingController _accountController = TextEditingController();

  void _submitWithdraw() async {
    if (widget.userPoints < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(r'عذراً، الحد الأدنى للسحب هو 1000 نقطة (1.00\$)'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_accountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة رقم الحساب أو المحفظة'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('withdrawals').add({
          'userId': user.uid,
          'method': _selectedMethod,
          'account': _accountController.text.trim(),
          'pointsSpent': 1000,
          'amountUSD': 1.0,
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        widget.onDeductPoints(1000);
        _accountController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال طلب السحب بنجاح! سيتم التحويل قريباً.'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء السحب: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double usdBalance = widget.userPoints / 1000.0;

    return Scaffold(
      appBar: AppBar(title: const Text('المحفظة وسحب الأرباح'), backgroundColor: AppColors.cardBg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('رصيدك المالي الحالي', style: TextStyle(color: AppColors.textGrey)),
                  const SizedBox(height: 8),
                  Text('\$${usdBalance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
                  Text('${widget.userPoints} نقطة', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('اختر طريقة السحب:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              dropdownColor: AppColors.cardBg,
              items: ['زين كاش', 'كارت كيش / آسيا / زين', 'Binance USDT']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedMethod = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountController,
              decoration: const InputDecoration(
                labelText: 'رقم المحفظة / رقم الهاتف / عنوان المحفظة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                onPressed: _submitWithdraw,
                child: const Text(r'طلب سحب 1.00\$ (1000 نقطة)', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 4. PROFILE & AUTH SCREEN ----------------
class ProfileScreen extends StatelessWidget {
  final int userPoints;
  const ProfileScreen({super.key, required this.userPoints});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي'), backgroundColor: AppColors.cardBg),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: AppColors.primaryGold, child: Icon(Icons.person, size: 50, color: Colors.black)),
            const SizedBox(height: 12),
            Text('معرف المستخدِم: ${user?.uid.substring(0, 8) ?? "مجهول"}', style: const TextStyle(fontSize: 16, color: AppColors.textGrey)),
            const SizedBox(height: 24),
            ListTile(
              tileColor: AppColors.cardBg,
              title: const Text('مجموع النقاط المكتسبة'),
              trailing: Text('$userPoints نقطة', style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
