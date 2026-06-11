import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/dynamic_island.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showModelConfig = false;
  bool _showCustomVoiceConfig = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Column(
          children: [
            // Coach Horizontal Selector List
            _buildCoachSelector(state),

            // Toggleable Local TTS parameters (README requirement: 本地简易部署声音语气模拟)
            _buildModelConfigPanel(state),

            // Cloud Custom Voice Cloning Panel
            _buildCustomVoicePanel(state),

            // Message Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: state.isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.015),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: state.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.08)),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Standard chat behavior: bottom-to-top layout
                  padding: const EdgeInsets.all(12.0),
                  itemCount: state.chatMessages.length + (state.isAiTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (state.isAiTyping) {
                      if (index == 0) {
                        return _buildTypingIndicator(state, state.currentCoach);
                      }
                      final msg = state.chatMessages[state.chatMessages.length - index];
                      return _buildMessageBubble(state, msg, state.currentCoach);
                    } else {
                      final msg = state.chatMessages[state.chatMessages.length - 1 - index];
                      return _buildMessageBubble(state, msg, state.currentCoach);
                    }
                  },
                ),
              ),
            ),

            // Suggestion Chips
            _buildSuggestionChips(state),

            // Input Row
            ChatInputRow(state: state, textController: _textController),
          ],
        );
      },
    );
  }

  Widget _buildCoachSelector(AppState state) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        itemCount: state.coaches.length,
        itemBuilder: (context, index) {
          final coach = state.coaches[index];
          bool isSelected = state.selectedCoachId == coach.id;
          return GestureDetector(
            onTap: () => state.selectCoach(coach.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          coach.themeColor.withValues(alpha: 0.25),
                          coach.themeColor.withValues(alpha: 0.05),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          state.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                          state.isDarkMode ? Colors.white.withValues(alpha: 0.01) : Colors.black.withValues(alpha: 0.01),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected 
                      ? coach.themeColor.withValues(alpha: 0.6) 
                      : (state.isDarkMode ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: coach.themeColor.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isSelected 
                        ? coach.themeColor.withValues(alpha: 0.2) 
                        : (state.isDarkMode ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
                    radius: 18,
                    child: Text(
                      coach.avatarUrl,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          coach.name.split(' ')[0], // just Chinese name
                          style: TextStyle(
                            color: isSelected 
                                ? (state.isDarkMode ? Colors.white : coach.themeColor)
                                : state.primaryTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          coach.title,
                          style: TextStyle(
                            color: state.secondaryTextColor,
                            fontSize: 9,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModelConfigPanel(AppState state) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showModelConfig = !_showModelConfig;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings_suggest_rounded,
                      color: state.currentCoach.themeColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      '本地声音参数微调 (简易端侧部署模拟)',
                      style: TextStyle(
                        color: state.secondaryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _showModelConfig ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: state.isDarkMode ? Colors.white30 : Colors.black38,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (_showModelConfig)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: state.isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: state.isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '激活端侧个性化TTS模拟',
                      style: TextStyle(color: state.secondaryTextColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: state.localVoiceDeployment,
                      activeThumbColor: state.currentCoach.themeColor,
                      onChanged: (val) {
                        state.localVoiceDeployment = val;
                      },
                    ),
                  ],
                ),
                Divider(color: state.isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08), height: 12),
                _buildSliderItem(
                  state,
                  label: '声调音高 (Pitch): ${state.voicePitch.toStringAsFixed(1)}',
                  value: state.voicePitch,
                  min: 0.5,
                  max: 1.8,
                  activeColor: state.currentCoach.themeColor,
                  onChanged: (val) {
                    setState(() {
                      state.voicePitch = val;
                    });
                  },
                ),
                _buildSliderItem(
                  state,
                  label: '鼓励语速 (Speed): ${state.voiceSpeed.toStringAsFixed(1)}',
                  value: state.voiceSpeed,
                  min: 0.7,
                  max: 1.5,
                  activeColor: state.currentCoach.themeColor,
                  onChanged: (val) {
                    setState(() {
                      state.voiceSpeed = val;
                    });
                  },
                ),
                _buildSliderItem(
                  state,
                  label: '声音能量 (Energy): ${state.voiceEnergy.toStringAsFixed(1)}',
                  value: state.voiceEnergy,
                  min: 0.6,
                  max: 1.6,
                  activeColor: state.currentCoach.themeColor,
                  onChanged: (val) {
                    setState(() {
                      state.voiceEnergy = val;
                    });
                  },
                ),
              ],
            ),
          ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildCustomVoicePanel(AppState state) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showCustomVoiceConfig = !_showCustomVoiceConfig;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.cloud_upload_rounded,
                      color: state.currentCoach.themeColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      '云端声线与口癖克隆 (轻量算力卸载)',
                      style: TextStyle(
                        color: state.secondaryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _showCustomVoiceConfig ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: state.isDarkMode ? Colors.white30 : Colors.black38,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (_showCustomVoiceConfig)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: state.isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: state.isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Voice sample selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1. 录入声音特征样本 (WAV)',
                      style: TextStyle(color: state.primaryTextColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    if (state.recordedVoicePath == null || state.recordedVoicePath!.isEmpty)
                      ElevatedButton.icon(
                        onPressed: () {
                          state.setRecordedVoice('/data/user/0/com.flyingrun/cache/temp_sample.wav');
                        },
                        icon: const Icon(Icons.mic_rounded, size: 12, color: Colors.black),
                        label: const Text('录制 15s 音频', style: TextStyle(fontSize: 10, color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.currentCoach.themeColor,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                    else
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                          const SizedBox(width: 4.0),
                          Text(
                            'temp_sample.wav',
                            style: TextStyle(color: state.secondaryTextColor, fontSize: 10),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 14),
                            onPressed: () => state.setRecordedVoice(''),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          )
                        ],
                      )
                  ],
                ),
                const SizedBox(height: 10.0),
                
                // Dialogue images selection
                Text(
                  '2. 上传聊天/口吻截图 (提取语气特征)',
                  style: TextStyle(color: state.primaryTextColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    ...state.uploadedDialogueImagePaths.asMap().entries.map((entry) {
                      int idx = entry.key;
                      return Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: state.isDarkMode ? Colors.white10 : Colors.black12,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: state.currentCoach.themeColor.withValues(alpha: 0.3)),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.image_rounded, size: 18, color: Colors.grey),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: GestureDetector(
                                onTap: () => state.removeDialogueImage(idx),
                                child: Container(
                                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                  child: const Icon(Icons.close_rounded, size: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () {
                        state.addDialogueImage('screenshot_${state.uploadedDialogueImagePaths.length + 1}.png');
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: state.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: state.isDarkMode ? Colors.white12 : Colors.black26),
                        ),
                        child: const Icon(Icons.add_photo_alternate_rounded, size: 18, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                Divider(color: state.isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.08), height: 16),
                
                // Train actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: state.isCustomVoiceTraining
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(state.currentCoach.themeColor),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  '云端提取口风与TTS模型声线中...',
                                  style: TextStyle(color: state.secondaryTextColor, fontSize: 9),
                                ),
                              ],
                            )
                          : Text(
                              (state.recordedVoicePath == null || state.recordedVoicePath!.isEmpty)
                                  ? '等待上传样本以进行参数化克隆' 
                                  : '自定义声线配置就绪',
                              style: TextStyle(color: state.secondaryTextColor, fontSize: 9),
                            ),
                    ),
                    ElevatedButton(
                      onPressed: ((state.recordedVoicePath == null || state.recordedVoicePath!.isEmpty) || state.isCustomVoiceTraining)
                          ? null
                          : () => state.submitCustomVoiceTraining(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.currentCoach.themeColor,
                        disabledBackgroundColor: state.isDarkMode ? Colors.white10 : Colors.black12,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        state.isCustomVoiceTraining ? '训练中...' : '提交云端训练',
                        style: TextStyle(
                          fontSize: 10, 
                          color: ((state.recordedVoicePath == null || state.recordedVoicePath!.isEmpty) || state.isCustomVoiceTraining)
                              ? state.secondaryTextColor 
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (state.customVoiceParameterUrl.isNotEmpty) ...[
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '启用克隆声线(云端推理/低开销)',
                              style: TextStyle(color: state.primaryTextColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: state.isCustomVoiceEnabled,
                              activeThumbColor: Colors.green,
                              onChanged: (val) => state.toggleCustomVoice(val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '专属声线参数URL: ${state.customVoiceParameterUrl}',
                          style: const TextStyle(color: Colors.grey, fontSize: 8, fontFamily: 'monospace'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildSliderItem(
    AppState state, {
    required String label,
    required double value,
    required double min,
    required double max,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: state.secondaryTextColor, fontSize: 10),
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: activeColor,
              inactiveTrackColor: state.isDarkMode ? Colors.white10 : Colors.black12,
              thumbColor: activeColor,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AppState state, Message msg, Coach currentCoach) {
    bool isMe = msg.sender == 'user';
    
    Decoration bubbleDecoration = isMe
        ? BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00E6FF), Color(0xFF0284C7)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0),
              topRight: Radius.circular(18.0),
              bottomLeft: Radius.circular(18.0),
              bottomRight: Radius.circular(4.0),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E6FF).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          )
        : BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                state.isDarkMode ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                state.isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0),
              topRight: Radius.circular(18.0),
              bottomLeft: Radius.circular(4.0),
              bottomRight: Radius.circular(18.0),
            ),
            border: Border.all(
              color: currentCoach.themeColor.withValues(alpha: state.isDarkMode ? 0.35 : 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: currentCoach.themeColor.withValues(alpha: state.isDarkMode ? 0.05 : 0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        decoration: bubbleDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: isMe ? Colors.black : (state.isDarkMode ? Colors.white : const Color(0xFF1E293B)),
                fontSize: 13,
                height: 1.4,
                fontWeight: isMe ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            
            // Audio wave simulation if present
            if (msg.audioWaveform != null) ...[
              const SizedBox(height: 8.0),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      state.speak(msg.text);
                      DynamicIsland.show(
                        context,
                        title: '伴跑语音播放',
                        message: '正在播放由【${currentCoach.name}】实时模拟生成的伴跑语音播报...',
                        icon: Icons.volume_up_rounded,
                        color: currentCoach.themeColor,
                        isAudio: true,
                        duration: const Duration(seconds: 3),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: currentCoach.themeColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: _buildAudioWaveVisualizer(currentCoach.themeColor),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '2"',
                    style: TextStyle(
                      color: isMe ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildAudioWaveVisualizer(Color color) {
    // Generate simple vertical bar visualizer
    List<double> heights = [3, 8, 14, 10, 6, 12, 18, 22, 16, 10, 4, 8, 12, 16, 10, 4];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: heights.map((h) {
        return Container(
          width: 2.0,
          height: h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypingIndicator(AppState state, Coach coach) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: coach.themeColor.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
            bottomLeft: Radius.circular(4.0),
            bottomRight: Radius.circular(16.0),
          ),
          border: Border.all(color: coach.themeColor.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${coach.name.split(' ')[0]} 正在合成反馈语音',
              style: TextStyle(
                color: state.secondaryTextColor,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 8.0),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(coach.themeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSuggestionChips(AppState state) {
    List<String> chips = [];
    if (state.selectedCoachId == 'spark') {
      chips = ['🔥 推荐跑步计划', '⚡ 怎么提升配速', '🏃‍♂️ 3公里挑战'];
    } else if (state.selectedCoachId == 'lynn') {
      chips = ['🍃 跑后如何拉伸', '🧘 呼吸如何调整', '🥗 运动后饮食建议'];
    } else {
      chips = ['🛡️ 想偷懒怎么办', '👟 规避膝盖受损', '⏰ 晨跑好还是夜跑好'];
    }

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: chips.length,
        itemBuilder: (context, idx) {
          final text = chips[idx];
          return GestureDetector(
            onTap: () {
              // Strip emojis by taking the text after the first space
              final parts = text.split(' ');
              String sendText = parts.length > 1 ? parts.sublist(1).join(' ') : text;
              state.sendChatMessage(sendText.trim());
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: state.isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: state.isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: state.secondaryTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatInputRow extends StatefulWidget {
  final AppState state;
  final TextEditingController textController;

  const ChatInputRow({
    super.key,
    required this.state,
    required this.textController,
  });

  @override
  State<ChatInputRow> createState() => _ChatInputRowState();
}

class _ChatInputRowState extends State<ChatInputRow> with WidgetsBindingObserver {
  bool _isKeyboardOpen = false;
  double _keyboardHeight = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _checkKeyboardStatus();
  }

  void _checkKeyboardStatus() {
    if (WidgetsBinding.instance.platformDispatcher.views.isEmpty) return;
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final bottomInset = view.viewInsets.bottom;
    final devicePixelRatio = view.devicePixelRatio;
    final keyboardHeight = bottomInset / devicePixelRatio;
    final newIsKeyboardOpen = keyboardHeight > 10.0;
    if (_isKeyboardOpen != newIsKeyboardOpen || _keyboardHeight != keyboardHeight) {
      setState(() {
        _isKeyboardOpen = newIsKeyboardOpen;
        _keyboardHeight = keyboardHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final textController = widget.textController;

    return Container(
      padding: EdgeInsets.only(
        left: 16.0, 
        right: 16.0, 
        bottom: _isKeyboardOpen ? (_keyboardHeight + 16.0) : 96.0, 
        top: 8.0
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: state.isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: state.isDarkMode ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: TextField(
                      controller: textController,
                      style: TextStyle(color: state.primaryTextColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: '向AI陪伴教练提问，如 "推荐跑步计划"...',
                        hintStyle: TextStyle(color: state.secondaryTextColor, fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (val) {
                        state.sendChatMessage(val);
                        textController.clear();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.mic_none_rounded,
                      color: state.currentCoach.themeColor.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    onPressed: () {
                      DynamicIsland.show(
                        context,
                        title: '语音输入激活',
                        message: '正使用本地端侧极简TTS提取人声音频...',
                        icon: Icons.mic_rounded,
                        color: state.currentCoach.themeColor,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          GestureDetector(
            onTap: () {
              if (textController.text.trim().isNotEmpty) {
                state.sendChatMessage(textController.text);
                textController.clear();
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: state.currentCoach.themeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: state.currentCoach.themeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

