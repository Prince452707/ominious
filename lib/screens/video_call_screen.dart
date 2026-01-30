import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:ui';
import '../controllers/video_call_controller.dart';
import '../core/theme/app_theme.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoCallController>();

    return Scaffold(
      body: Obx(() {
        if (controller.callState.value == CallState.connecting ||
            controller.callState.value == CallState.idle) {
          return _buildLoadingState();
        }

        return Stack(
          children: [
            _buildVideoView(controller),
            _buildGradientOverlay(),
            _buildTopBar(controller),
            _buildBottomControls(controller),
            _buildConnectionStatus(controller),
          ],
        );
      }),
    );
  }

  Widget _buildVideoView(VideoCallController controller) {
    final remoteUsers = controller.remoteUsers;

   
    if (remoteUsers.isEmpty) {
      return Obx(
        () => controller.isVideoDisabled.value
            ? _buildCameraOffPlaceholder('You')
            : AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: controller.engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
      );
    } else if (remoteUsers.length == 1) {
   
      return Stack(
        children: [
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: controller.engine,
              canvas: VideoCanvas(uid: remoteUsers[0]),
              connection: RtcConnection(channelId: controller.channelName),
            ),
          ),
          Positioned(
            right: 16,
            top: 100, 
            width: 120,
            height: 160,
            child: Obx(
              () => controller.isVideoDisabled.value
                  ? _buildCameraOffPlaceholder('You', small: true)
                  : AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: controller.engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    ),
            ),
          ),
        ],
      );
    } else {
    
      final allUsers = [0, ...remoteUsers];
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
        ),
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          final uid = allUsers[index];
          if (uid == 0) {
            return Obx(
              () => controller.isVideoDisabled.value
                  ? _buildCameraOffPlaceholder('You')
                  : AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: controller.engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    ),
            );
          } else {
            return AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: controller.engine,
                canvas: VideoCanvas(uid: uid),
                connection: RtcConnection(channelId: controller.channelName),
              ),
            );
          }
        },
      );
    }
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
            const SizedBox(height: 24),
            Text(
              'Connecting...',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
       
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withOpacity(0.7),
                Colors.transparent,
                Colors.transparent,
                AppColors.background.withOpacity(0.7),
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(VideoCallController controller) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Obx(
                      () => Text(
                        controller.formattedDuration,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Obx(
                      () => Icon(
                        controller.callState.value == CallState.connected
                            ? Icons.signal_cellular_alt
                            : Icons.signal_cellular_connected_no_internet_0_bar,
                        color: controller.callState.value == CallState.connected
                            ? AppColors.success
                            : AppColors.warning,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(VideoCallController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.cameraswitch,
                      onPressed: controller.switchCamera,
                      color: AppColors.accent,
                    ),
                    Obx(
                      () => _buildControlButton(
                        icon: controller.isMuted.value
                            ? Icons.mic_off
                            : Icons.mic,
                        onPressed: controller.toggleMute,
                        color: controller.isMuted.value
                            ? AppColors.error
                            : AppColors.primary,
                        isActive: !controller.isMuted.value,
                      ),
                    ),
                    Obx(
                      () => _buildControlButton(
                        icon: controller.isVideoDisabled.value
                            ? Icons.videocam_off
                            : Icons.videocam,
                        onPressed: controller.toggleVideo,
                        color: controller.isVideoDisabled.value
                            ? AppColors.error
                            : AppColors.primary,
                        isActive: !controller.isVideoDisabled.value,
                      ),
                    ),
                    _buildControlButton(
                      icon: Icons.call_end,
                      onPressed: controller.endCall,
                      color: AppColors.error,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isActive = true,
    double size = 24,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.8), color],
                  )
                : null,
            color: isActive ? null : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : AppColors.textSecondary,
            size: size,
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(VideoCallController controller) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Obx(() {
        if (controller.callState.value != CallState.connecting) {
          return const SizedBox.shrink();
        }

        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Connecting to call...',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCameraOffPlaceholder(String label, {bool small = false}) {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(small ? 12 : 24),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.videocam_off_rounded,
                color: AppColors.textSecondary,
                size: small ? 24 : 48,
              ),
            ),
            if (!small) ...[
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
