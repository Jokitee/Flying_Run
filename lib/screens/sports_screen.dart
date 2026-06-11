import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/glowing_card.dart';
import '../main.dart';

class SportsScreen extends StatefulWidget {
  const SportsScreen({super.key});

  @override
  State<SportsScreen> createState() => _SportsScreenState();
}

class _SportsScreenState extends State<SportsScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Run tracking section (Active run vs Start button)
              state.isTracking 
                  ? _buildActiveRunTracker(state)
                  : _buildStartRunDashboard(state),

              const SizedBox(height: 20.0),

              // 2. Elastic Check-in Rules Panel (弹性智能打卡)
              _buildElasticRulesPanel(state),

              const SizedBox(height: 16.0),

              // 3. Today's Dynamic Task List
              _buildTaskListHeader(state),
              _buildTaskList(state),

              const SizedBox(height: 100.0),
            ],
          ),
        );
      },
    );
  }

  // --- Active Running Dashboard ---
  Widget _buildActiveRunTracker(AppState state) {
    // Format duration mm:ss
    int mins = state.runDurationSeconds ~/ 60;
    int secs = state.runDurationSeconds % 60;
    String timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    // Format pace mm'ss"
    int paceMins = state.runPaceMinPerKm.toInt();
    int paceSecs = ((state.runPaceMinPerKm - paceMins) * 60).round();
    String paceStr = state.runDistanceKm > 0 
        ? "$paceMins'${paceSecs.toString().padLeft(2, '0')}\""
        : "--'--\"";

    return GlowingCard(
      borderGradientColors: [
        state.currentCoach.themeColor,
        state.currentCoach.themeColor.withValues(alpha: 0.3),
      ],
      backgroundColor: state.isDarkMode ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.45),
      child: Column(
        children: [
          // Header with coach indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: state.currentCoach.themeColor.withValues(alpha: 0.2),
                    radius: 14,
                    child: Text(state.currentCoach.avatarUrl, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '${state.currentCoach.name} 伴跑中',
                    style: TextStyle(color: state.secondaryTextColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Icon(
                Icons.gps_fixed_rounded,
                color: Color(0xFF10B981),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Big Distance Indicator and Speedometer dial side by side
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    state.runDistanceKm.toStringAsFixed(2),
                    style: TextStyle(
                      color: state.primaryTextColor,
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '路跑距离 (公里)',
                    style: TextStyle(color: state.secondaryTextColor, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 36.0),
              Column(
                children: [
                  SpeedometerDial(
                    paceMinPerKm: state.runPaceMinPerKm,
                    themeColor: state.currentCoach.themeColor,
                    isDarkMode: state.isDarkMode,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '配速盘 (min/km)',
                    style: TextStyle(color: state.secondaryTextColor, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Secondary Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetricItem(state, timeStr, '时长', Icons.timer_outlined),
              _buildMetricItem(state, paceStr, '平均配速', Icons.speed_outlined),
              _buildMetricItem(state, '${state.runCalories}', '千卡', Icons.local_fire_department_outlined),
            ],
          ),
          
          const SizedBox(height: 20.0),

          // Custom Painted Running Map / GPS Route Simulator
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: state.isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.015),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: state.isDarkMode ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _RoutePainter(
                  route: state.runRoutePoints,
                  themeColor: state.currentCoach.themeColor,
                  isDarkMode: state.isDarkMode,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16.0),

          // Live Speech Broadcast Log
          Container(
            padding: const EdgeInsets.all(10.0),
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: state.isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListView.builder(
              itemCount: state.aiAudioTranscripts.length,
              itemBuilder: (context, idx) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    state.aiAudioTranscripts[idx],
                    style: TextStyle(
                      color: idx == 0 ? state.currentCoach.themeColor : state.secondaryTextColor,
                      fontSize: 10,
                      fontWeight: idx == 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20.0),

          // Playback / Stop Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pause / Resume
              GestureDetector(
                onTap: () {
                  if (state.isTracking) {
                    state.pauseRun();
                  } else {
                    state.startRun();
                  }
                },
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: state.isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    state.isTracking ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: state.primaryTextColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 40.0),
              
              // Stop Workout
              GestureDetector(
                onLongPress: () {
                  state.stopRun();
                  _showSummaryDialog(context, state);
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF2A5F),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF2A5F),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stop_rounded, color: Colors.white, size: 24),
                        Text('长按结束', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(AppState state, String val, String title, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: state.secondaryTextColor.withValues(alpha: 0.5), size: 16),
        const SizedBox(height: 6.0),
        Text(
          val,
          style: TextStyle(color: state.primaryTextColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 2.0),
        Text(
          title,
          style: TextStyle(color: state.secondaryTextColor, fontSize: 9),
        ),
      ],
    );
  }

  // --- Start Running Panel ---
  Widget _buildStartRunDashboard(AppState state) {
    return Column(
      children: [
        GlowingCard(
          borderGradientColors: [
            state.isDarkMode ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
            state.isDarkMode ? Colors.white12 : Colors.black.withValues(alpha: 0.08)
          ],
          backgroundColor: state.isDarkMode ? const Color(0x0Affffff) : Colors.white.withValues(alpha: 0.4),
          child: Column(
            children: [
              // Top Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '准备运动',
                        style: TextStyle(color: state.primaryTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        '端对端加密通道已建立，定位数据不留云端',
                        style: TextStyle(color: state.secondaryTextColor, fontSize: 10),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 10),
                        SizedBox(width: 4),
                        Text('加密P2P', style: TextStyle(color: Color(0xFF10B981), fontSize: 8, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Big Start Button
              ScaleTransition(
                scale: _pulseAnimation,
                child: GestureDetector(
                  onTap: () => state.startRun(),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          state.currentCoach.themeColor,
                          state.currentCoach.themeColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: state.currentCoach.themeColor.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 38,
                          ),
                          Text(
                            '开始户外跑',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              
              Text(
                'AI陪伴教练: ${state.currentCoach.name} (${state.currentCoach.title})',
                style: TextStyle(color: state.secondaryTextColor, fontSize: 11),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8.0),

        // Warnings
        if (state.isSosCountingDown) ...[
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              painter: HazardStripesPainter(
                color: const Color(0xFF7F1D1D),
                stripeColor: const Color(0xFFEF4444).withValues(alpha: 0.35),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '⚠️ 监测到紧急昏厥！${state.sosCountdownSeconds} 秒后呼救',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => state.cancelSosAlert(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('取消紧急求救', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else if (state.isCampusWarningActive) ...[
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              painter: HazardStripesPainter(
                color: const Color(0xFF78350F),
                stripeColor: const Color(0xFFF59E0B).withValues(alpha: 0.35),
              ),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                width: double.infinity,
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '阳光跑作弊风控警报已触发：监测到疑似代跑作弊！',
                            style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => state.toggleCampusWarning(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('解除防作弊警告', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- Elastic Rules Adjuster Panel ---
  Widget _buildElasticRulesPanel(AppState state) {
    return GlowingCard(
      borderGradientColors: [
        const Color(0x3300E6FF),
        state.isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
      ],
      backgroundColor: state.isDarkMode ? const Color(0x0E0B1626) : Colors.white.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                color: Color(0xFF00E6FF),
                size: 18,
              ),
              const SizedBox(width: 8.0),
              Text(
                '弹性智能打卡规则 (AI自动调控)',
                style: TextStyle(
                  color: state.primaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E6FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '动态调节',
                  style: TextStyle(color: Color(0xFF00E6FF), fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            '根据外部天气与身体作息状态自动下调或转换打卡目标，杜绝强迫性运动伤害。',
            style: TextStyle(color: state.secondaryTextColor, fontSize: 10),
          ),
          const SizedBox(height: 14.0),
          
          // Row of quick rule toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRuleToggleItem(
                state: state,
                label: '下雨天减量',
                icon: Icons.umbrella_rounded,
                active: state.ruleRainyDay,
                activeColor: const Color(0xFF00E6FF),
                onTap: () => state.toggleRule('rainy', context),
              ),
              _buildRuleToggleItem(
                state: state,
                label: '熬夜恢复',
                icon: Icons.bedtime_rounded,
                active: state.ruleLateSleep,
                activeColor: const Color(0xFFFF6B00),
                onTap: () => state.toggleRule('sleep', context),
              ),
              _buildRuleToggleItem(
                state: state,
                label: '加班调休',
                icon: Icons.work_history_rounded,
                active: state.ruleOvertime,
                activeColor: const Color(0xFF8B5CF6),
                onTap: () => state.toggleRule('overtime', context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRuleToggleItem({
    required AppState state,
    required String label,
    required IconData icon,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? activeColor.withValues(alpha: 0.15) : (state.isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? activeColor.withValues(alpha: 0.5) : (state.isDarkMode ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: active ? activeColor : state.secondaryTextColor,
              size: 14,
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: TextStyle(
                color: active ? (state.isDarkMode ? Colors.white : Colors.black87) : state.secondaryTextColor,
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Today's Tasks List ---
  Widget _buildTaskListHeader(AppState state) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '今日打卡清单',
            style: TextStyle(color: state.primaryTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          
          Text(
            '已完成 ${state.tasks.where((t) => t.isCompleted).length} / ${state.tasks.length}',
            style: TextStyle(color: state.secondaryTextColor, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(AppState state) {
    return Column(
      children: state.tasks.map((task) {
        return GlowingCard(
          borderGradientColors: [
            task.isCompleted ? task.color.withValues(alpha: 0.4) : (state.isDarkMode ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
            state.isDarkMode ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
          ],
          backgroundColor: task.isCompleted 
              ? task.color.withValues(alpha: 0.04) 
              : (state.isDarkMode ? const Color(0x08FFFFFF) : Colors.white.withValues(alpha: 0.45)),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Left Icon Container
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: task.isCompleted ? task.color.withValues(alpha: 0.2) : (state.isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  task.icon,
                  color: task.isCompleted ? task.color : state.secondaryTextColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14.0),

              // Title and Progress Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: task.isCompleted ? (state.isDarkMode ? Colors.white : Colors.black87) : state.primaryTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: state.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    
                    // Small progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: task.percent,
                        backgroundColor: state.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(task.color),
                        minHeight: 3.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20.0),

              // Value & Checkbox
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${task.currentValue.toStringAsFixed(task.id == 'run' ? 2 : 0)} / ${task.targetValue.toStringAsFixed(task.id == 'run' ? 1 : 0)}',
                    style: TextStyle(color: state.primaryTextColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                  Text(
                    task.unit,
                    style: TextStyle(color: state.secondaryTextColor, fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(width: 10.0),
              
              Icon(
                task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: task.isCompleted ? task.color : (state.isDarkMode ? Colors.white24 : Colors.black26),
                size: 20,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showSummaryDialog(BuildContext context, AppState state) {
    int mins = state.runDurationSeconds ~/ 60;
    int secs = state.runDurationSeconds % 60;
    String timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    int paceMins = state.runPaceMinPerKm.toInt();
    int paceSecs = ((state.runPaceMinPerKm - paceMins) * 60).round();
    String paceStr = state.runDistanceKm > 0 
        ? "$paceMins'${paceSecs.toString().padLeft(2, '0')}\""
        : "--'--\"";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final coach = state.currentCoach;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Main Card Container
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.82,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF090A11).withValues(alpha: 0.96), // Premium Dynamic Island Black
                  borderRadius: BorderRadius.circular(32.0),
                  border: Border.all(
                    color: coach.themeColor,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: coach.themeColor.withValues(alpha: 0.25),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20.0, 48.0, 20.0, 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        const Text(
                          '运动圆满达成！',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          '${coach.name}教练已为您记录下这滴汗水',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        
                        // Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryStatCard(
                                state,
                                icon: Icons.directions_run_rounded,
                                label: '总里程',
                                value: state.runDistanceKm.toStringAsFixed(2),
                                unit: '公里',
                                color: coach.themeColor,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: _buildSummaryStatCard(
                                state,
                                icon: Icons.timer_outlined,
                                label: '总时长',
                                value: timeStr,
                                unit: '',
                                color: const Color(0xFF00E6FF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryStatCard(
                                state,
                                icon: Icons.speed_rounded,
                                label: '平均配速',
                                value: paceStr,
                                unit: '',
                                color: const Color(0xFFFF8A00),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: _buildSummaryStatCard(
                                state,
                                icon: Icons.local_fire_department_rounded,
                                label: '热量消耗',
                                value: state.runCalories.toString(),
                                unit: '千卡',
                                color: const Color(0xFFFF2A5F),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        
                        // Quote / Coach Comment Section
                        Container(
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: coach.themeColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: coach.themeColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coach.avatarUrl,
                                style: const TextStyle(fontSize: 26.0),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${coach.name}教练的评语：',
                                      style: TextStyle(
                                        color: coach.themeColor,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      state.selectedCoachId == 'spark'
                                          ? '太强了我的兄弟！今天这配速简直起飞！完美的步频控制，继续保持这个冲劲，明天我们再创佳绩！💥'
                                          : state.selectedCoachId == 'lynn'
                                              ? '你做得很好。今天的跑步呼吸节奏控制得很舒缓，心率也非常平稳。现在请慢走拉伸，让身体慢慢恢复平静吧。🌸'
                                              : '今日指标达成。起步稳定，配速没有忽快忽慢，体现了极佳的自律性。保持这个势头，下一阶段我们提高强度。⚔️',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 11.0,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: const BorderSide(
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  '返回',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  // Switch to reports tab (index 3)
                                  context.findAncestorStateOfType<MainShellState>()?.setIndex(3);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [coach.themeColor, coach.themeColor.withValues(alpha: 0.85)],
                                    ),
                                    borderRadius: BorderRadius.circular(18.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: coach.themeColor.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '查看完整报告',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Top Floating Medal / Trophy Icon
              Positioned(
                top: -36,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFFFD700), coach.themeColor],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF090A11),
                      width: 4.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: coach.themeColor.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryStatCard(
    AppState state, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2.0),
                Text(
                  unit,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 9,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// --- Custom Route Painter for GPS Simulation ---
class _RoutePainter extends CustomPainter {
  final List<Offset> route;
  final Color themeColor;
  final bool isDarkMode;

  _RoutePainter({required this.route, required this.themeColor, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    // Background Grid
    final gridPaint = Paint()
      ..color = isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.015)
      ..strokeWidth = 1.0;
    
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    if (route.isEmpty) return;

    // Draw route lines
    final linePaint = Paint()
      ..color = themeColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.4)
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    path.moveTo(route.first.dx, route.first.dy);
    for (int i = 1; i < route.length; i++) {
      path.lineTo(route[i].dx, route[i].dy);
    }

    // Draw Glow & Path
    if (route.length > 1) {
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, linePaint);
    }

    // Draw Start Point (Green)
    final startPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(route.first, 6.0, startPaint);
    canvas.drawCircle(route.first, 10.0, Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.3));

    // Draw Current End Point (Flashing Ring)
    if (route.length > 1) {
      final endPaint = Paint()..color = Colors.white;
      canvas.drawCircle(route.last, 4.0, endPaint);
      canvas.drawCircle(route.last, 8.0, Paint()..color = themeColor.withValues(alpha: 0.4));
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.route.length != route.length || oldDelegate.themeColor != themeColor;
  }
}

// --- Dynamic Speedometer Dial Widget ---
class SpeedometerDial extends StatelessWidget {
  final double paceMinPerKm;
  final Color themeColor;
  final bool isDarkMode;
  const SpeedometerDial({super.key, required this.paceMinPerKm, required this.themeColor, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, 50),
      painter: _SpeedometerPainter(paceMinPerKm: paceMinPerKm, themeColor: themeColor, isDarkMode: isDarkMode),
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double paceMinPerKm;
  final Color themeColor;
  final bool isDarkMode;
  _SpeedometerPainter({required this.paceMinPerKm, required this.themeColor, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height);
    final radius = (width / 2) - 5;

    // Draw the speedometer arc (from 180 degrees to 360 degrees)
    final paintArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background arc
    paintArc.color = isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);
    canvas.drawArc(rect, math.pi, math.pi, false, paintArc);

    // Calculate pace fraction: average runner pace is between 12 min/km (slow) and 4 min/km (fast).
    double paceFraction = 0.0;
    if (paceMinPerKm > 0) {
      paceFraction = (12.0 - paceMinPerKm).clamp(0.0, 8.0) / 8.0;
    }
    
    // Draw active arc
    paintArc.shader = LinearGradient(
      colors: [themeColor.withValues(alpha: 0.35), themeColor],
    ).createShader(rect);
    canvas.drawArc(rect, math.pi, math.pi * paceFraction, false, paintArc);

    // Draw needle
    final needlePaint = Paint()
      ..color = isDarkMode ? Colors.white : Colors.black87
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    // Needle angle (from pi to 2*pi)
    double angle = math.pi + (math.pi * paceFraction);
    double needleLength = radius - 6;
    double needleX = center.dx + needleLength * math.cos(angle);
    double needleY = center.dy + needleLength * math.sin(angle);
    canvas.drawLine(center, Offset(needleX, needleY), needlePaint);
    
    // Needle center pin
    final pinPaint = Paint()..color = themeColor;
    canvas.drawCircle(center, 3.5, pinPaint);
    canvas.drawCircle(center, 1.5, Paint()..color = isDarkMode ? Colors.white : Colors.black87);
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) {
    return oldDelegate.paceMinPerKm != paceMinPerKm || oldDelegate.themeColor != themeColor || oldDelegate.isDarkMode != isDarkMode;
  }
}

// --- Repeating Diagonal Hazard Warning Stripes Painter ---
class HazardStripesPainter extends CustomPainter {
  final Color color;
  final Color stripeColor;
  final double stripeWidth;

  HazardStripesPainter({
    required this.color,
    required this.stripeColor,
    this.stripeWidth = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final stripePaint = Paint()
      ..color = stripeColor
      ..style = PaintingStyle.fill;

    final double step = stripeWidth * 2.2;
    for (double x = -size.height; x < size.width; x += step) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth + size.height, size.height)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant HazardStripesPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.stripeColor != stripeColor || oldDelegate.stripeWidth != stripeWidth;
  }
}
