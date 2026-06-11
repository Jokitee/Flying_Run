# API_Config 配置文档

> **版本**: v1.0.0  
> **更新日期**: 2026-06-07  
> **适用端**: iOS / Android / Web  
> **文档用途**: 定义所有第三方服务接入规范，统一接口管理、错误处理与数据格式标准

---

## 目录
1. [架构说明](#1-架构说明)
    - [1.1 设计原则](#11-设计原则)
    - [1.2 文件位置](#12-文件位置)
    - [1.3 基础配置模板](#13-基础配置模板)
    - [1.4 错误处理规范](#14-错误处理规范)
    - [1.5 数据适配器 (Adapter) 标准](#15-数据适配器-adapter-标准)

---

## 1. 架构说明

### 1.1 设计原则
- **配置驱动**: 所有第三方 API 通过 `ApiConfig` 文件集中注册，禁止在业务代码中硬编码接口地址
- **统一封装**: 底层 HTTP 客户端统一处理鉴权、超时、重试、日志
- **插件化接入**: 新增数据源仅需修改配置文件，零业务代码侵入

### 1.2 文件位置
- lib/
- ├── config/
- │   └── api_config.dart          # 主配置文件
- ├── services/
- │   ├── http_client.dart         # 统一请求封装
- │   └── adapters/                # 各平台数据适配器
- │       ├── health_adapter.dart
- │       └── ...

---

### 1.3 基础配置模板
```dart
// lib/config/api_config.dart
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

  // 环境切换
  static const String currentEnv = 'production'; // development | staging | production
  
  static String get baseUrl {
    switch (currentEnv) {
      case 'development': return 'https://dev-api.flyingrun.com';
      case 'staging': return 'https://staging-api.flyingrun.com';
      case 'production': default: return 'https://api.flyingrun.com';
    }
  }

  // 服务路由注册表
  static const String aiGenerateReply = '/api/v1/ai/reply';
  static const String syncHealthData = '/api/v1/health/sync';
}
```

---

### 1.4 错误处理规范
所有的 API 响应统一由底层的 `HttpClient` 进行拦截。应用中抛出的错误应包装为统一的 `ApiException` 类：

1. **200-299**: 请求成功，提取 `data` 字段。
2. **401**: Token 验证失败，清除本地密钥，自动弹回登录页。
3. **403**: 无权限操作（如未绑定校园账号）。
4. **404/500+**: 网络或服务器故障，触发全局 Toast/灵动岛提示。
5. **Timeout**: 超时自动重试，失败则报网络异常。

---

### 1.5 数据适配器 (Adapter) 标准
由于第三方硬件（如苹果 HealthKit、华为运动健康、小米手环）返回的运动数据格式各异，需要在请求之后进行一次 Adapter 转换，再转为 AppState 中定义的数据模型。

**示例转换逻辑**：
```dart
// 统一接收的标准化数据模型
class StandardHealthData {
  final int heartRate;
  final int steps;
  final double sleepHours;

  StandardHealthData({required this.heartRate, required this.steps, required this.sleepHours});
}

```

---

### 1.6 接入指南 (如何配置你的后端)
如果你打算克隆此前端作为你的 App，你需要做以下三步来连通你的服务器：

1. **修改域名常量**：
   打开 `lib/config/api_config.dart`，修改 `baseUrl` 下的域名为你自己的后端域名（例如 `https://api.your-school.edu.cn`）。
2. **对接鉴权体系**：
   后端必须在登录接口（`login` 或 `campusAuth`）中返回 `Token`。前端的 `token_manager.dart` 会自动加密存入本地，且后期的每一次网络请求（通过 `http_client.dart`）都会自动在 Request Header 中带上 `Authorization: Bearer <Token>`，你的后端需要据此验证用户身份。
3. **数据格式清洗 (Adapter)**：
   如果你接入了第三方的设备（如某品牌智能手环），其返回的 JSON 字段通常是乱七八糟的（例如心率字段叫 `hr_val` 而不是 `heartRate`）。**绝对不要**在页面 UI 层去修改这些判断。你应该在 `lib/services/adapters/` 目录下新建一个类继承 `HealthDataAdapter`，在里面完成字段的转化清洗，然后再喂给 `AppState`。


