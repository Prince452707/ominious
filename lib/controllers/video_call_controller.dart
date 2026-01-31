import 'dart:async';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/constants/app_constants.dart';

enum CallState { idle, connecting, connected, disconnected }

class VideoCallController extends GetxController {
  final Rx<CallState> callState = CallState.idle.obs;
  final RxBool isMuted = false.obs;
  final RxBool isVideoDisabled = false.obs;
  final RxInt callDuration = 0.obs;

  late RtcEngine _engine;
  RtcEngine get engine => _engine;

  // Track remote users
  final RxList<int> remoteUsers = <int>[].obs;
  final RxBool _localUserJoined = false.obs;
  bool get localUserJoined => _localUserJoined.value;

  Timer? _callTimer;
  String? _channelName;
  String get channelName => _channelName ?? "";

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _channelName = args?['channelName'] ?? "prince";
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    if (_channelName == null) return;
    callState.value = CallState.connecting;

    // request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
        appId: AppConstants.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Local user joined: ${connection.localUid}');
          callState.value = CallState.connected;
          _localUserJoined.value = true;
          _startCallTimer();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('Remote user joined: $remoteUid');
          remoteUsers.add(remoteUid);
          callState.value = CallState.connected;
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              print('Remote user offline: $remoteUid');
              remoteUsers.remove(remoteUid);
              if (remoteUsers.isEmpty) {
                // Optional: Handle case when all users leave?
                // For now just keep call active as you might wait for others.
              }
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          callState.value = CallState.disconnected;
          _localUserJoined.value = false;
          remoteUsers.clear();
          _stopCallTimer();
        },
      ),
    );

    await _engine.joinChannel(
      token:
          "007eJxTYDiVuUOzXeDJ/ScMx024jNN6NJWZWOflVWyp2LlGsdsxS0iBwcDMPCXJxNjU2NLA1CTZJMUyzdjI0jw12dA42dLCJDVlpX1dZkMgI0OvpgcLIwMEgvhsDAVFmXnJqQwMALPPHP4=",
      channelId: "prince",
      uid: 0,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  void _startCallTimer() {
    callDuration.value = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDuration.value++;
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  String get formattedDuration {
    final duration = callDuration.value;
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    await _engine.muteLocalAudioStream(isMuted.value);
    // Also update local audio state
    await _engine.enableLocalAudio(!isMuted.value);
  }

  Future<void> toggleVideo() async {
    isVideoDisabled.value = !isVideoDisabled.value;
    await _engine.muteLocalVideoStream(isVideoDisabled.value);
    await _engine.enableLocalVideo(!isVideoDisabled.value);
  }

  Future<void> switchCamera() async {
    await _engine.switchCamera();
  }

  Future<void> endCall() async {
    _stopCallTimer();
    callState.value = CallState.disconnected;

    await _engine.leaveChannel();
    await _engine.release();

    await Future.delayed(const Duration(milliseconds: 300));
    Get.back();
  }

  @override
  void onClose() {
    _stopCallTimer();
    // Engine might be already released in endCall, but safe to check?
    // Usually best to release in onClose if not done.
    // However, endCall navigates back, so onClose will be called.
    // We should ensure release is called.
    try {
      _engine.release();
    } catch (e) {
      // ignore
    }
    super.onClose();
  }
}
