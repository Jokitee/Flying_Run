import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../main.dart'; // to read appMode

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Prefill if in developer mode
    if (appMode == 'developer') {
      _usernameController.text = 'developer@flyingrun.com';
      _passwordController.text = 'admin123';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(AppState state) {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = '用户名和密码不能为空';
      });
      return;
    }

    // Simple authentication logic
    if (appMode == 'developer' || (username == 'user@flyingrun.com' && password == 'user123') || (username == 'developer@flyingrun.com' && password == 'admin123')) {
      state.login(username: username);
      setState(() {
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = '用户名或密码错误';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isDark = state.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF090A11), const Color(0xFF131524), const Color(0xFF1E1035)]
                : [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB), const Color(0xFFEEF2F6)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo / Slogan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E6FF), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E6FF).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'web/favicon.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Flying Run',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: state.primaryTextColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    'AI 陪伴式打卡与健康数据监测系统',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: state.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Mode Indicator Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: appMode == 'developer'
                              ? const Color(0x2000E6FF)
                              : const Color(0x2010B981),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: appMode == 'developer'
                                ? const Color(0xFF00E6FF)
                                : const Color(0xFF10B981),
                          ),
                        ),
                        child: Text(
                          appMode == 'developer' ? '⚙️ 调试开发者模式' : '👤 用户模式',
                          style: TextStyle(
                            color: appMode == 'developer'
                                ? const Color(0xFF00E6FF)
                                : const Color(0xFF10B981),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // Input Username
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(color: state.primaryTextColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, color: state.secondaryTextColor, size: 18),
                      labelText: '账号/邮箱',
                      labelStyle: TextStyle(color: state.secondaryTextColor, fontSize: 13),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF00E6FF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Input Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: state.primaryTextColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: state.secondaryTextColor, size: 18),
                      labelText: '密码',
                      labelStyle: TextStyle(color: state.secondaryTextColor, fontSize: 13),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF00E6FF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Error Message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Login Button — uses Material+InkWell so the splash is
                  // strictly bounded to the visible gradient rectangle.
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _handleLogin(state),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Colors.white24,
                      highlightColor: Colors.white10,
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E6FF), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          child: const Text(
                            '登录系统',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Quick Bypass button if developer mode
                  if (appMode == 'developer') ...[
                    const SizedBox(height: 12.0),
                    OutlinedButton.icon(
                      onPressed: () {
                        state.login(username: 'developer@flyingrun.com');
                      },
                      icon: const Icon(Icons.rocket_launch_rounded, size: 16, color: Color(0xFF00E6FF)),
                      label: const Text(
                        '开发者快速调试通道',
                        style: TextStyle(color: Color(0xFF00E6FF), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00E6FF)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
