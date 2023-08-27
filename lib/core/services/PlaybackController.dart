import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:play_audio/core/models/SLAudioModel.dart';

import '../models/SLAudioPlayList.dart';
import '../utils/Logger.dart';


class PlaybackController with ChangeNotifier {

  /// 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer(playerId: "1");

  /// 播放列表
  final SLAudioPlayList _audioPlayList = SLAudioPlayList();

  /// 音频播放状态
  PlayerState playerState = PlayerState.stopped;

  /// 播放音量
  double playVolume = 1.0;

  //  PlaybackController 初始化
  PlaybackController() {

      // 设置播放器参数
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // 设置播放速度
      _audioPlayer.setPlaybackRate(1.0);
      // 播放音量
      _audioPlayer.setVolume(playVolume);

      // 监听播放进度
      _audioPlayer.onPositionChanged.listen((event) {
        Logger.debug("onPositionChanged : $event");
      });

      // 监听播放状态
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        playerState = state;
        Logger.debug("播放器状态: $state");
        switch (state){
          case PlayerState.playing:
            Logger.debug("播放");
            break;
          case PlayerState.paused:
            Logger.debug("暂停播放");
            break;
          case PlayerState.stopped:
            Logger.debug("停止播放");
            break;
          case PlayerState.completed:
            Logger.debug("播放结束");
            break;
          case PlayerState.disposed:
            Logger.debug("播放销毁");
            break;
        }
        notifyListeners();
      });

      // 监听播放进度
      _audioPlayer.onDurationChanged.listen((event) {
        Logger.debug("onPlayerStateChanged: $event");
      },onError: (e){
        Logger.error(e);
      },onDone:(){

      });

  }


  /// 设置播放列表，这个方式只设置数据，默认并不会播放，需要调用【startPlay】接口才会播放，
  /// 参数说明：
  /// audioGroup: 音频列表
  /// playIndex: 开始播放第几首
  /// isPlay: 是否立即播放
  void setPlayList(List<SlAudioModel> audioGroup, int playIndex, {bool isPlay = false}) {
    // 校验 playIndex 参数是否合法，如果不合法，直接修改为0
    if (playIndex < 0 || playIndex >= audioGroup.length) {
      playIndex = 0;
    }

    _audioPlayList.setPlayList(audioGroup, playIndex);
    if (isPlay) {
      startPlay();
    }
  }

  /// 开始播放
  void startPlay() async {
    SlAudioModel? audioModel = _audioPlayList.getCurrentAudio();
    if (audioModel == null) {
      Logger.debug("当前播放列表为空，不能播放");
      return;
    }else {
      Logger.debug("开始播放音频: ${audioModel.title}");
      // 校验模型中的音频地址是否为空
      if (audioModel.playUrl == null || audioModel.playUrl!.isEmpty) {
        Logger.error("音频地址为空");
        return;
      }else {
        // 播放音频
        try {
          await _audioPlayer.play(UrlSource(audioModel.playUrl!));
        } catch(e) {
          Logger.error("void startPlay()  播放音乐出现了异常：$e");
        }
      }
    }
  }



  // Pause the current track
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // Stop the current track
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // 播放下一首
  Future<void> next() async {
    // 1. 先从播放列表中获取下一首音频
    SlAudioModel? audioModel = _audioPlayList.next();
    if (audioModel == null) {
      Logger.debug("当前播放列表为空，不能播放");
      return;
    }else {
      Logger.debug("开始播放音频: ${audioModel.title}");
      // 校验模型中的音频地址是否为空
      if (audioModel.playUrl == null || audioModel.playUrl!.isEmpty) {
        Logger.error("音频地址为空");
        return;
      }else {
        // 播放音频
        try {
          await _audioPlayer.play(UrlSource(audioModel.playUrl!));
        }catch(e) {
          Logger.error("播放下一首音乐出现了异常：$e");
        }
      }
    }
  }

  // 播放上一首
  Future<void> previous() async {
    // 1. 先从播放列表中获取下一首音频
    SlAudioModel? audioModel = _audioPlayList.previous();
    if (audioModel == null) {
      Logger.debug("当前播放列表为空，不能播放");
      return;
    }else {
      Logger.debug("开始播放音频: ${audioModel.title}");
      // 校验模型中的音频地址是否为空
      if (audioModel.playUrl == null || audioModel.playUrl!.isEmpty) {
        Logger.error("音频地址为空");
        return;
      }else {
        // 播放音频
        try {
          await _audioPlayer.play(UrlSource(audioModel.playUrl!));
        }catch(e) {
          Logger.error("播放上一首音乐出现了异常：$e");
        }
      }
    }

  }

  // Set volume (value should be between 0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    playVolume = volume;
    await _audioPlayer.setVolume(playVolume);
  }

  // 修改进度
  Future seek(int millSeconds) async {

    try{
      await _audioPlayer.seek(Duration(milliseconds: millSeconds));
    }catch(e) {
      Logger.error("修改进度出现了异常：$e");
    }
  }

  /// 修改播放模式
  void setPlayMode(CycleType playMode) {
    _audioPlayList.cycleType = playMode;
  }

  // Get current playing status
  PlayerState get status => _audioPlayer.state;

  // Clean up resources
  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }
}
