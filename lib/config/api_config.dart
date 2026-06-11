class ApiConfig {
  // 全局设置
  static const int timeout = 10000;            // 默认超时(ms)
  static const int retryCount = 3;             // 失败重试次数
  static const int retryDelay = 1000;          // 重试间隔(ms)
  static const bool enableLog = true;          // 是否开启请求日志
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  // 环境切换: development | staging | production
  static const String currentEnv = 'production'; 
  
  static String get baseUrl {
    switch (currentEnv) {
      case 'development': return 'https://dev-api.flyingrun.com';
      case 'staging': return 'https://staging-api.flyingrun.com';
      case 'production': default: return 'https://api.flyingrun.com';
    }
  }

  // 服务路由注册表 (API Endpoints)
  
  // --- AI 陪伴教练相关接口 ---
  static const String aiGenerateReply = '/api/v1/ai/reply';
  static const String aiAnalyzeHealth = '/api/v1/ai/analyze-health';

  // --- 健康数据与设备同步接口 ---
  static const String syncHealthData = '/api/v1/health/sync';
  static const String getReport = '/api/v1/health/report';

  // --- 用户系统 ---
  static const String login = '/api/v1/auth/login';
  static const String verifyToken = '/api/v1/auth/verify';

  // --- 校园模式专有接口 (中转与加密) ---
  static const String campusAuth = '/api/v1/campus/auth';           // 校园API统一鉴权
  static const String fetchCampusTasks = '/api/v1/campus/tasks';    // 获取校园下发的每日跑步任务(位置等)
  static const String uploadCampusRun = '/api/v1/campus/upload';    // 加密上传GPS/步数数据到校园网端

  // --- 社区康养模式专有接口 (体医融合) ---
  static const String communityEmergency = '/api/v1/community/sos';       // 老年跌倒/心率异常紧急求助
  static const String connectCustomerService = '/api/v1/community/cs';    // 呼叫社区客服/全科医生

  // --- 硬件设备接口 (智能手表/心率带) ---
  static const String smartwatchSync = '/api/v1/hardware/sync';     // 拉取手表设备数据

  // --- 消息推送系统 ---
  static const String registerPushToken = '/api/v1/push/register';  // 注册设备推送Token
  static const String fetchNotifications = '/api/v1/push/messages'; // 拉取推送通知 (跑步任务通知等)
}
