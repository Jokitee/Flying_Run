/// 标准化健康数据模型
/// 无论底层厂家 (苹果/华为/校园跑API) 返回什么奇怪的 JSON 结构，
/// 最终在 App 业务层都统一使用此模型
class StandardHealthData {
  final int heartRate;
  final int steps;
  final double sleepHours;
  final double distanceKm;

  StandardHealthData({
    required this.heartRate,
    required this.steps,
    required this.sleepHours,
    required this.distanceKm,
  });
}

/// 所有第三方数据源适配器的基类接口
abstract class HealthDataAdapter {
  /// 将厂家私有的原始 JSON 转换为标准化模型
  StandardHealthData parse(Map<String, dynamic> rawJson);
}
