import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// تعريف اللون الذهبي الرئيسي داخل الملف مباشرة لمنع أي خطأ في الملفات المفقودة
const Color kPrimaryGold = Color(0xFFD4AF37);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint("Initialization Error: $e");
  }
  runApp(const SkipCashPro());
}

class SkipCashPro extends StatelessWidget {
  const SkipCashPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkipCash Global PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        primaryColor: kPrimaryGold,
        colorScheme: const ColorScheme.dark(
          primary: kPrimaryGold,
          secondary: kPrimaryGold,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// ---------------- 0. AUTH WRAPPER ----------------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F0F0F),
            body: Center(child: CircularProgressIndicator(color: kPrimaryGold)),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return MainNavigationScreen(user: snapshot.data!);
        }
        return const AuthScreen();
      },
    );
  }
}

// ---------------- AUTH SCREEN (LOGIN / SIGNUP) ----------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
      _showMsg("يرجى ملء كافة الحقول المطلوبة");
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await cred.user?.updateDisplayName(name);
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'name': name,
          'email': email,
          'points': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      _showMsg(e.message ?? "حدث خطأ في التسجيل");
    } catch (e) {
      _showMsg("حدث خطأ غير متوقع");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars_rounded, size: 80, color: kPrimaryGold),
                const SizedBox(height: 10),
                const Text(
                  "SkipCash",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kPrimaryGold),
                ),
                const Text(
                  "شاهد وفز بالجوائز الحقيقية",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 40),

                Text(
                  isLogin ? "تسجيل الدخول" : "إنشاء حساب جديد",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),

                if (!isLogin) ...[
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "الاسم الكامل",
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.person, color: kPrimaryGold),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "البريد الإلكتروني",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.email, color: kPrimaryGold),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "كلمة المرور",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock, color: kPrimaryGold),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            isLogin ? "دخول" : "إنشاء الحساب",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 15),

                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? "ليس لديك حساب؟ سجل الآن" : "لديك حساب بالفعل؟ سجل دخولك",
                    style: const TextStyle(color: kPrimaryGold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- MAIN NAVIGATION ----------------
class MainNavigationScreen extends StatefulWidget {
  final User user;
  const MainNavigationScreen({super.key, required this.user});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      TikTokFeed(uid: widget.user.uid),
      const AdRewardScreen(),
      WalletScreen(uid: widget.user.uid),
      ProfileScreen(user: widget.user),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: kPrimaryGold,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.slow_motion_video_rounded), label: 'اكتشف'),
          BottomNavigationBarItem(icon: Icon(Icons.ads_click_rounded), label: 'المهام'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet_giftcard_rounded), label: 'المحفظة'),
          BottomNavigationBarItem(icon: Icon(Icons.person_pin_rounded), label: 'حسابي'),
        ],
      ),
    );
  }
}

// ---------------- 1. TIKTOK REELS FEED PRO ----------------
class TikTokFeed extends StatelessWidget {
  final String uid;
  const TikTokFeed({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final List<String> videoIds = ["dQw4w9WgXcQ", "L_LUpnjgPso", "3JZ_D3ELwOQ"];

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: videoIds.length,
      itemBuilder: (context, index) => TikTokVideoCard(videoId: videoIds[index], uid: uid),
    );
  }
}

class TikTokVideoCard extends StatefulWidget {
  final String videoId;
  final String uid;
  const TikTokVideoCard({super.key, required this.videoId, required this.uid});

  @override
  State<TikTokVideoCard> createState() => _TikTokVideoCardState();
}

class _TikTokVideoCardState extends State<TikTokVideoCard> {
  late YoutubePlayerController _controller;
  int _timer = 30;
  Timer? _countdown;
  bool _earned = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false, hideControls: true),
    )..addListener(() {
        if (_controller.value.isPlaying && _countdown == null && !_earned) {
          _startTimer();
        } else if (!_controller.value.isPlaying) {
          _countdown?.cancel();
          _countdown = null;
        }
      });
  }

  void _startTimer() {
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timer > 0) {
        if (mounted) setState(() => _timer--);
      } else {
        t.cancel();
        _givePoints();
      }
    });
  }

  void _givePoints() async {
    if (_earned || widget.uid.isEmpty) return;
    _earned = true;
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'points': FieldValue.increment(50),
        'last_watch': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🎉 مبروك! +50 نقطة"), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("Points Error: $e");
    }
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        YoutubePlayer(controller: _controller),
        Positioned(
          right: 15,
          bottom: 100,
          child: Column(
            children: [
              _sideIcon(Icons.favorite, "1.2k"),
              const SizedBox(height: 20),
              _sideIcon(Icons.comment, "450"),
              const SizedBox(height: 20),
              _sideIcon(Icons.share, "مشاركة"),
            ],
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: Text("00:$_timer", style: const TextStyle(color: kPrimaryGold, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.verified, color: kPrimaryGold),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sideIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 35),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

// ---------------- 2. AD REWARD SCREEN ----------------
class AdRewardScreen extends StatelessWidget {
  const AdRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المهام اليومية"), centerTitle: true, elevation: 0, backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _adTaskCard("شاهد إعلان فيديو مكافأة", "+100 نقطة", Icons.play_lesson_rounded),
          const SizedBox(height: 15),
          _adTaskCard("تثبيت تطبيق مقترح", "+500 نقطة", Icons.download_for_offline_rounded),
        ],
      ),
    );
  }

  Widget _adTaskCard(String title, String reward, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryGold, size: 40),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), Text(reward, style: const TextStyle(color: kPrimaryGold))])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 15),
        ],
      ),
    );
  }
}

// ---------------- 3. WALLET PRO WITH HISTORY ----------------
class WalletScreen extends StatelessWidget {
  final String uid;
  const WalletScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المحفظة"), centerTitle: true, backgroundColor: Colors.transparent, elevation: 0),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          int points = 0;
          if (snapshot.hasData && snapshot.data!.exists) {
            points = (snapshot.data!.data() as Map<String, dynamic>)['points'] ?? 0;
          }
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFF8A6E2F)]),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      const Text("رصيدك الحالي بالدولار", style: TextStyle(color: Colors.white70)),
                      Text("\$${(points / 1000).toStringAsFixed(2)}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                      Text("$points نقطة", style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Align(alignment: Alignment.centerRight, child: Text("سجل السحوبات الأخيرة", style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('withdrawals').where('userId', isEqualTo: uid).snapshots(),
                    builder: (context, subSnapshot) {
                      if (!subSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                      if (subSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("لا توجد عمليات سحب سابقة", style: TextStyle(color: Colors.grey)));
                      }
                      return ListView.builder(
                        itemCount: subSnapshot.data!.docs.length,
                        itemBuilder: (context, i) {
                          var doc = subSnapshot.data!.docs[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text("سحب ${doc['method'] ?? 'زين كاش'}"),
                            subtitle: Text(doc['status'] == 'Pending' ? "قيد المعالجة" : "تم الدفع ✅"),
                            trailing: Text("\$${doc['amountUSD'] ?? '1.00'}", style: const TextStyle(color: kPrimaryGold)),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------- 4. PROFILE PRO SCREEN ----------------
class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String name = user.displayName ?? 'مستخدم SkipCash';
    String email = user.email ?? '';

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 70),
              const CircleAvatar(
                radius: 45,
                backgroundColor: kPrimaryGold,
                child: Icon(Icons.person, size: 55, color: Colors.black),
              ),
              const SizedBox(height: 12),
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 6),
              const Text("عضو ذهبي 🏆", style: TextStyle(color: kPrimaryGold, fontSize: 13, fontWeight: FontWeight.w600)),
              
              const SizedBox(height: 30),

              // Developer Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C2512), Color(0xFF1A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kPrimaryGold.withOpacity(0.4), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryGold.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kPrimaryGold.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.code_rounded, color: kPrimaryGold, size: 28),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("مطور التطبيق", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          SizedBox(height: 2),
                          Text("جمال الحسناوي", style: TextStyle(color: kPrimaryGold, fontSize: 17, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.verified_user_rounded, color: kPrimaryGold, size: 20),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _profileOption(Icons.headset_mic_rounded, "الدعم الفني", () {}),
              _profileOption(Icons.share_rounded, "دعوة الأصدقاء", () {}),
              _profileOption(Icons.info_outline_rounded, "حول التطبيق", () {}),
              
              // Logout Button
              _profileOption(Icons.logout_rounded, "تسجيل الخروج", () async {
                await FirebaseAuth.instance.signOut();
              }, color: Colors.redAccent),

              const SizedBox(height: 30),
              const Text("SkipCash v2.0.0 Global Pro", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                "تطوير وتصميم جمال الحسناوي © جميع الحقوق محفوظة",
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileOption(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? kPrimaryGold),
        title: Text(title, style: TextStyle(fontSize: 15, color: color ?? Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
