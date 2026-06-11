import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'screens/dashboard_screen.dart';
import 'screens/ai_coach_screen.dart';
import 'screens/sports_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/dynamic_island.dart';

// Compile-time immutable app mode define: 'developer' or 'user'
const String appMode = 'developer';

void main() {
  // Ensure status bar looks integrated
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF090A11),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const FlyingRunApp(),
    ),
  );
}

class FlyingRunThemeState {
  final bool isDarkMode;
  final Color backgroundColor1;
  final Color activeSwitchColor;
  final bool isLoggedIn;

  const FlyingRunThemeState({
    required this.isDarkMode,
    required this.backgroundColor1,
    required this.activeSwitchColor,
    required this.isLoggedIn,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlyingRunThemeState &&
          runtimeType == other.runtimeType &&
          isDarkMode == other.isDarkMode &&
          backgroundColor1 == other.backgroundColor1 &&
          activeSwitchColor == other.activeSwitchColor &&
          isLoggedIn == other.isLoggedIn;

  @override
  int get hashCode =>
      isDarkMode.hashCode ^
      backgroundColor1.hashCode ^
      activeSwitchColor.hashCode ^
      isLoggedIn.hashCode;
}

class MainShellThemeState {
  final bool isDarkMode;
  final Color backgroundColor1;
  final Color backgroundColor2;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color activeSwitchColor;
  final Color currentCoachThemeColor;

  const MainShellThemeState({
    required this.isDarkMode,
    required this.backgroundColor1,
    required this.backgroundColor2,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.activeSwitchColor,
    required this.currentCoachThemeColor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainShellThemeState &&
          runtimeType == other.runtimeType &&
          isDarkMode == other.isDarkMode &&
          backgroundColor1 == other.backgroundColor1 &&
          backgroundColor2 == other.backgroundColor2 &&
          primaryTextColor == other.primaryTextColor &&
          secondaryTextColor == other.secondaryTextColor &&
          activeSwitchColor == other.activeSwitchColor &&
          currentCoachThemeColor == other.currentCoachThemeColor;

  @override
  int get hashCode =>
      isDarkMode.hashCode ^
      backgroundColor1.hashCode ^
      backgroundColor2.hashCode ^
      primaryTextColor.hashCode ^
      secondaryTextColor.hashCode ^
      activeSwitchColor.hashCode ^
      currentCoachThemeColor.hashCode;
}

class FlyingRunApp extends StatelessWidget {
  const FlyingRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, FlyingRunThemeState>(
      selector: (context, state) => FlyingRunThemeState(
        isDarkMode: state.isDarkMode,
        backgroundColor1: state.backgroundColor1,
        activeSwitchColor: state.activeSwitchColor,
        isLoggedIn: state.isLoggedIn,
      ),
      builder: (context, themeState, child) {
        final isDark = themeState.isDarkMode;
        return MaterialApp(
          title: 'Flying Run - AI Sports & Health',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            scaffoldBackgroundColor: themeState.backgroundColor1,
            primaryColor: themeState.activeSwitchColor,
            colorScheme: ColorScheme.light(
              primary: themeState.activeSwitchColor,
              secondary: const Color(0xFFFF6B00),
              tertiary: const Color(0xFF8B5CF6),
              surface: Colors.white.withValues(alpha: 0.4),
            ),
            textTheme: const TextTheme(
              titleLarge: TextStyle(fontFamily: 'system-ui', fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              bodyMedium: TextStyle(fontFamily: 'system-ui', color: Color(0xFF64748B)),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            scaffoldBackgroundColor: themeState.backgroundColor1,
            primaryColor: themeState.activeSwitchColor,
            colorScheme: ColorScheme.dark(
              primary: themeState.activeSwitchColor,
              secondary: const Color(0xFFFF6B00),
              tertiary: const Color(0xFF8B5CF6),
              surface: Colors.white.withValues(alpha: 0.06),
            ),
            textTheme: const TextTheme(
              titleLarge: TextStyle(fontFamily: 'system-ui', fontWeight: FontWeight.bold, color: Colors.white),
              bodyMedium: TextStyle(fontFamily: 'system-ui', color: Colors.white70),
            ),
          ),
          home: themeState.isLoggedIn ? const MainShell() : const LoginScreen(),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<String> _titles = [
    '健康监测',
    'AI 伴跑教练',
    '运动打卡',
    '数据分析报告',
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);

    return Selector<AppState, MainShellThemeState>(
      selector: (context, state) => MainShellThemeState(
        isDarkMode: state.isDarkMode,
        backgroundColor1: state.backgroundColor1,
        backgroundColor2: state.backgroundColor2,
        primaryTextColor: state.primaryTextColor,
        secondaryTextColor: state.secondaryTextColor,
        activeSwitchColor: state.activeSwitchColor,
        currentCoachThemeColor: state.currentCoach.themeColor,
      ),
      builder: (context, themeState, screensChild) {
        final isDark = themeState.isDarkMode;

        // Dynamically change AppBar / UI glows based on the active tab and selected coach
        Color activeGlowColor = const Color(0xFF00E6FF);
        if (_currentIndex == 1) {
          activeGlowColor = themeState.currentCoachThemeColor;
        } else if (_currentIndex == 2) {
          activeGlowColor = const Color(0xFFFF6B00);
        } else if (_currentIndex == 3) {
          activeGlowColor = const Color(0xFF10B981);
        }

        return ValueListenableBuilder<double>(
          valueListenable: state.simulatedHourNotifier,
          builder: (context, hourVal, childStack) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              extendBody: true, // Allows bottom bar to be transparent/floating over body
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: themeState.backgroundColor1.withValues(alpha: 0.85),
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Row(
                  children: [
                    Tooltip(
                      message: '用户中心与版本切换',
                      child: GestureDetector(
                        onTap: () => _showUserProfileAndVersionSheet(context, state),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [activeGlowColor, activeGlowColor.withValues(alpha: 0.5)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              'web/favicon.png',
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      _titles[_currentIndex],
                      style: TextStyle(
                        color: themeState.primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Theme toggler (Sun / Moon)
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                      color: themeState.primaryTextColor.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    onPressed: () {
                      state.toggleThemeMode();
                    },
                  ),
                  // Security lock indicator as header decoration
                  IconButton(
                    icon: Icon(Icons.verified_user_outlined, color: activeGlowColor.withValues(alpha: 0.7), size: 20),
                    onPressed: () {
                      DynamicIsland.show(
                        context,
                        title: '机密计算安全卫士',
                        message: '已启用端侧机密计算，本地原始心率/步数/GPS数据均点对点加密存储。',
                        icon: Icons.security_rounded,
                        color: activeGlowColor,
                      );
                    },
                  ),
                ],
              ),
              body: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      themeState.backgroundColor1,
                      themeState.backgroundColor2,
                    ],
                  ),
                ),
                child: childStack,
              ),
              // Floating Frosted Bottom Navigation Bar
              bottomNavigationBar: MainBottomNavigationBar(
                currentIndex: _currentIndex,
                activeGlowColor: activeGlowColor,
                state: state,
                isDark: isDark,
                onTap: (index) {
                  state.stopSpeaking();
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            );
          },
          child: Stack(
            children: [
              // Subtle background decorative glows
              Positioned(
                top: -150,
                right: -100,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    color: activeGlowColor.withValues(alpha: isDark ? 0.12 : 0.08),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: activeGlowColor.withValues(alpha: isDark ? 0.08 : 0.05),
                        blurRadius: 150,
                        spreadRadius: 80,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -150,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.06 : 0.04),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.04 : 0.02),
                        blurRadius: 120,
                        spreadRadius: 60,
                      )
                    ],
                  ),
                ),
              ),
              // Main Screen contents
              screensChild!,
            ],
          ),
        );
      },
      child: SafePadding(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            const DashboardScreen(),
            const AiCoachScreen(),
            const SportsScreen(),
            ReportsScreen(isActive: _currentIndex == 3),
          ],
        ),
      ),
    );
  }

  void _showUserProfileAndVersionSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (context) {
        return UserProfileSheetContent(state: state);
      },
    ).then((_) {
      state.refreshUI();
    });
  }
}

class UserProfileSheetContent extends StatefulWidget {
  final AppState state;
  const UserProfileSheetContent({super.key, required this.state});

  @override
  State<UserProfileSheetContent> createState() => _UserProfileSheetContentState();
}

class _UserProfileSheetContentState extends State<UserProfileSheetContent> with WidgetsBindingObserver {
  late final TextEditingController schoolCtrl;
  late final TextEditingController studentCtrl;
  late final TextEditingController clinicCtrl;
  late final TextEditingController residentCtrl;
  late final TextEditingController emergencyCtrl;
  double _keyboardHeight = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    schoolCtrl = TextEditingController(text: widget.state.schoolName);
    studentCtrl = TextEditingController(text: widget.state.studentId);
    clinicCtrl = TextEditingController(text: widget.state.assignedClinic);
    residentCtrl = TextEditingController(text: widget.state.residentId);
    emergencyCtrl = TextEditingController(text: widget.state.emergencyContact);
    _checkKeyboardStatus();
  }

  @override
  void dispose() {
    schoolCtrl.dispose();
    studentCtrl.dispose();
    clinicCtrl.dispose();
    residentCtrl.dispose();
    emergencyCtrl.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _checkKeyboardStatus();
  }

  void _checkKeyboardStatus() {
    if (WidgetsBinding.instance.platformDispatcher.views.isEmpty) return;
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final bottomInset = view.viewInsets.bottom;
    final devicePixelRatio = view.devicePixelRatio;
    final keyboardHeight = bottomInset / devicePixelRatio;
    if (_keyboardHeight != keyboardHeight) {
      setState(() {
        _keyboardHeight = keyboardHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;
    final primaryColor = state.activeSwitchColor;
    final appMode = state.activeMode == 'normal'
        ? '基础版本'
        : state.activeMode == 'campus'
            ? '校园阳光跑'
            : '社区康养';

    return Padding(
      padding: EdgeInsets.only(bottom: _keyboardHeight),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F101A) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primaryColor.withValues(alpha: 0.2),
                    child: Icon(Icons.person_rounded, color: primaryColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '开发模式测试用户',
                          style: TextStyle(
                            color: state.primaryTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'developer@flyingrun.com',
                          style: TextStyle(
                            color: state.secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
              const SizedBox(height: 16),
              Text(
                '工作模式切换',
                style: TextStyle(
                  color: state.primaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildModeTabItem(
                      label: '普通版',
                      icon: Icons.directions_run_rounded,
                      modeValue: 'normal',
                      activeColor: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildModeTabItem(
                      label: '校园版',
                      icon: Icons.school_rounded,
                      modeValue: 'campus',
                      activeColor: const Color(0xFF00E6FF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildModeTabItem(
                      label: '社区版',
                      icon: Icons.health_and_safety_rounded,
                      modeValue: 'community',
                      activeColor: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: _buildDynamicSettingsPanel(),
              ),
              const SizedBox(height: 24),
              Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '当前模式: $appMode',
                    style: TextStyle(color: state.secondaryTextColor, fontSize: 10),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      state.logout();
                    },
                    icon: const Icon(Icons.logout_rounded, size: 14, color: Colors.white),
                    label: const Text('退出登录', style: TextStyle(fontSize: 11, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTabItem({
    required String label,
    required IconData icon,
    required String modeValue,
    required Color activeColor,
  }) {
    final state = widget.state;
    final isSelected = state.activeMode == modeValue;
    final isDark = state.isDarkMode;

    return GestureDetector(
      onTap: () {
        setState(() {
          state.setActiveMode(modeValue);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? activeColor.withValues(alpha: 0.12) 
              : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? activeColor.withValues(alpha: 0.5) 
                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : state.secondaryTextColor,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? state.primaryTextColor : state.secondaryTextColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSettingsPanel() {
    final state = widget.state;
    final isDark = state.isDarkMode;
    final activeMode = state.activeMode;
    
    Widget statusBanner;
    if (activeMode == 'normal') {
      statusBanner = Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '当前激活：基础运动模式 (极低能耗，仅日常轨迹与基础配速计算)',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 11),
              ),
            ),
          ],
        ),
      );
    } else if (activeMode == 'campus') {
      statusBanner = Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF00E6FF).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF00E6FF).withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.school_rounded, size: 16, color: Color(0xFF00E6FF)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '当前激活：校园阳光跑模式 (反作弊代跑与定位打卡功能就绪)',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 11),
              ),
            ),
          ],
        ),
      );
    } else {
      statusBanner = Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.health_and_safety_rounded, size: 16, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '当前激活：社区健康监测模式 (跌倒昏厥求救与HIS直连接通)',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 11),
              ),
            ),
          ],
        ),
      );
    }

    final isCampusActive = activeMode == 'campus';
    final isCommunityActive = activeMode == 'community';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        statusBanner,
        if (isCampusActive)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00E6FF).withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00E6FF).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_rounded, size: 16, color: Color(0xFF00E6FF)),
                        const SizedBox(width: 8),
                        Text(
                          '校园服务配置',
                          style: TextStyle(
                            color: state.primaryTextColor, 
                            fontSize: 12, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E6FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '当前激活',
                        style: TextStyle(color: Color(0xFF00E6FF), fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: schoolCtrl,
                  style: TextStyle(color: state.primaryTextColor, fontSize: 12),
                  decoration: InputDecoration(
                    labelText: '认证高校名称',
                    labelStyle: TextStyle(color: state.secondaryTextColor, fontSize: 10),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    state.schoolName = val;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: studentCtrl,
                  style: TextStyle(color: state.primaryTextColor, fontSize: 12),
                  decoration: InputDecoration(
                    labelText: '认证学号',
                    labelStyle: TextStyle(color: state.secondaryTextColor, fontSize: 10),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    state.studentId = val;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          state.isFaceVerified ? Icons.face_retouching_natural_rounded : Icons.face_unlock_rounded,
                          color: state.isFaceVerified ? const Color(0xFF10B981) : state.secondaryTextColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.isFaceVerified ? '人脸核验通过' : '人脸核验未就绪',
                          style: TextStyle(
                            color: state.isFaceVerified ? const Color(0xFF10B981) : state.secondaryTextColor,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          state.verifyFace(true);
                        });
                        DynamicIsland.show(
                          context,
                          title: '校园阳光跑',
                          message: '人脸特征匹配成功，定位通道就绪！',
                          icon: Icons.face_retouching_natural_rounded,
                          color: const Color(0xFF00E6FF),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.isFaceVerified ? Colors.grey[850] : const Color(0xFF00E6FF),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        state.isFaceVerified ? '重新核验' : '核验打卡',
                        style: TextStyle(color: state.isFaceVerified ? Colors.white : Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '模拟防作弊警告:',
                      style: TextStyle(color: state.secondaryTextColor, fontSize: 9),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          state.toggleCampusWarning(!state.isCampusWarningActive);
                        });
                      },
                      icon: Icon(
                        state.isCampusWarningActive ? Icons.lock_open_rounded : Icons.warning_rounded,
                        size: 9,
                        color: Colors.black,
                      ),
                      label: Text(
                        state.isCampusWarningActive ? '解除风控警告' : '触发作弊警告',
                        style: const TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (isCommunityActive)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.health_and_safety_rounded, size: 16, color: Color(0xFF8B5CF6)),
                        const SizedBox(width: 8),
                        Text(
                          '社区康养配置',
                          style: TextStyle(
                            color: state.primaryTextColor, 
                            fontSize: 12, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '当前激活',
                        style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: clinicCtrl,
                  style: TextStyle(color: state.primaryTextColor, fontSize: 12),
                  decoration: InputDecoration(
                    labelText: '定点社区 HIS 卫生中心',
                    labelStyle: TextStyle(color: state.secondaryTextColor, fontSize: 10),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    state.assignedClinic = val;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: residentCtrl,
                  style: TextStyle(color: state.primaryTextColor, fontSize: 12),
                  decoration: InputDecoration(
                    labelText: '居民健康档案身份证号',
                    labelStyle: TextStyle(color: state.secondaryTextColor, fontSize: 10),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    state.residentId = val;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emergencyCtrl,
                  style: TextStyle(color: state.primaryTextColor, fontSize: 12),
                  decoration: InputDecoration(
                    labelText: '健康紧急联系人电话',
                    labelStyle: TextStyle(color: state.secondaryTextColor, fontSize: 10),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    state.emergencyContact = val;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          state.isClinicLinked ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                          color: state.isClinicLinked ? const Color(0xFF10B981) : state.secondaryTextColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.isClinicLinked ? 'HIS通道已建立' : '医疗数据未直连',
                          style: TextStyle(color: state.secondaryTextColor, fontSize: 9),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          state.toggleClinicLink();
                        });
                        DynamicIsland.show(
                          context,
                          title: '医疗端同步',
                          message: state.isClinicLinked ? '已建立社区HIS系统直连通道，体征数据将一键上传！' : '已断开医疗端同步',
                          icon: state.isClinicLinked ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                          color: const Color(0xFF8B5CF6),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.isClinicLinked ? Colors.grey[850] : const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        state.isClinicLinked ? '断开直连' : '激活直连',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  title: const Text('跌倒与昏厥自动求救', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  subtitle: const Text('智能手表端摔倒检测，联动呼叫监护人与拨打HIS热线', style: TextStyle(fontSize: 8)),
                  value: state.isSosEnabled,
                  activeThumbColor: Colors.redAccent,
                  onChanged: (val) {
                    setState(() {
                      state.toggleSosEnabled(val);
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                if (state.isSosEnabled) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '异常模拟功能:',
                        style: TextStyle(color: state.secondaryTextColor, fontSize: 9),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          state.simulateFaintEvent(context);
                        },
                        icon: const Icon(Icons.warning_amber_rounded, size: 10, color: Colors.white),
                        label: const Text('模拟跌倒昏厥', style: TextStyle(fontSize: 8, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        if (activeMode == 'normal')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Text(
              '当前已调至基础运动模式运行。在此状态下系统以极低能耗运行，仅自动监测并绘制日常轨迹、计算基础速度/卡路里及配速，无后台AI监督。您可在上方随时开启校园阳光跑或社区康养模块进行数据互通与智能防护。',
              style: TextStyle(color: state.secondaryTextColor, fontSize: 11, height: 1.5),
            ),
          ),
      ],
    );
  }
}

class MainBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Color activeGlowColor;
  final AppState state;
  final bool isDark;
  final ValueChanged<int> onTap;

  const MainBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.activeGlowColor,
    required this.state,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<MainBottomNavigationBar> createState() => _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> with WidgetsBindingObserver {
  bool _hasKeyboard = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _checkKeyboardStatus();
  }

  void _checkKeyboardStatus() {
    if (WidgetsBinding.instance.platformDispatcher.views.isEmpty) return;
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final bottomInset = view.viewInsets.bottom;
    final devicePixelRatio = view.devicePixelRatio;
    final keyboardHeight = bottomInset / devicePixelRatio;
    final newHasKeyboard = keyboardHeight > 10.0;
    if (_hasKeyboard != newHasKeyboard) {
      setState(() {
        _hasKeyboard = newHasKeyboard;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasKeyboard) {
      return const SizedBox.shrink();
    }

    final isDark = widget.isDark;
    final activeGlowColor = widget.activeGlowColor;

    return Container(
      margin: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 20.0),
      height: 64,
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF131524) : Colors.white).withValues(alpha: isDark ? 0.85 : 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: activeGlowColor.withValues(alpha: isDark ? 0.25 : 0.4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: activeGlowColor.withValues(alpha: isDark ? 0.06 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.grid_view_rounded, '健康监测'),
            _buildNavItem(1, Icons.chat_bubble_outline_rounded, 'AI陪伴'),
            _buildNavItem(2, Icons.directions_run_rounded, '运动打卡'),
            _buildNavItem(3, Icons.analytics_outlined, '健康报表'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = widget.currentIndex == index;
    final isDark = widget.isDark;
    final activeGlowColor = widget.activeGlowColor;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? activeGlowColor.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? activeGlowColor : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                size: 20,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? (isDark ? Colors.white : const Color(0xFF1E293B)) 
                    : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                fontSize: 9.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SafePadding extends StatelessWidget {
  final Widget child;
  const SafePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.only(
        top: padding.top,
        left: padding.left,
        right: padding.right,
      ),
      child: child,
    );
  }
}
