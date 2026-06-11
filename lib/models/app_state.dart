import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/dynamic_island.dart';
import '../services/token_manager.dart';

class Message {
  final String sender; // 'user' or 'ai'
  final String text;
  final DateTime timestamp;
  final String? audioWaveform; // For representing audio messages

  Message({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.audioWaveform,
  });
}

class Coach {
  final String id;
  final String name;
  final String title;
  final String description;
  final String toneDescription;
  final String avatarUrl;
  final Color themeColor;
  final List<String> greetingPhrases;

  Coach({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.toneDescription,
    required this.avatarUrl,
    required this.themeColor,
    required this.greetingPhrases,
  });
}

class CheckInTask {
  final String id;
  final String title;
  final double targetValue;
  double currentValue;
  final String unit;
  bool isCompleted;
  final IconData icon;
  final Color color;

  CheckInTask({
    required this.id,
    required this.title,
    required this.targetValue,
    this.currentValue = 0.0,
    required this.unit,
    this.isCompleted = false,
    required this.icon,
    required this.color,
  });

  double get percent => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
}

class AppState extends ChangeNotifier {
  // --- Coaches & Chat ---
  final List<Coach> coaches = [
    Coach(
      id: 'spark',
      name: '星火 (Coach Spark)',
      title: '元气热血教练',
      description: '充满激情，声音清亮富有感染力。擅长高强度耐力激发和长跑节奏带动。',
      toneDescription: '阳光开朗、充满激情、极具感召力',
      avatarUrl: '⚡',
      themeColor: const Color(0xFFFF6B00),
      greetingPhrases: [
        '嘿！今天也是活力满满的一天，准备好去操场挥洒汗水了吗？',
        '脚步别停！感受心跳的律动，有我陪着你，你就是最棒的跑者！',
        '今天的阳光刚刚好，正适合来一场痛快的流汗跑，加油！',
      ],
    ),
    Coach(
      id: 'lynn',
      name: '林静 (Coach Lynn)',
      title: '温柔疗愈伴跑员',
      description: '声音轻柔舒缓，极具共情力。专注于心率管理、跑后拉伸与睡眠康复建议。',
      toneDescription: '温柔克制、温暖共情、春风拂面',
      avatarUrl: '🌸',
      themeColor: const Color(0xFF10B981),
      greetingPhrases: [
        '你好，今天感觉怎么样？如果有些疲惫，我们可以先从慢走开始。',
        '运动是倾听自己身体的过程。别担心速度，保持深呼吸，我们一起慢慢来。',
        '跑完了吗？辛苦啦，来听着我的声音，我们做一下跑后拉伸，放松紧绷的肌肉。',
      ],
    ),
    Coach(
      id: 'rex',
      name: '雷克 (Coach Rex)',
      title: '硬核铁血教官',
      description: '沉稳雄浑，指令简洁有力。硬核督促，专治拖延，适合需要严格自律打卡的用户。',
      toneDescription: '沉稳有力、严厉刚健、执行力强',
      avatarUrl: '🛡️',
      themeColor: const Color(0xFF8B5CF6),
      greetingPhrases: [
        '不要给懒惰找借口。换上跑鞋，立刻出发！',
        '目标是5公里，一米也不能少。跟上节奏，调整呼吸，别让我看到你松懈！',
        '今天的任务完成了没有？没有完成就不要谈休息。执行力是跑者的第一品质！',
      ],
    ),
  ];

  late String selectedCoachId;
  List<Message> chatMessages = [];
  bool isAiTyping = false;

  // Local deployed parameters for simulated TTS model
  double voicePitch = 1.0;
  double voiceSpeed = 1.0;
  double voiceEnergy = 1.0;
  bool _localVoiceDeployment = true;
  bool get localVoiceDeployment => _localVoiceDeployment;
  set localVoiceDeployment(bool val) {
    if (_localVoiceDeployment != val) {
      _localVoiceDeployment = val;
      notifyListeners();
    }
  }

  void refreshUI() {
    notifyListeners();
  }

  final FlutterTts _flutterTts = FlutterTts();
  double _appliedPitch = -1.0;
  double _appliedSpeed = -1.0;
  double _appliedEnergy = -1.0;
  bool _isLanguageSet = false;

  Future<void> speak(String text) async {
    if (!localVoiceDeployment) return;
    try {
      if (voicePitch != _appliedPitch) {
        await _flutterTts.setPitch(voicePitch);
        _appliedPitch = voicePitch;
      }
      if (voiceSpeed != _appliedSpeed) {
        await _flutterTts.setSpeechRate(voiceSpeed * 0.45);
        _appliedSpeed = voiceSpeed;
      }
      if (voiceEnergy != _appliedEnergy) {
        await _flutterTts.setVolume(voiceEnergy);
        _appliedEnergy = voiceEnergy;
      }
      if (!_isLanguageSet) {
        bool isZhCnAvailable = false;
        try {
          isZhCnAvailable = await _flutterTts.isLanguageAvailable("zh-CN");
        } catch (_) {}
        if (isZhCnAvailable) {
          await _flutterTts.setLanguage("zh-CN");
        } else {
          await _flutterTts.setLanguage("zh");
        }
        _isLanguageSet = true;
      }
      
      // Clean up text format (remove prefix indicators like [AI播报 - Lynn])
      String cleanText = text.replaceAll(RegExp(r'\[AI播报\s*-\s*[^\]]+\]:'), '');
      
      // Stop and speak asynchronously in a non-awaiting way
      _flutterTts.stop().then((_) {
        _flutterTts.speak(cleanText);
      });
    } catch (e) {
      debugPrint("TTS error: $e");
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint("TTS stop error: $e");
    }
  }

  // --- Running Track State ---
  bool isTracking = false;
  double runDistanceKm = 0.0;
  int runDurationSeconds = 0;
  double runPaceMinPerKm = 0.0;
  int runCalories = 0;
  Timer? _runTimer;
  List<Offset> runRoutePoints = [];
  List<String> aiAudioTranscripts = [];
  double currentSpeedKmh = 0.0;

  // --- Devices & Integration ---
  Map<String, bool> connectedDevices = {
    'Huawei': true,
    'Xiaomi': false,
    'Apple': false,
    'Garmin': false,
  };
  bool isSyncing = false;
  String activeMode = 'normal'; // 'normal', 'campus', or 'community'

  // --- Campus / Sunshine Run ---
  bool isCampusEnabled = false;
  bool isFaceVerified = false;
  String studentId = "2024100932";
  String schoolName = "南方智慧理工大学";
  int sunshineRunTarget = 120; // total km target for semester
  double sunshineRunDone = 78.5;

  // --- Community Health & Care ---
  bool isCommunityEnabled = false;
  bool isClinicLinked = false;
  String residentId = "44010619550215XXXX";
  String assignedClinic = "沙河社区卫生服务中心";
  String emergencyContact = "138-0000-1111";

  // --- Smart Elastic Check-in Rules ---
  bool ruleRainyDay = false;
  bool ruleLateSleep = false;
  bool ruleOvertime = false;

  // --- Login & Warnings ---
  bool isLoggedIn = false;
  String? _savedUsername;
  String? get savedUsername => _savedUsername;
  bool isCampusWarningActive = false;

  // List of tasks
  List<CheckInTask> tasks = [];

  // --- Health Vitals (Simulated Real-time Data) ---
  int heartRate = 72;
  int bloodOxygen = 98;
  double sleepHours = 7.5;
  int dailySteps = 4230;
  int stressLevel = 45;
  Timer? _vitalsTimer;
  List<int> heartRateHistory = List.generate(30, (_) => 70 + Random().nextInt(15));

  // --- Day / Night Theme Mode ---
  final ValueNotifier<double> simulatedHourNotifier = ValueNotifier<double>(12.0);
  bool _useSystemTime = true;
  Timer? _timeTimer;

  // Anchor background gradients for light/dark transitions
  // Peak Sunrise / Dawn (6:00)
  static const Color dawnColor1 = Color(0xFFFFECE0);
  static const Color dawnColor2 = Color(0xFFD4E6F1);

  // Peak Noon / Daylight (12:00)
  static const Color noonColor1 = Color(0xFFE0F2FE);
  static const Color noonColor2 = Color(0xFFF0F9FF);

  // Peak Sunset (18:00)
  static const Color sunsetColor1 = Color(0xFFFF9E7D);
  static const Color sunsetColor2 = Color(0xFF4A2574);

  // Peak Midnight / Night (0:00 / 24:00)
  static const Color nightColor1 = Color(0xFF0F172A);
  static const Color nightColor2 = Color(0xFF020617);

  double get simulatedHour => simulatedHourNotifier.value;
  bool get useSystemTime => _useSystemTime;

  bool _calculateDarkModeForHour(double t) {
    Color bg1;
    if (t >= 0.0 && t < 6.0) {
      double fraction = t / 6.0;
      bg1 = Color.lerp(nightColor1, dawnColor1, fraction) ?? nightColor1;
    } else if (t >= 6.0 && t < 12.0) {
      double fraction = (t - 6.0) / 6.0;
      bg1 = Color.lerp(dawnColor1, noonColor1, fraction) ?? dawnColor1;
    } else if (t >= 12.0 && t < 18.0) {
      double fraction = (t - 12.0) / 6.0;
      bg1 = Color.lerp(noonColor1, sunsetColor1, fraction) ?? noonColor1;
    } else {
      double fraction = (t - 18.0) / 6.0;
      bg1 = Color.lerp(sunsetColor1, nightColor1, fraction) ?? sunsetColor1;
    }
    return bg1.computeLuminance() < 0.45;
  }

  bool get isDarkMode => _calculateDarkModeForHour(simulatedHourNotifier.value);

  set simulatedHour(double value) {
    double oldVal = simulatedHourNotifier.value;
    double newVal = value.clamp(0.0, 24.0);
    
    bool oldDarkMode = _calculateDarkModeForHour(oldVal);
    bool newDarkMode = _calculateDarkModeForHour(newVal);
    
    simulatedHourNotifier.value = newVal;
    
    if (oldDarkMode != newDarkMode) {
      notifyListeners();
    }
  }

  set useSystemTime(bool val) {
    _useSystemTime = val;
    if (_useSystemTime) {
      _syncToSystemTime();
    }
    notifyListeners();
  }

  void _syncToSystemTime() {
    final now = DateTime.now();
    simulatedHour = now.hour + now.minute / 60.0 + now.second / 3600.0;
  }

  void updateThemeMode() {
    if (_useSystemTime) {
      _syncToSystemTime();
    }
  }

  void toggleThemeMode() {
    _useSystemTime = false;
    if (isDarkMode) {
      simulatedHour = 12.0; // noon
    } else {
      simulatedHour = 0.0; // midnight
    }
  }

  // Theme Color Getters
  Color get backgroundColor1 {
    double t = simulatedHourNotifier.value;
    if (t >= 0.0 && t < 6.0) {
      double fraction = t / 6.0;
      return Color.lerp(nightColor1, dawnColor1, fraction) ?? nightColor1;
    } else if (t >= 6.0 && t < 12.0) {
      double fraction = (t - 6.0) / 6.0;
      return Color.lerp(dawnColor1, noonColor1, fraction) ?? dawnColor1;
    } else if (t >= 12.0 && t < 18.0) {
      double fraction = (t - 12.0) / 6.0;
      return Color.lerp(noonColor1, sunsetColor1, fraction) ?? noonColor1;
    } else {
      double fraction = (t - 18.0) / 6.0;
      return Color.lerp(sunsetColor1, nightColor1, fraction) ?? sunsetColor1;
    }
  }

  Color get backgroundColor2 {
    double t = simulatedHourNotifier.value;
    if (t >= 0.0 && t < 6.0) {
      double fraction = t / 6.0;
      return Color.lerp(nightColor2, dawnColor2, fraction) ?? nightColor2;
    } else if (t >= 6.0 && t < 12.0) {
      double fraction = (t - 6.0) / 6.0;
      return Color.lerp(dawnColor2, noonColor2, fraction) ?? dawnColor2;
    } else if (t >= 12.0 && t < 18.0) {
      double fraction = (t - 12.0) / 6.0;
      return Color.lerp(noonColor2, sunsetColor2, fraction) ?? noonColor2;
    } else {
      double fraction = (t - 18.0) / 6.0;
      return Color.lerp(sunsetColor2, nightColor2, fraction) ?? sunsetColor2;
    }
  }

  Color get cardBgColor => isDarkMode ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.72);
  Color get cardBorderColor => isDarkMode ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);
  Color get primaryTextColor => isDarkMode ? Colors.white : const Color(0xFF1E293B);
  Color get secondaryTextColor => isDarkMode ? Colors.white60 : const Color(0xFF64748B);
  Color get hintTextColor => isDarkMode ? Colors.white38 : const Color(0xFF94A3B8);
  Color get activeSwitchColor => isDarkMode ? const Color(0xFF00E6FF) : const Color(0xFF0284C7);

  AppState() {
    selectedCoachId = 'spark';
    _syncToSystemTime();
    _initializeChat();
    _initializeTasks();
    _startVitalsSimulation();
    _initTokenAsync();

    // Periodically sync time if useSystemTime is true (60s interval is sufficient for minute-level clock updates)
    _timeTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_useSystemTime) {
        _syncToSystemTime();
      }
    });
  }

  /// Check for a saved credential token on startup and auto-login if valid.
  Future<void> _initTokenAsync() async {
    final username = await TokenManager.loadToken();
    if (username != null) {
      _savedUsername = username;
      isLoggedIn = true;
      notifyListeners();
    }
  }

  Coach get currentCoach => coaches.firstWhere((c) => c.id == selectedCoachId);

  void selectCoach(String coachId) {
    selectedCoachId = coachId;
    _initializeChat();
    
    // Configure natural defaults for each coach type to reduce robotic tone:
    if (coachId == 'spark') {
      voicePitch = 1.25;  // Spark: Young, high-spirited tone
      voiceSpeed = 1.10;  // Spark: Slightly faster energetic pace
    } else if (coachId == 'lynn') {
      voicePitch = 0.95;  // Lynn: Warm, soft, gentle female tone
      voiceSpeed = 0.82;  // Lynn: Calmer, healing slow pace
    } else if (coachId == 'rex') {
      voicePitch = 0.72;  // Rex: Strict, deep baritone command tone
      voiceSpeed = 0.95;  // Rex: Standard firm pace
    }
    
    notifyListeners();
    
    // Instantly speak the greeting phrase
    speak(currentCoach.greetingPhrases[0]);
  }

  void _initializeChat() {
    chatMessages = [
      Message(
        sender: 'ai',
        text: currentCoach.greetingPhrases[0],
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  void _initializeTasks() {
    tasks = [
      CheckInTask(
        id: 'run',
        title: '每日路跑',
        targetValue: 3.0,
        currentValue: 0.0,
        unit: '公里',
        icon: Icons.directions_run_rounded,
        color: const Color(0xFFFF6B00),
      ),
      CheckInTask(
        id: 'steps',
        title: '每日步数',
        targetValue: 8000.0,
        currentValue: 4230.0,
        unit: '步',
        icon: Icons.directions_walk_rounded,
        color: const Color(0xFF10B981),
      ),
      CheckInTask(
        id: 'active_time',
        title: '中高强度运动',
        targetValue: 30.0,
        currentValue: 12.0,
        unit: '分钟',
        icon: Icons.fitness_center_rounded,
        color: const Color(0xFF00E6FF),
      ),
      CheckInTask(
        id: 'water',
        title: '日常饮水',
        targetValue: 2000.0,
        currentValue: 1200.0,
        unit: '毫升',
        icon: Icons.local_drink_rounded,
        color: Colors.blueAccent,
      ),
    ];
    _applyElasticRules();
  }

  // Elastic adjustments based on status rules
  void toggleRule(String ruleType, BuildContext context) {
    if (ruleType == 'rainy') {
      ruleRainyDay = !ruleRainyDay;
      _applyElasticRules();
      notifyListeners();
      DynamicIsland.show(
        context,
        title: '端侧本地模型推送',
        message: ruleRainyDay
            ? '外部天气异常（雨天已激活），本地AI推荐：室内有氧拉伸 15 分钟，降低运动损伤！'
            : '雨天模式已解除，本地AI推荐：恢复户外阳光慢跑打卡 3.0 公里。',
        icon: Icons.umbrella_rounded,
        color: const Color(0xFF00E6FF),
      );
    } else if (ruleType == 'sleep') {
      ruleLateSleep = !ruleLateSleep;
      _applyElasticRules();
      notifyListeners();
      DynamicIsland.show(
        context,
        title: '端侧本地模型推送',
        message: ruleLateSleep
            ? '检测到熬夜睡眠不足，弹性保护已激活。本地AI推荐：今日缩减目标，严禁剧烈无氧！'
            : '熬夜调休已解除，本地AI推荐：常规有氧慢跑 30 分钟。',
        icon: Icons.bedtime_rounded,
        color: const Color(0xFFFF6B00),
      );
    } else if (ruleType == 'overtime') {
      ruleOvertime = !ruleOvertime;
      _applyElasticRules();
      notifyListeners();
      DynamicIsland.show(
        context,
        title: '端侧本地模型推送',
        message: ruleOvertime
            ? '加班疲劳度预警生效，今日打卡难度降低 30%。本地AI推荐：轻微步行或拉伸。'
            : '加班状态已解除，本地AI推荐：进行有氧心肺跑 20 分钟恢复元气。',
        icon: Icons.work_history_rounded,
        color: const Color(0xFF8B5CF6),
      );
    }
  }

  void _applyElasticRules() {
    // Reset tasks defaults, then adjust
    double runTarget = 3.0;
    double stepsTarget = 8000.0;
    double activeTarget = 30.0;

    // Apply cumulative discounts
    double multiplier = 1.0;
    if (ruleRainyDay) {
      multiplier *= 0.6; // Rain: reduce run, shift to indoor
    }
    if (ruleLateSleep) {
      multiplier *= 0.5; // Sleep deprived: avoid high strain
    }
    if (ruleOvertime) {
      multiplier *= 0.7; // Busy workday: light workout only
    }

    // Apply to task targets
    for (var task in tasks) {
      if (task.id == 'run') {
        // Adjust run target
        task.currentValue = runDistanceKm;
        double adjusted = runTarget * multiplier;
        // If multiplier is too low, convert run target to 0 or 1km
        task.currentValue = runDistanceKm;
        // In late sleep or heavy rain, we might even replace run with stretching
        double finalTarget = double.parse(adjusted.toStringAsFixed(1));
        // Force minimum target of 1km if not 0
        if (finalTarget < 1.0 && finalTarget > 0.0) finalTarget = 1.0;
        // Update target
        // If rain + late sleep, running goal could be adjusted to 0 (optional indoor exercises instead)
        _updateTaskTarget(task, finalTarget);
      } else if (task.id == 'steps') {
        double finalTarget = (stepsTarget * (multiplier > 0.5 ? multiplier : 0.5)).roundToDouble();
        _updateTaskTarget(task, finalTarget);
      } else if (task.id == 'active_time') {
        double finalTarget = (activeTarget * (multiplier > 0.5 ? multiplier : 0.5)).roundToDouble();
        _updateTaskTarget(task, finalTarget);
      }
    }
  }

  void _updateTaskTarget(CheckInTask task, double target) {
    // Use reflection-like update
    int idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      double cur = tasks[idx].currentValue;
      IconData icon = tasks[idx].icon;
      Color color = tasks[idx].color;
      String unit = tasks[idx].unit;
      String title = tasks[idx].title;
      String actualTitle = title;
      if (ruleLateSleep && task.id == 'run') {
        actualTitle = '轻度慢跑/走 (睡眠调节)';
      } else if (ruleRainyDay && task.id == 'run') {
        actualTitle = '室内拉伸/跑 (雨天调整)';
      } else {
        actualTitle = task.id == 'run' ? '每日路跑' : title;
      }

      tasks[idx] = CheckInTask(
        id: task.id,
        title: actualTitle,
        targetValue: target,
        currentValue: cur,
        unit: unit,
        icon: icon,
        color: color,
        isCompleted: cur >= target,
      );
    }
  }

  // --- Real-time Vitals Simulation ---
  void _startVitalsSimulation() {
    _vitalsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isLoggedIn) return; // Skip background calculations and notify if not logged in
      
      if (isTracking) {
        // Heart rate goes up during exercise
        heartRate = 125 + Random().nextInt(35);
      } else {
        // Resting heart rate
        heartRate = 60 + Random().nextInt(18);
      }
      heartRateHistory.add(heartRate);
      if (heartRateHistory.length > 30) {
        heartRateHistory.removeAt(0);
      }

      // Oxygen fluctuates slightly
      if (isTracking && heartRate > 150) {
        bloodOxygen = 96 + Random().nextInt(3);
      } else {
        bloodOxygen = 98 + Random().nextInt(3);
        if (bloodOxygen > 100) bloodOxygen = 100;
      }

      // Steps tick slowly even when not tracking running
      if (!isTracking) {
        dailySteps += Random().nextInt(8); // Scaled from 4 steps/2s to 8 steps/5s
        int idx = tasks.indexWhere((t) => t.id == 'steps');
        if (idx != -1) {
          tasks[idx].currentValue = dailySteps.toDouble();
          tasks[idx].isCompleted = tasks[idx].currentValue >= tasks[idx].targetValue;
        }
      }

      notifyListeners();
    });
  }

  // --- AI Chat Logic ---
  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;

    chatMessages.add(Message(
      sender: 'user',
      text: text,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    isAiTyping = true;
    notifyListeners();

    // Mock network lag for AI response
    await Future.delayed(const Duration(milliseconds: 1500));

    String reply;
    if (isCustomVoiceEnabled && customVoiceParameterUrl.isNotEmpty) {
      reply = '[自定义克隆声线]: 收到！检测到你对伴跑口癖和声响参数已完成云端打包。今日本地AI推荐：深呼吸，继续保持这个节奏！';
    } else {
      reply = _generateAiReply(text);
    }

    chatMessages.add(Message(
      sender: 'ai',
      text: reply,
      timestamp: DateTime.now(),
      audioWaveform: localVoiceDeployment ? '0,10,25,40,15,30,60,80,45,20,5,12,38,70,55,30,10,0' : null,
    ));

    isAiTyping = false;
    notifyListeners();
    
    // Automatically synthesize and play the speech response
    speak(reply);
  }

  String _generateAiReply(String userText) {
    String text = userText.toLowerCase();
    
    if (selectedCoachId == 'spark') {
      if (text.contains('累') || text.contains('坚持不住')) {
        return '兄弟！累是正常的，说明你正在突破极限！深吸一口气，摆动双臂，大步向前迈！我一直在你身后，加油！💥';
      }
      if (text.contains('计划') || text.contains('推荐') || text.contains('怎么跑')) {
        return '太棒了！今天我推荐你来一个【热血变速跑】：先慢跑3分钟热身，然后全力冲刺1分钟，再慢跑2分钟调整，循环4组！绝对爽快，我们一起冲！🔥';
      }
      if (text.contains('天气') || text.contains('下雨')) {
        return '下雨怕什么！换上轻便衣服，我们可以在家里来一套【热血室内HIIT打卡】！高抬腿+开合跳，心率马上飙起来，干就完了！⚡';
      }
      return '收到！不管前面有多远，踏实迈出每一步！把你的呼吸调整好，我们继续冲刺！加油加油！🏃‍♂️💥';
    } else if (selectedCoachId == 'lynn') {
      if (text.contains('累') || text.contains('坚持不住')) {
        return '辛苦了。累的话就慢下来走一走吧，听听风声，把脚步放缓。运动是为了让我们更舒适，而不是为了折磨自己。深呼吸，我在陪着你。🌸';
      }
      if (text.contains('计划') || text.contains('推荐') || text.contains('怎么跑')) {
        return '对于今天，我建议进行一次【舒缓心率控制跑】。心率控制在120-135之间，慢跑20-30分钟。这有利于增强心肺功能，又不会让你的身体感到过度压力。😊';
      }
      if (text.contains('天气') || text.contains('下雨')) {
        return '外面下雨了呢。那我们就不要出门了，拉上窗帘，放一首舒缓的音乐，做一节20分钟的【全身筋膜拉伸与瑜伽】吧。这也算今天的打卡哦。🌧️🍃';
      }
      return '嗯，我听到了。感受一下你肩膀的松紧度，试着把它放下来。无论你跑得多慢，能动起来就是对身体最棒的温柔。✨';
    } else { // rex
      if (text.contains('累') || text.contains('坚持不住')) {
        return '累？累就对了！舒服是留给退缩者的。调整你的呼吸，咬紧牙关，再跑最后一公里。你的软弱只能由你自己的双脚来战胜。挺起胸膛，继续！🛡️';
      }
      if (text.contains('计划') || text.contains('推荐') || text.contains('怎么跑')) {
        return '执行计划：【3公里节奏耐力跑】。配速保持在6分钟以内，中途不准停下，严格控制步频在180。准备好就立刻点击开始，不要拖延！⏱️';
      }
      if (text.contains('天气') || text.contains('下雨')) {
        return '下雨只是懒惰的借口。如果是小雨，换上防泼水跑鞋，继续执行。如果是暴雨，在室内进行【150个开合跳+50个深蹲】代替。立刻开始！⚔️';
      }
      return '指令收到。执行过程中，保持注意力高度集中。不要东张西望，关注你的步伐和心率。完成你的既定目标！';
    }
  }

  // --- Run Tracking Controller ---
  void startRun() {
    if (isTracking) return;
    isTracking = true;
    runDistanceKm = 0.0;
    runDurationSeconds = 0;
    runPaceMinPerKm = 0.0;
    runCalories = 0;
    currentSpeedKmh = 10.0;
    runRoutePoints = [const Offset(150, 250)];
    aiAudioTranscripts = [
      '[AI播报 - ${currentCoach.name}]: 运动已开始。跟上我的呼吸，慢慢把配速提起来。'
    ];
    notifyListeners();
    speak('运动已开始。跟上我的呼吸，慢慢把配速提起来。');

    _runTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      runDurationSeconds++;
      
      // Every second, simulate incremental progress
      // 10 km/h is ~2.77 meters per second
      double currentSpeed = 9.0 + Random().nextDouble() * 2.0; // 9 to 11 km/h
      currentSpeedKmh = currentSpeed;
      double metersPerSecond = currentSpeed / 3.6;
      runDistanceKm += (metersPerSecond / 1000.0);
      
      // Calculate pace
      if (runDistanceKm > 0) {
        double totalMinutes = runDurationSeconds / 60.0;
        runPaceMinPerKm = totalMinutes / runDistanceKm;
      }
      
      // Calories
      runCalories = (runDistanceKm * 65).round(); // approx 65 kcal per km

      // Simulate route coordinates for the visualizer
      if (runDurationSeconds % 3 == 0) {
        Offset lastPoint = runRoutePoints.last;
        double angle = Random().nextDouble() * 2 * pi;
        double dist = 8.0 + Random().nextDouble() * 5.0;
        double nextX = (lastPoint.dx + cos(angle) * dist).clamp(20.0, 280.0);
        double nextY = (lastPoint.dy + sin(angle) * dist).clamp(50.0, 320.0);
        runRoutePoints.add(Offset(nextX, nextY));
      }

      // Add AI voice companion audio segments during running
      if (runDurationSeconds == 15) {
        String msg = selectedCoachId == 'spark' 
          ? '[AI播报 - 星火]: 已经跑了快100米啦！姿势很帅，步频稳住，我们非常顺利！'
          : selectedCoachId == 'lynn' 
            ? '[AI播报 - 林静]: 很好，现在的呼吸频率很舒服。如果觉得腿有点沉，可以稍微把步伐缩小。'
            : '[AI播报 - 雷克]: 第一个阶段完成。抬起你的膝盖，摆臂幅度加大，别松劲。';
        aiAudioTranscripts.insert(0, msg);
        speak(msg);
      } else if (runDurationSeconds == 45) {
        String msg = selectedCoachId == 'spark'
          ? '[AI播报 - 星火]: 跑起来！风都在为你加油！听这节奏，我们稍微加速，冲！'
          : selectedCoachId == 'lynn'
            ? '[AI播报 - 林静]: 心率保持得很好，135次/分，非常安全而且高效。继续享受这一刻吧。'
            : '[AI播报 - 雷克]: 稳住。配速不要忽快忽慢。保持步频在175以上。';
        aiAudioTranscripts.insert(0, msg);
        speak(msg);
      }

      // Sync data to the run task in the task list
      int idx = tasks.indexWhere((t) => t.id == 'run');
      if (idx != -1) {
        tasks[idx].currentValue = double.parse(runDistanceKm.toStringAsFixed(2));
        tasks[idx].isCompleted = tasks[idx].currentValue >= tasks[idx].targetValue;
      }

      notifyListeners();
    });
  }

  void pauseRun() {
    _runTimer?.cancel();
    isTracking = false;
    currentSpeedKmh = 0.0;
    notifyListeners();
  }

  void stopRun() {
    _runTimer?.cancel();
    isTracking = false;
    currentSpeedKmh = 0.0;
    
    // Add completion message
    String endMsg = '[AI播报 - ${currentCoach.name}]: 运动结束。今天共完成${runDistanceKm.toStringAsFixed(2)}公里，辛苦了！请记得进行拉伸放松。';
    aiAudioTranscripts.insert(0, endMsg);
    speak(endMsg);
    
    // Update daily steps with the running steps
    dailySteps += (runDistanceKm * 1400).round(); // ~1400 steps per km
    int stepsIdx = tasks.indexWhere((t) => t.id == 'steps');
    if (stepsIdx != -1) {
      tasks[stepsIdx].currentValue = dailySteps.toDouble();
      tasks[stepsIdx].isCompleted = tasks[stepsIdx].currentValue >= tasks[stepsIdx].targetValue;
    }

    notifyListeners();
  }

  // --- Device Sync Simulation ---
  Future<void> syncDevices(BuildContext context) async {
    isSyncing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Scan enabled health APIs to read actual steps instead of blindly accumulating
    int scannedSteps = 0;
    int scannedHeartRate = 72;
    int scannedOxygen = 98;

    if (connectedDevices['Huawei'] == true) {
      scannedSteps = 7280;
      scannedHeartRate = 74;
      scannedOxygen = 99;
    }
    if (connectedDevices['Xiaomi'] == true) {
      scannedSteps = max(scannedSteps, 8560);
      scannedHeartRate = max(scannedHeartRate, 76);
      scannedOxygen = max(scannedOxygen, 98);
    }
    if (connectedDevices['Apple'] == true) {
      scannedSteps = max(scannedSteps, 9420);
      scannedHeartRate = max(scannedHeartRate, 72);
      scannedOxygen = max(scannedOxygen, 99);
    }
    if (connectedDevices['Garmin'] == true) {
      scannedSteps = max(scannedSteps, 11050);
      scannedHeartRate = max(scannedHeartRate, 68);
      scannedOxygen = max(scannedOxygen, 99);
    }

    if (scannedSteps > 0) {
      dailySteps = scannedSteps;
      heartRate = scannedHeartRate;
      bloodOxygen = scannedOxygen;
    }

    int stepsIdx = tasks.indexWhere((t) => t.id == 'steps');
    if (stepsIdx != -1) {
      tasks[stepsIdx].currentValue = dailySteps.toDouble();
      tasks[stepsIdx].isCompleted = tasks[stepsIdx].currentValue >= tasks[stepsIdx].targetValue;
    }

    isSyncing = false;
    notifyListeners();

    // Pushed by the built-in local model
    if (context.mounted) {
      DynamicIsland.show(
        context,
        title: '端侧本地模型推送',
        message: '设备数据同步完成。本地AI已成功接入健康API并生成了今日打卡弹性调整方案！',
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFF10B981),
      );
    }
  }

  void toggleDevice(String deviceName) {
    if (connectedDevices.containsKey(deviceName)) {
      connectedDevices[deviceName] = !connectedDevices[deviceName]!;
      notifyListeners();
    }
  }

  // --- Campus Mode Setters ---
  void toggleCampusMode() {
    isCampusEnabled = !isCampusEnabled;
    if (isCampusEnabled) {
      isCommunityEnabled = false;
      activeMode = 'campus';
    } else {
      activeMode = 'normal';
    }
    notifyListeners();
  }

  void setActiveMode(String mode) {
    activeMode = mode;
    if (mode == 'normal') {
      isCampusEnabled = false;
      isCommunityEnabled = false;
    } else if (mode == 'campus') {
      isCampusEnabled = true;
      isCommunityEnabled = false;
    } else if (mode == 'community') {
      isCampusEnabled = false;
      isCommunityEnabled = true;
    }
    notifyListeners();
  }

  void verifyFace(bool success) {
    isFaceVerified = success;
    notifyListeners();
  }

  void setSchoolName(String name) {
    schoolName = name;
    notifyListeners();
  }

  void setStudentId(String id) {
    studentId = id;
    notifyListeners();
  }

  void setAssignedClinic(String clinic) {
    assignedClinic = clinic;
    notifyListeners();
  }

  void setResidentId(String id) {
    residentId = id;
    notifyListeners();
  }

  void login({String username = 'user'}) {
    isLoggedIn = true;
    _savedUsername = username;
    TokenManager.saveToken(username); // persist encrypted token
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    _savedUsername = null;
    TokenManager.clearToken(); // wipe local token
    notifyListeners();
  }

  void toggleCampusWarning(bool val) {
    isCampusWarningActive = val;
    notifyListeners();
  }

  // --- Community Mode Setters ---
  void toggleCommunityMode() {
    isCommunityEnabled = !isCommunityEnabled;
    if (isCommunityEnabled) {
      isCampusEnabled = false;
      activeMode = 'community';
    } else {
      activeMode = 'normal';
    }
    notifyListeners();
  }

  void toggleClinicLink() {
    isClinicLinked = !isClinicLinked;
    notifyListeners();
  }

  // --- Custom Voice & Tone Profiles (Cloud Training, On-device Applying) ---
  bool isCustomVoiceTraining = false;
  bool isCustomVoiceEnabled = false;
  String customVoiceParameterUrl = '';
  String? recordedVoicePath;
  List<String> uploadedDialogueImagePaths = [];

  void setRecordedVoice(String path) {
    recordedVoicePath = path;
    notifyListeners();
  }

  void addDialogueImage(String path) {
    uploadedDialogueImagePaths.add(path);
    notifyListeners();
  }

  void removeDialogueImage(int index) {
    if (index >= 0 && index < uploadedDialogueImagePaths.length) {
      uploadedDialogueImagePaths.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> submitCustomVoiceTraining(BuildContext context) async {
    if (recordedVoicePath == null) return;
    isCustomVoiceTraining = true;
    notifyListeners();

    // Simulate uploading files to OSS & cloud training queue
    await Future.delayed(const Duration(milliseconds: 1500));
    await Future.delayed(const Duration(milliseconds: 2000));

    customVoiceParameterUrl = 'https://oss.flyingrun.com/voice-profiles/user_16936_profile.json';
    isCustomVoiceEnabled = true;
    isCustomVoiceTraining = false;
    notifyListeners();

    if (context.mounted) {
      DynamicIsland.show(
        context,
        title: '自定义声线克隆成功',
        message: '专属音色与口稳参数已封装并挂载至个人账号！已自动切换为自定义声线陪伴。',
        icon: Icons.record_voice_over_rounded,
        color: const Color(0xFF10B981),
      );
    }
  }

  void toggleCustomVoice(bool enabled) {
    isCustomVoiceEnabled = enabled;
    notifyListeners();
  }

  // --- SOS Fall & Fainting Automatic Alarm System ---
  bool isSosEnabled = true;
  bool isSosCountingDown = false;
  int sosCountdownSeconds = 10;
  Timer? _sosTimer;

  void toggleSosEnabled(bool val) {
    isSosEnabled = val;
    notifyListeners();
  }

  void updateEmergencyContact(String val) {
    emergencyContact = val;
    notifyListeners();
  }

  void simulateFaintEvent(BuildContext context) {
    if (!isSosEnabled) return;
    if (isSosCountingDown) return;

    isSosCountingDown = true;
    sosCountdownSeconds = 10;
    notifyListeners();

    // Trigger local audio alert shouting via TTS right away
    speak("警告！检测到剧烈冲击与体征跌落，疑似发生身体昏厥。开始求救倒计时。");

    _sosTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sosCountdownSeconds > 1) {
        sosCountdownSeconds--;
        notifyListeners();
        // Play local shout TTS warning at intervals to avoid clipping audio & blocking thread
        if (sosCountdownSeconds % 3 == 0 || sosCountdownSeconds == 1) {
          speak("求救倒计时 $sosCountdownSeconds 秒。");
        }
      } else {
        // Countdown finished, execute emergency actions
        timer.cancel();
        _sosTimer = null;
        executeSosRescue(context);
      }
    });
  }

  void cancelSosAlert() {
    if (_sosTimer != null) {
      _sosTimer!.cancel();
      _sosTimer = null;
    }
    isSosCountingDown = false;
    notifyListeners();
    speak("警报已取消。健康防护持续进行中。");
  }

  Future<void> executeSosRescue(BuildContext context) async {
    isSosCountingDown = false;
    notifyListeners();

    // 1. Speak out loud through device speaker at high volume
    speak("有人昏厥，请帮帮我！位置在东经113度32分，北纬23度12分！");

    // 2. Display red critical warning Dynamic Island notification
    DynamicIsland.show(
      context,
      title: '🔴 跌倒昏厥紧急求救中',
      message: '已自动拨打紧急热线 120，并向监护人 $emergencyContact 发送了实时GPS定位数据！',
      icon: Icons.emergency_share_rounded,
      color: Colors.redAccent,
    );

    // 3. Simulate API call: POST /api/v1/sos/alert
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      debugPrint("POST /api/v1/sos/alert succeeded: Dispatched emergency response to current coordinates.");
    } catch (e) {
      debugPrint("SOS API call failed: $e");
    }
  }

  @override
  void dispose() {
    _runTimer?.cancel();
    _vitalsTimer?.cancel();
    _timeTimer?.cancel();
    _sosTimer?.cancel();
    super.dispose();
  }
}
