import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/glowing_card.dart';

class ReportsScreen extends StatefulWidget {
  final bool isActive;
  const ReportsScreen({super.key, this.isActive = false});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _reportReady = false;
  bool _isLoadingAdvice = false;
  Timer? _cryptoTimer;

  // Mock data for weekly chart
  final List<double> _weeklySteps = [7400, 9200, 4800, 11000, 6500, 8300, 4230];
  final List<double> _weeklyHr = [65, 78, 62, 85, 72, 70, 75];
  final List<String> _days = ['周一', '周二', '周三', '周四', '周五', '周六', '今日'];

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _triggerAutoLoad();
    }
  }

  @override
  void didUpdateWidget(ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _triggerAutoLoad();
    }
  }

  @override
  void dispose() {
    _cryptoTimer?.cancel();
    super.dispose();
  }

  void _triggerAutoLoad() {
    setState(() {
      _isLoadingAdvice = true;
      _reportReady = false;
    });

    _cryptoTimer?.cancel();
    _cryptoTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isLoadingAdvice = false;
          _reportReady = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        // Update today's steps in the chart
        _weeklySteps[6] = state.dailySteps.toDouble();
        _weeklyHr[6] = state.heartRate.toDouble();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Chart title and custom chart
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  '周活动趋势分析',
                  style: TextStyle(
                    color: state.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              _buildWeeklyTrendChart(state),

              const SizedBox(height: 16.0),

              // 2. AI Health Audit Report & Suggestions
              if (_isLoadingAdvice)
                _buildSkeletonLoader(state)
              else if (_reportReady)
                _buildAuditReportDetails(state)
              else
                const SizedBox.shrink(),

              const SizedBox(height: 100.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLoader(AppState state) {
    final isDark = state.isDarkMode;
    return GlowingCard(
      borderGradientColors: [
        state.currentCoach.themeColor.withValues(alpha: 0.2),
        isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
      ],
      backgroundColor: isDark ? const Color(0x0CFFFFFF) : Colors.white.withValues(alpha: 0.4),
      child: HolographicLoader(themeColor: state.currentCoach.themeColor),
    );
  }

  Widget _buildWeeklyTrendChart(AppState state) {
    return GlowingCard(
      borderGradientColors: [
        const Color(0x2200E6FF),
        state.isDarkMode ? const Color(0x228B5CF6) : Colors.black.withValues(alpha: 0.08),
      ],
      backgroundColor: state.isDarkMode ? const Color(0x1016162B) : Colors.white.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '步数 & 静息心率',
                    style: TextStyle(color: state.primaryTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    '最近7天的综合身体负荷情况',
                    style: TextStyle(color: state.secondaryTextColor, fontSize: 10),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendIndicator(state, '步数', const Color(0xFF10B981)),
                  const SizedBox(width: 12.0),
                  _buildLegendIndicator(state, '心率', const Color(0xFFFF2A5F)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Custom painted holographic chart
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _HealthChartPainter(
                steps: _weeklySteps,
                heartRates: _weeklyHr,
                days: _days,
                isDarkMode: state.isDarkMode,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(AppState state, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4.0),
        Text(
          label,
          style: TextStyle(color: state.secondaryTextColor, fontSize: 10),
        ),
      ],
    );
  }



  Widget _buildAuditReportDetails(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            '点对点加密·AI本地模型健康审计',
            style: TextStyle(color: state.primaryTextColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        GlowingCard(
          borderGradientColors: [
            const Color(0x4410B981),
            state.isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
          ],
          backgroundColor: state.isDarkMode ? const Color(0x100D281D) : const Color(0xFFE8F5E9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 16),
                      const SizedBox(width: 6.0),
                      Text(
                        'AI综合健康评估报告',
                        style: TextStyle(color: state.primaryTextColor, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    '报告单号: FR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    style: TextStyle(color: state.secondaryTextColor, fontSize: 9),
                  ),
                ],
              ),
              Divider(color: state.isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08), height: 16),

              // Vitals Breakdown Table
              _buildAuditGridItem(state, '心率状态', '平均 72 bpm', '心率变异度(HRV)处于健康阈值，有氧心肺适应能力处于良。'),
              const SizedBox(height: 10.0),
              _buildAuditGridItem(state, '睡眠质量', '昨晚 7.5 小时', state.ruleLateSleep 
                  ? '昨晚入睡较迟。深睡比例偏低（20%），体能恢复未达最佳值。今日已自动调整打卡难度。' 
                  : '深度睡眠比例达32%（优秀级）。脑疲劳彻底修复，机体肌肉元气已重组。'),
              const SizedBox(height: 10.0),
              _buildAuditGridItem(state, '呼吸血氧', '平均 98 %', '血液氧气输送充足。静态血氧处于极佳层级，红细胞运氧负荷表现平稳。'),
              const SizedBox(height: 10.0),
              _buildAuditGridItem(state, '运动负荷', '本周累计约 12.5 km', '周跑量在稳定增长区间，心肺负荷（EPOC）维持在中性平稳层，无过度劳损征兆。'),

              Divider(color: state.isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08), height: 20),

              // Medical Clinic Connection advice (for community pension)
              if (state.isCommunityEnabled && state.isClinicLinked) ...[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.healing_rounded, color: Color(0xFF8B5CF6), size: 14),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          '社区康养通告: 已成功向 [${state.assignedClinic}] 上报体征档案。医生团队评定：您的心肺适应指标为优，慢病风险平稳。',
                          style: TextStyle(color: state.isDarkMode ? Colors.white.withValues(alpha: 0.8) : Colors.black87, fontSize: 9, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
              ],

              // Final advice summary
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📢', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'AI专家综合建议: 基于您的多维度数据分析，今日运动适宜指数为 85%。${state.ruleLateSleep ? "建议避免无氧 and 剧烈间歇跑，执行轻度慢跑目标。" : "状态绝佳，可按照计划执行既定路跑。"} 饮食注意补充优质蛋白与碳水，夜间请尽量于23:00前入睡。',
                      style: TextStyle(color: state.isDarkMode ? Colors.white.withValues(alpha: 0.8) : Colors.black87, fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditGridItem(AppState state, String title, String val, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(color: state.primaryTextColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            Text(
              val,
              style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2.0),
        Text(
          desc,
          style: TextStyle(color: state.secondaryTextColor, fontSize: 9, height: 1.3),
        ),
      ],
    );
  }
}

// --- Custom Holographic Health Chart Painter ---
class _HealthChartPainter extends CustomPainter {
  final List<double> steps;
  final List<double> heartRates;
  final List<String> days;
  final bool isDarkMode;

  _HealthChartPainter({
    required this.steps,
    required this.heartRates,
    required this.days,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final paddingBottom = 20.0;
    final paddingTop = 10.0;
    final chartHeight = height - paddingBottom - paddingTop;
    
    // Left/Right paddings for axis labels
    final leftPadding = 30.0;
    final rightPadding = 35.0;
    final chartWidth = width - leftPadding - rightPadding;
    
    final numBars = steps.length;
    final spacing = chartWidth / numBars;

    // Find max steps to scale chart
    double maxSteps = 12000.0;
    for (var s in steps) {
      if (s > maxSteps) maxSteps = s;
    }

    // Paint for Grid line
    final gridPaint = Paint()
      ..color = isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    final gridLabelPaint = TextPainter(textDirection: TextDirection.ltr);

    // Draw horizontal grid lines & Y-axis labels
    int gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      double y = paddingTop + (chartHeight * i / gridLines);
      canvas.drawLine(Offset(leftPadding, y), Offset(width - rightPadding, y), gridPaint);
      
      // Left Y-Axis: Steps
      int stepVal = ((maxSteps * (gridLines - i)) / gridLines).round();
      String stepLabel = stepVal >= 1000 ? '${(stepVal / 1000).toStringAsFixed(1)}k' : '$stepVal';
      gridLabelPaint.text = TextSpan(
        text: stepLabel,
        style: TextStyle(color: isDarkMode ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.4), fontSize: 7.5, fontFamily: 'monospace'),
      );
      gridLabelPaint.layout();
      gridLabelPaint.paint(canvas, Offset(2, y - 5));

      // Right Y-Axis: Heart Rate (bpm)
      double maxHr = 100.0;
      double minHr = 50.0;
      double hrVal = maxHr - ((maxHr - minHr) * i / gridLines);
      gridLabelPaint.text = TextSpan(
        text: '${hrVal.round()} bpm',
        style: TextStyle(color: const Color(0xFFFF2A5F).withValues(alpha: 0.35), fontSize: 7.5, fontFamily: 'monospace'),
      );
      gridLabelPaint.layout();
      gridLabelPaint.paint(canvas, Offset(width - rightPadding + 4, y - 5));
    }

    // Draw Step bars (Green gradient)
    final barWidth = spacing * 0.45;

    for (int i = 0; i < numBars; i++) {
      double barHeight = (steps[i] / maxSteps) * chartHeight;
      barHeight = barHeight.clamp(5.0, chartHeight);
      
      double x = leftPadding + (i * spacing) + (spacing - barWidth) / 2;
      double y = paddingTop + chartHeight - barHeight;

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      
      final barPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF047857), Color(0xFF10B981)],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      // Draw rounded rect bar
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3.0));
      canvas.drawRRect(rrect, barPaint);

      // Draw glowing shadow under bars
      final barGlow = Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawRRect(rrect, barGlow);

      // Draw Days Labels
      gridLabelPaint.text = TextSpan(
        text: days[i],
        style: TextStyle(color: isDarkMode ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.6), fontSize: 9),
      );
      gridLabelPaint.layout();
      gridLabelPaint.paint(
        canvas,
        Offset(leftPadding + (i * spacing) + (spacing - gridLabelPaint.width) / 2, height - 12),
      );
    }

    // Draw Heart Rate line (Red neon curve overlay with Bezier control points for smooth curves)
    final hrPaint = Paint()
      ..color = const Color(0xFFFF2A5F)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final hrGlow = Paint()
      ..color = const Color(0xFFFF2A5F).withValues(alpha: 0.3)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();
    final fillPath = Path();
    
    double minHr = 50.0;
    double maxHr = 100.0;
    
    List<Offset> points = [];
    for (int i = 0; i < numBars; i++) {
      double hr = heartRates[i].clamp(50.0, 100.0);
      double percent = (hr - minHr) / (maxHr - minHr);
      double y = paddingTop + chartHeight - (percent * chartHeight);
      double x = leftPadding + (i * spacing) + spacing / 2;
      points.add(Offset(x, y));
    }

    // Bezier path rendering
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      fillPath.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPointX = p0.dx + (p1.dx - p0.dx) / 2;
        
        path.cubicTo(controlPointX, p0.dy, controlPointX, p1.dy, p1.dx, p1.dy);
        fillPath.cubicTo(controlPointX, p0.dy, controlPointX, p1.dy, p1.dx, p1.dy);
      }

      // Close the fill path to the bottom of the chart
      fillPath.lineTo(points.last.dx, paddingTop + chartHeight);
      fillPath.lineTo(points.first.dx, paddingTop + chartHeight);
      fillPath.close();

      // Draw the glowing fading mist area under the curve
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFF2A5F).withValues(alpha: 0.18),
            const Color(0xFFFF2A5F).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(leftPadding, paddingTop, width - rightPadding, paddingTop + chartHeight))
        ..style = PaintingStyle.fill;
      
      canvas.drawPath(fillPath, fillPaint);

      // Draw core lines
      canvas.drawPath(path, hrGlow);
      canvas.drawPath(path, hrPaint);
    }

    // Draw little circles on heart rate path points
    final dotPaint = Paint()..color = isDarkMode ? Colors.white : Colors.black87;
    final dotBorderPaint = Paint()
      ..color = const Color(0xFFFF2A5F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    for (var pt in points) {
      canvas.drawCircle(pt, 3.0, dotPaint);
      canvas.drawCircle(pt, 3.0, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HealthChartPainter oldDelegate) {
    return oldDelegate.isDarkMode != isDarkMode || oldDelegate.steps != steps || oldDelegate.heartRates != heartRates;
  }
}

class HolographicLoader extends StatefulWidget {
  final Color themeColor;
  const HolographicLoader({super.key, required this.themeColor});

  @override
  State<HolographicLoader> createState() => _HolographicLoaderState();
}

class _HolographicLoaderState extends State<HolographicLoader> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  int _stepIndex = 0;
  Timer? _stepTimer;
  final List<String> _loadingSteps = [
    '读取步数与里程趋势...',
    '分析心率与睡眠变异度...',
    '智能AI推荐模型匹配中...',
    '生成个性化运动诊断建议...',
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _stepTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          _stepIndex = (_stepIndex + 1) % _loadingSteps.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating neon gradient border
              RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        widget.themeColor.withValues(alpha: 0.0),
                        widget.themeColor.withValues(alpha: 0.2),
                        widget.themeColor.withValues(alpha: 0.8),
                        widget.themeColor,
                      ],
                      stops: const [0.0, 0.25, 0.75, 1.0],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF090A11),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              // Glowing center circle
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.themeColor.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: widget.themeColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: widget.themeColor,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        // Loading status text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _loadingSteps[_stepIndex],
            key: ValueKey<int>(_stepIndex),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          'AI 智慧健康助手正在分析',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
