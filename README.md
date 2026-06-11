# Flying Run (AI 陪伴式运动打卡与健康数据监测系统)

![Flutter](https://img.shields.io/badge/Flutter-v3.19+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-v3.3+-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)

`Flying Run` 是一款**AI陪伴式运动打卡与健康数据监测富前端应用**。基于端侧智能与云端大数据模型分析，它能够动态汇总用户的步数、心率、睡眠及血氧等健康体征，为用户提供科学的健康管理与弹性运动处方。同时，应用开创性地引入了 AI 伴跑教练，在运动全程给予用户实时且温暖的语音陪伴与激励。

> ⚠️ **注意**：本仓库为 App 前端 UI 与业务路由源码。所有核心数据流转、大模型分析均通过 `lib/config/api_config.dart` 与后端服务器/第三方穿戴硬件交互。详细后端接口规范见 [API_Config 配置文档](./API.md)。项目顶层设计规划见 [项目分析文档](./项目规划.md)。

---

## 🌟 核心技术架构选型

### 1. 医学健康数据分析模型 (QLoRA + Qwen3-7B + DPO)
放弃硬编码的健康建议，我们采用微调的开源千问模型 (`Qwen3-7B`) 进行健康审计。通过收集用户的睡眠、心率与步数数据，结合 DPO (Direct Preference Optimization) 对齐医疗专家偏好，提供高安全性、极具针对性的千人千面“运动处方”。

### 2. AI 伴跑教练语音克隆 (云端 GPT-SoVITS)
全面接入云端 `GPT-SoVITS` 极速声音克隆方案。支持仅用少量样本复刻高质量、强情感表现力的音色（专业教练、元气少女等）。同时采用严格的账户绑定策略加密音色资产，保护用户隐私。

### 3. 底层通信与安全中转 (Dio 拦截器)
App 内置工业级 `Dio` 网络封装 (`lib/services/http_client.dart`)。所有通信链路不仅具备完整的超时重试、状态解包功能，而且集成了统一的加密 Token 注入验证，保障每一次健康数据同步的链路安全。

---

## 📱 系统核心板块与落地场景

### 场景 1：校园模式落地（智慧体育与绝对合规）
*   **功能**：对接高校“阳光跑”要求，支持 GPS 运动轨迹定位防作弊。校园网下发每日跑步规定区域与公里数任务，由 App 进行导航打卡。
*   **安全亮点**：**数据不落地原则**。App 作为纯粹的数据搬运工，通过加密通道直接将步频/定位转交至校园私有服务器，以此杜绝学生隐私外泄。

### 场景 2：社区康养模块（体医融合适老化）
*   **功能**：连接穿戴设备拉取实时心率与血氧数据，关注老年人群慢病管理。
*   **急救亮点**：内置异常检测，一旦侦测到极高心率或跌倒状态，App 立刻触发生命体征预警，并直连“社区全科医生”及自动上报监护人。

### 场景 3：基础个人运动监测
*   提供跳动迷你音轨波形、实时状态呼吸灯（PulsingDot）与灵动岛通知。
*   支持三维全息加载动画（Holographic Loader），直观呈现 AI 数据处理的进程。

---

## 🛠️ 目录结构与快速开始

### 核心目录树
```bash
lib/
├── config/
│   └── api_config.dart       # API路由常量配置 (校园、社区、大模型接口定义)
├── services/
│   ├── http_client.dart      # 基于 Dio 的统一网络请求中心
│   ├── token_manager.dart    # 登录凭证加密持久化管理器
│   └── adapters/             # 第三方硬件 JSON 数据清洗层
├── models/
│   └── app_state.dart        # 状态流转中心 (UI 层依赖)
├── screens/
│   ├── dashboard_screen.dart # 健康监测主界面
│   ├── ai_coach_screen.dart  # AI 伴跑聊天及声音调节参数界面
│   ├── sports_screen.dart    # 运动打卡、GPS与运动总结界面
│   └── reports_screen.dart   # Holographic Loader 加载审计报告界面
└── widgets/
    └── dynamic_island.dart   # 全局灵动岛通知与动效组件
```

### 运行环境
- Flutter SDK >= 3.19.0
- Dart SDK >= 3.3.0

### 部署与调试
1. **安装最新依赖**（需拉取 Dio、Shared_Preferences 等新包）：
   ```bash
   flutter clean
   flutter pub get
   ```
2. **生成或更新桌面图标**（如需自定义发布）：
   ```bash
   dart run flutter_launcher_icons
   ```
3. **启动调试模式**：
   ```bash
   flutter run
   ```

---

*“本系统致力于通过端云协同与前沿大模型，打造最具情感温度的智能伴跑体验。”*
