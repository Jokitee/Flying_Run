import 'base_adapter.dart';
import '../http_client.dart';
import '../../config/api_config.dart';

/// 校园模式数据适配器与服务调用层
class CampusService {
  final HttpClient _http = HttpClient();
  
  /// 示例：调用校园鉴权接口
  Future<bool> authCampus(String studentId, String password) async {
    try {
      final data = await _http.post(
        ApiConfig.campusAuth,
        data: {
          'student_id': studentId,
          'password': password,
        },
      );
      return data['is_verified'] == true;
    } catch (e) {
      // 这里的 e 已经被 HttpClient 统一转为了 ApiException
      print('Campus Auth Failed: $e');
      return false;
    }
  }

  /// 示例：获取校园下发的阳光跑任务
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      final data = await _http.get(ApiConfig.fetchCampusTasks);
      return List<Map<String, dynamic>>.from(data['tasks'] ?? []);
    } catch (e) {
      print('Fetch tasks failed: $e');
      return [];
    }
  }
}

/// 校园返回的数据字段可能很奇葩，我们在这里进行适配转换
class CampusHealthAdapter implements HealthDataAdapter {
  @override
  StandardHealthData parse(Map<String, dynamic> rawJson) {
    // 假设校园的 JSON 格式是 {"hr_val": 120, "step_count": 3000, "sleep_time": 4.5, "run_dist": 2.1}
    return StandardHealthData(
      heartRate: rawJson['hr_val'] ?? 0,
      steps: rawJson['step_count'] ?? 0,
      sleepHours: (rawJson['sleep_time'] ?? 0).toDouble(),
      distanceKm: (rawJson['run_dist'] ?? 0).toDouble(),
    );
  }
}
