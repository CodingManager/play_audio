import 'dart:async';
import 'dart:ffi';

import 'package:just_audio/just_audio.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:play_audio/core/models/SLAudioModel.dart';

import '../models/SLAudioPlayList.dart';
import '../utils/Logger.dart';
import '../utils/MusicListener.dart';


enum SLPlayerState {
  loading,// 音频正在加载
  playing, // 播放中
  paused, // 暂停
  stopped,// 停止
  completed,// 播放完成
}

class PlaybackController with ChangeNotifier {

  /// 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// 播放列表
  final _playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: []);

  Duration _totalDuration = const Duration(milliseconds: 1); // 初始化为1以避免除以0的错误

  Duration _currentPosition = Duration.zero;


  double get progress => _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;


  /// 音频播放状态
  // PlayerState playerState = PlayerState(false, ProcessingState.loading);
  SLPlayerState playerState = SLPlayerState.stopped;

  /// 播放进度
  double duration = 0;

  /// 播放音量
  double playVolume = 1.0;

  /// 保存回调事件
  List<MusicListener> musicListeners = [];

  int playIndex = -1;

  /// 当前正在播放的音频
  String? playUrl;

  /// 使用一个变量来区别当前播放的音乐列表，用于切换播放列表时，判断是否需要重新加载音乐。
  int groupId = -1;

  // 获取音频的总时长（毫秒）
  int get totalDurationInMilliseconds => _totalDuration.inMilliseconds;


  AudioPlayer get getAudioPlayer => _audioPlayer;
  
  //  PlaybackController 初始化
  PlaybackController() {


      // 设置循环模式
      _audioPlayer.setLoopMode(LoopMode.all);

      // 播放音量
      _audioPlayer.setVolume(playVolume);

      // 设置播放列表
      _audioPlayer.setAudioSource(_playlist);

      // 监听播放进度
      _audioPlayer.positionStream.listen((Duration value) {
        // 把 Duration 转换成毫秒，这个变量用于进度条，需要使用浮点数。
        _currentPosition = value;
        notifyListeners();

        // Logger.info("播放进度：$progress");
      },onError: (e){
        Logger.error(e);
      },onDone:(){

      });

      // 监听播放时长
      _audioPlayer.durationStream.listen((value) {
        if (value != null) {
          _totalDuration = value;
          Logger.debug("音频的播放时长: $value");
        }


        // notifyMusicListeners((listener) {
        //   listener.onDurationChanged(value);
        // });
      },onError: (e){
        Logger.error(e);
      },onDone:(){

      });
      //
      // _audioPlayer.playbackEventStream.listen((event) {
      //   Logger.debug("播放事件: $event");
      // },onError: (e){
      //   Logger.error(e);
      // },onDone:(){
      //
      // });

      _audioPlayer.sequenceStream.listen((value) {
        Logger.debug("播放列表发生变化: $value");
        // playIndex = value;
        notifyListeners();
      },onError: (e){
        Logger.error(e);
      },onDone:(){

      });
      // _audioPlayer.sequenceStateStream.listen((value) {
      //   Logger.debug("播放列表状态发生变化: $value");
      //
      //   // playIndex = value;
      //   notifyListeners();
      // },onError: (e){
      //   Logger.error(e);
      // },onDone:(){
      //
      // });

      _audioPlayer.currentIndexStream.listen((value) {
        Logger.debug("当前播放的音频索引: $value");
        if (value != null){
          playIndex = value;
        }
        notifyListeners();
      },onError: (e){
        Logger.error(e);
      },onDone:(){

      });
      // 监听播放状态
      _audioPlayer.playerStateStream.listen((PlayerState state) {
        Logger.debug("播放状态发生变化: $state");
        if (state.processingState == ProcessingState.ready && state.playing){
          playerState = SLPlayerState.playing;
        }else if (state.processingState == ProcessingState.buffering && state.playing){
          playerState = SLPlayerState.loading;
        }else if (state.processingState == ProcessingState.completed && state.playing == false) {
          playerState = SLPlayerState.completed;
        }else if (state.processingState == ProcessingState.loading){
          playerState = SLPlayerState.loading;
        }else if (state.playing == false && state.processingState == ProcessingState.ready){
          playerState = SLPlayerState.paused;
        }
        notifyListeners();
        // notifyMusicListeners((listener) {
        //   listener.onPlayerStateChanged(playerState);
        // });
      },onError: (e){
        Logger.error(e);
      },onDone:(){

      });


      //
      // // 监听播放进度
      // _audioPlayer.onDurationChanged.listen((event) {
      //   Logger.debug("onPlayerStateChanged: $event");
      // },onError: (e){
      //   Logger.error(e);
      // },onDone:(){
      //
      // });

  }


  /// 设置播放列表，这个方式只设置数据，默认并不会播放，需要调用【startPlay】接口才会播放，
  /// 参数说明：
  /// audioGroup: 音频列表
  /// groupId: 音频列表的id，用于区分不同的音频列表
  /// playIndex: 开始播放第几首
  /// isPlay: 是否立即播放
  void setPlayListWithPlay(List<SlAudioModel> audioGroup,groupId,{int playIndex = 0, bool isPlay = true}) {

    // 1. 先校验 playIndex 参数是否合法，如果不合法，直接修改为0
    if (playIndex < 0 || playIndex >= audioGroup.length) {
      playIndex = 0;
    //  playIndex 参数不合法，抛出异常。
      throw Exception("playIndex 参数不合法");
    }

    this.playIndex = playIndex;
    playUrl = audioGroup[playIndex].playUrl;

    // 2. 判断是否需要重新加载音乐
    if (this.groupId == groupId) {
      // 不需要重新加载音乐列表，只需要修改播放索引即可
      Logger.debug("不需要重新加载音乐列表,只需要修改播放索引即可");
      // 设置播放索引
      // _playlist.move(0, playIndex);
    }else {
      // 3.不是同一个音频列表，需要重新加载音乐列表
      _playlist.clear(); // 先清除播放列表
      for (SlAudioModel element in audioGroup) {
        if (element.playUrl != null) {
          AudioSource audioSource = LockCachingAudioSource(Uri.parse(element.playUrl!));
          _playlist.add(audioSource);
        }
      }
      this.groupId = groupId;
    }
    // 4. 判断是否需要立即播放
    if (isPlay) {
      startPlay();

    }
  }

  /// 开始播放，可以手动调用
  void startPlay() async {

    await _audioPlayer.setAudioSource(_playlist, initialIndex: playIndex, initialPosition: Duration.zero);
    await _audioPlayer.play();                  // Skip to the next item

    //
    // AudioSource audioSource = _playlist.children[playIndex];
    // audioSource.

    //
    // // 获取当前正在播放的音乐和接下来要播放的音乐，如果相同，不需要重新播放，直接返回。
    //
    // if (playUrl playerState == ProcessingState.loading) {
    //   Logger.debug("当前播放的音乐和准备播放的音乐相同，不需要重新播放");
    //   return;
    // }else {
    //
    //   // 3. 判断当前播放的音乐是否为空
    //   if (readPlayAudio != null) {
    //     await _startPlay(readPlayAudio);
    //   }else {
    //     Logger.debug("当前播放的音乐为空，不能播放");
    //   }
    //
    // }

  }



  // Pause the current track
  Future<void> pause() async {
    if (playerState == SLPlayerState.playing) {
      await _audioPlayer.pause();
    }
  }

  // Stop the current track
  Future<void> stop() async {
    // 判断播放状态,是否需要停止
    if (playerState == SLPlayerState.playing) {
      await _audioPlayer.stop();
    }
  }

  Future<void> play() async {
    if (playerState != SLPlayerState.playing) {
      await _audioPlayer.play();
    }
  }


  // 播放下一首
  Future<void> next() async {

    // 1. 先从播放列表中获取下一首音频
    if (_playlist.children.isEmpty) {
      Logger.debug("当前播放列表为空，不能播放");
      return;
    }else {

      if (_playlist.children.length <0 || playIndex >= _playlist.children.length - 1) {
        playIndex = 0;
      }else {
        playIndex++;
      }

      Logger.debug("下一首");
      await _audioPlayer.seekToNext();
    }
  }

  // 播放上一首
  Future<void> previous() async {
    // 1. 先从播放列表中获取下一首音频
    if (_playlist.children.isEmpty) {
      Logger.debug("当前播放列表为空，不能播放");
      return;
    }else {

      if (playIndex <= 0) {
        playIndex = _playlist.children.length - 1;
      }else {
        playIndex--;
      }

      Logger.debug("上一首");
      await _audioPlayer.seekToPrevious();
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
  void setPlayMode(LoopMode loopMode) {
    _audioPlayer.setLoopMode(loopMode);
  }

  /// 通知音乐监听器
  void notifyMusicListeners(Function event) {
    for (MusicListener listener in musicListeners) {
      event(listener);
    }
  }
  /// 添加音乐监听器，销毁后记得移除。
  void addMusicListener(MusicListener listener) {
    if (musicListeners.contains(listener) == false){
      musicListeners.add(listener);
    }
  }
  /// 移除音乐监听器
  void removeMusicListener(MusicListener listener) {
    if (musicListeners.contains(listener)) {
      musicListeners.remove(listener);
    }
  }

  // Clean up resources
  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }
}
