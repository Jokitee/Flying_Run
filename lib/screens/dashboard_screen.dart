import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/glowing_card.dart';
import '../widgets/heartbeat_wave.dart';
import '../widgets/progress_ring.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        // Find tasks for progress rings
        final runTask = state.tasks.firstWhere((t) => t.id == 'run', 
            orElse: () => CheckInTask(id: '', title: '', targetValue: 1.0, unit: '', icon: Icons.error, color: Colors.grey));
        final stepsTask = state.tasks.firstWhere((t) => t.id == 'steps', 
            orElse: () => CheckInTask(id: '', title: '', targetValue: 1.0, unit: '', icon: Icons.error, color: Colors.grey));
        final activeTask = state.tasks.firstWhere((t) => t.id == 'active_time', 
            orElse: () => CheckInTask(id: '', title: '', targetValue: 1.0, unit: '', icon: Icons.error, color: Colors.grey));

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildHeader(context, state),
              
              const SizedBox(height: 12.0),

              // Sun & Moon Time of Day Simulator Card
              TimeSimulatorCard(state: state),

              const SizedBox(height: 16.0),

              // Activity Ring Summary Card
              _buildActivitySummaryCard(state, stepsTask, runTask, activeTask),

              const SizedBox(height: 16.0),

              // AI Dynamic Advice Card
              _buildAiAdviceCard(state),

              const SizedBox(height: 16.0),

              // Vitals Section Title
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  '实时生命体征监测',
                  style: TextStyle(
                    color: state.primaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              // Heart Rate Widget (Full Width for ECG display)
              _buildHeartRateCard(state),

              const SizedBox(height: 8.0),

              // Blood Oxygen and Sleep Widgets (Side by Side)
              Row(
                children: [
                  Expanded(
                    child: _buildBloodOxygenCard(state),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildSleepCard(state),
                  ),
                ],
              ),

              const SizedBox(height: 20.0),

              // Wearables Connect Panel
              _buildWearablesPanel(state),

              const SizedBox(height: 100.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '你好，探索者 👋',
              style: TextStyle(
                color: state.secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              '健康与陪伴，与你同行',
              style: TextStyle(
                color: state.primaryTextColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        
        // Sync Button
        GestureDetector(
          onTap: state.isSyncing ? null : () => state.syncDevices(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E6FF), Color(0xFF10B981)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E6FF).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                state.isSyncing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.sync_rounded,
                        color: Colors.black,
                        size: 16,
                      ),
                const SizedBox(width: 6.0),
                Text(
                  state.isSyncing ? '同步中...' : '同步设备',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySummaryCard(
      AppState state, CheckInTask steps, CheckInTask run, CheckInTask active) {
    return GlowingCard(
      borderGradientColors: const [
        Color(0x22FF6B00),
        Color(0x2210B981),
      ],
      backgroundColor: state.cardBgColor,
      child: Row(
        children: [
          // Dynamic Triple Progress Rings
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Steps Ring (Outer)
                ProgressRing(
                  progress: steps.percent,
                  size: 110,
                  strokeWidth: 9,
                  gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                ),
                // Run Ring (Middle)
                ProgressRing(
                  progress: run.percent,
                  size: 88,
                  strokeWidth: 9,
                  gradientColors: const [Color(0xFFFF6B00), Color(0xFFEA580C)],
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                ),
                // Active Time Ring (Inner)
                ProgressRing(
                  progress: active.percent,
                  size: 66,
                  strokeWidth: 9,
                  gradientColors: const [Color(0xFF00E6FF), Color(0xFF0284C7)],
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: state.currentCoach.themeColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20.0),
          
          // Activity Stats Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '今日运动总览',
                  style: TextStyle(
                    color: state.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                
                // Steps Stat row
                _buildStatItemRow(
                  state: state,
                  icon: Icons.directions_walk_rounded,
                  label: '步数',
                  value: '${state.dailySteps} / ${(steps.targetValue).round()} 步',
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(height: 6.0),
                
                // Run Stat row
                _buildStatItemRow(
                  state: state,
                  icon: Icons.directions_run_rounded,
                  label: '路跑',
                  value: '${state.runDistanceKm.toStringAsFixed(2)} / ${run.targetValue.toStringAsFixed(1)} 公里',
                  color: const Color(0xFFFF6B00),
                ),
                const SizedBox(height: 6.0),
                
                // Active time row
                _buildStatItemRow(
                  state: state,
                  icon: Icons.access_time_rounded,
                  label: '中高强度',
                  value: '${active.currentValue.round()} / ${active.targetValue.round()} 分钟',
                  color: const Color(0xFF00E6FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemRow({
    required AppState state,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8.0),
        Text(
          '$label: ',
          style: TextStyle(
            color: state.secondaryTextColor,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: state.primaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAiAdviceCard(AppState state) {
    return GlowingCard(
      borderGradientColors: [
        state.currentCoach.themeColor.withValues(alpha: 0.3),
        state.currentCoach.themeColor.withValues(alpha: 0.1),
      ],
      backgroundColor: state.currentCoach.themeColor.withValues(alpha: 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: state.currentCoach.themeColor.withValues(alpha: 0.15),
            radius: 22,
            child: Text(
              state.currentCoach.avatarUrl,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      state.currentCoach.name,
                      style: TextStyle(
                        color: state.primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: state.currentCoach.themeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'AI陪伴建议',
                        style: TextStyle(
                          color: state.currentCoach.themeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  _getAdaptiveAdvice(state),
                  style: TextStyle(
                    color: state.secondaryTextColor,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAdaptiveAdvice(AppState state) {
    if (state.ruleLateSleep) {
      return '检测到你昨晚睡眠不足，且开启了睡眠弹性保护规则。我已经为你自动缩减了今日运动目标。建议选择温和的拉伸或低强度散步，严禁进行高心率无氧训练。多喝水，注意休息！';
    }
    if (state.ruleRainyDay) {
      return '外面下雨啦，天气限制已触发。我已自动帮你将户外路跑转为室内拉伸/跑，并且下调了跑步目标。你可以随时在客厅进行室内徒手运动，我在一旁为你计时打卡！';
    }
    if (state.heartRate > 140) {
      return '当前运动心率偏高（${state.heartRate}次/分）。请适当放慢步伐，保持步伐和呼吸同步。如果感到胸闷，立即停下休息！';
    }
    
    // Normal advice based on coaches
    if (state.selectedCoachId == 'spark') {
      return '今天你的体征状态处于优秀评级！心率与血氧完美适配。正是去操场拉长跑的最佳时机！带上你的热情，现在就换上鞋，我们去刷公里数！加油！⚡';
    } else if (state.selectedCoachId == 'lynn') {
      return '身体情况非常稳定，适合进行平稳的慢跑或全身太极/瑜伽。将心率控制在有氧区间，配合深呼吸，你会感到身心前所未有的舒缓。🍃';
    } else {
      return '设备显示各项指标就绪。今日路跑任务随时可以执行，请确保在跑前进行3分钟核心关节活动，切忌偷懒，严格执行步频控制！🛡️';
    }
  }

  Widget _buildHeartRateCard(AppState state) {
    bool isExercising = state.isTracking;

    return GlowingCard(
      borderGradientColors: const [
        Color(0x33FF2A5F),
        Color(0x11FF2A5F),
      ],
      backgroundColor: state.cardBgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  RepaintBoundary(
                    child: PulsingHeart(heartRate: state.heartRate),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '心率监测',
                    style: TextStyle(
                      color: state.primaryTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isExercising) ...[
                    const SizedBox(width: 10.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2A5F).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '路跑中',
                        style: TextStyle(
                          color: Color(0xFFFF2A5F),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${state.heartRate}',
                    style: TextStyle(
                      color: state.primaryTextColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 2.0),
                  Text(
                    '次/分',
                    style: TextStyle(
                      color: state.secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12.0),
          
          // Live Heartbeat Wave custom painted widget
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: RepaintBoundary(
              child: HeartbeatWave(
                heartRate: state.heartRate,
                color: const Color(0xFFFF2A5F),
                height: 70.0,
              ),
            ),
          ),
          
          const SizedBox(height: 8.0),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '静息心率: 64 | 最高: 168',
                style: TextStyle(
                  color: state.secondaryTextColor,
                  fontSize: 10,
                ),
              ),
              Text(
                state.heartRate > 120 ? '有氧燃脂区间' : '心率状态平稳',
                style: TextStyle(
                  color: state.heartRate > 120 ? const Color(0xFFFF6B00) : const Color(0xFF10B981),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBloodOxygenCard(AppState state) {
    return GlowingCard(
      borderGradientColors: const [
        Color(0x3300E6FF),
        Color(0x1100E6FF),
      ],
      backgroundColor: state.cardBgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.opacity_rounded,
                color: const Color(0xFF00E6FF),
                size: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${state.bloodOxygen}',
                    style: TextStyle(
                      color: state.primaryTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '%',
                    style: TextStyle(
                      color: state.secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            '血氧饱和度',
            style: TextStyle(
              color: state.primaryTextColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            state.bloodOxygen >= 95 ? '血氧浓度正常' : '建议深呼吸',
            style: TextStyle(
              color: state.bloodOxygen >= 95 ? const Color(0xFF10B981) : Colors.orangeAccent,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard(AppState state) {
    return GlowingCard(
      borderGradientColors: const [
        Color(0x338B5CF6),
        Color(0x118B5CF6),
      ],
      backgroundColor: state.cardBgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.mode_night_rounded,
                color: Color(0xFF8B5CF6),
                size: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${state.sleepHours}',
                    style: TextStyle(
                      color: state.primaryTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '小时',
                    style: TextStyle(
                      color: state.secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            '昨晚睡眠时长',
            style: TextStyle(
              color: state.primaryTextColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            state.ruleLateSleep ? '睡眠较浅/偏短' : '深度睡眠充足',
            style: TextStyle(
              color: state.ruleLateSleep ? Colors.orangeAccent : const Color(0xFF10B981),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWearablesPanel(AppState state) {
    return GlowingCard(
      borderGradientColors: const [
        Colors.white12,
        Colors.white12,
      ],
      backgroundColor: state.cardBgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.watch_rounded,
                    color: state.secondaryTextColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '跨品牌智能手环绑定',
                    style: TextStyle(
                      color: state.primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: state.isDarkMode ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '开放互联 v2.6',
                  style: TextStyle(
                    color: state.secondaryTextColor,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          
          // Row of device switches
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: state.connectedDevices.keys.map((device) {
              bool isConnected = state.connectedDevices[device]!;
              return Column(
                children: [
                  GestureDetector(
                    onTap: () => state.toggleDevice(device),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isConnected 
                                ? const Color(0xFF10B981).withValues(alpha: 0.15) 
                                : (state.isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isConnected 
                                  ? const Color(0xFF10B981).withValues(alpha: 0.4) 
                                  : (state.isDarkMode ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              device[0], // First letter representation
                              style: TextStyle(
                                color: isConnected ? const Color(0xFF10B981) : (state.isDarkMode ? Colors.white24 : Colors.black26),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (isConnected)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(color: state.backgroundColor1, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    device,
                    style: TextStyle(
                      color: isConnected ? (state.isDarkMode ? Colors.white70 : Colors.black87) : (state.isDarkMode ? Colors.white24 : Colors.black26),
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class TimeSimulatorCard extends StatelessWidget {
  final AppState state;
  const TimeSimulatorCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: state.simulatedHourNotifier,
      builder: (context, hourVal, child) {
        int hour = hourVal.floor();
        int minute = ((hourVal - hour) * 60).round();
        String timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

        // Show dynamic text description based on time
        String timeDesc = '';
        IconData timeIcon = Icons.wb_sunny_rounded;
        Color timeColor = const Color(0xFFFF9E7D);
        if (hourVal >= 5.0 && hourVal < 8.0) {
          timeDesc = '🌅 清晨曙光：背景呈柔粉微蓝，开启元气晨跑。';
          timeIcon = Icons.wb_twilight_rounded;
          timeColor = const Color(0xFFFFB085);
        } else if (hourVal >= 8.0 && hourVal < 16.0) {
          timeDesc = '☀️ 烈日正午：背景呈明亮天蓝，适合日常健康打卡。';
          timeIcon = Icons.wb_sunny_rounded;
          timeColor = const Color(0xFFFFD700);
        } else if (hourVal >= 16.0 && hourVal < 19.0) {
          timeDesc = '🌇 黄昏日落：背景呈暖金紫红，惬意暮色伴跑。';
          timeIcon = Icons.wb_twilight_rounded;
          timeColor = const Color(0xFFFF6B00);
        } else {
          timeDesc = '🌙 深夜霓虹：背景呈极客墨黑与暗蓝，建议安稳睡眠。';
          timeIcon = Icons.nights_stay_rounded;
          timeColor = const Color(0xFF8B5CF6);
        }

        return GlowingCard(
          borderGradientColors: [
            timeColor.withValues(alpha: 0.3),
            state.isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ],
          backgroundColor: state.cardBgColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(timeIcon, color: timeColor, size: 20),
                      const SizedBox(width: 8.0),
                      Text(
                        '光影伴跑时钟 ($timeStr)',
                        style: TextStyle(
                          color: state.primaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '自动同步系统',
                        style: TextStyle(
                          color: state.secondaryTextColor,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      SizedBox(
                        height: 24,
                        child: Switch(
                          value: state.useSystemTime,
                          activeThumbColor: timeColor,
                          onChanged: (val) {
                            state.useSystemTime = val;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                timeDesc,
                style: TextStyle(
                  color: state.secondaryTextColor,
                  fontSize: 11,
                ),
              ),
              if (!state.useSystemTime) ...[
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(Icons.nights_stay_rounded, color: Colors.indigo.shade300, size: 14),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: timeColor,
                          inactiveTrackColor: state.isDarkMode ? Colors.white10 : Colors.black12,
                          thumbColor: timeColor,
                        ),
                        child: Slider(
                          value: hourVal,
                          min: 0.0,
                          max: 24.0,
                          onChanged: (val) {
                            state.simulatedHour = val;
                          },
                        ),
                      ),
                    ),
                    Icon(Icons.wb_sunny_rounded, color: Colors.orange.shade300, size: 14),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 4.0),
                Text(
                  '已开启时间自动同步。关闭同步后，您可以拖动滑块模拟一天中的背景光影渐变。',
                  style: TextStyle(
                    color: state.secondaryTextColor.withValues(alpha: 0.6),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}


// --- Dynamic Pulsing Heart Widget ---
class PulsingHeart extends StatefulWidget {
  final int heartRate;
  const PulsingHeart({super.key, required this.heartRate});

  @override
  State<PulsingHeart> createState() => _PulsingHeartState();
}

class _PulsingHeartState extends State<PulsingHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _getDuration(),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  Duration _getDuration() {
    double beatsPerSecond = widget.heartRate / 60.0;
    double halfCycleMs = 500.0 / (beatsPerSecond > 0 ? beatsPerSecond : 1.0);
    return Duration(milliseconds: halfCycleMs.round().clamp(150, 1000));
  }

  @override
  void didUpdateWidget(covariant PulsingHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.heartRate != widget.heartRate) {
      _controller.duration = _getDuration();
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: const Icon(
        Icons.favorite_rounded,
        color: Color(0xFFFF2A5F),
        size: 20,
      ),
    );
  }
}
