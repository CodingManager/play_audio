import 'dart:async';
import 'dart:ffi';

import 'package:just_audio/just_audio.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:play_audio/core/models/SLAudioModel.dart';

import '../models/SLAudioPlayList.dart';
import '../utils/Logger.dart';
import '../utils/MusicListener.dart';


class PlaybackController with ChangeNotifier {

  /// 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// 播放列表
  final _playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: []);

  /// 音频播放状态
  ProcessingState playerState = ProcessingState.idle;

  /// 播放进度
  int duration = 0;

  /// 播放音量
  double playVolume = 1.0;

  /// 保存回调事件
  List<MusicListener> musicListeners = [];

  int playIndex = -1;

  /// 当前正在播放的音频
  String? playUrl;

  /// 使用一个变量来区别当前播放的音乐列表，用于切换播放列表时，判断是否需要重新加载音乐。
  int groupId = -1;



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
      _audioPlayer.positionStream.listen((value) {

        duration = value.inMilliseconds;
        notifyMusicListeners((listener) {
          listener.onPositionChanged(duration);
        });
      },onError: (e){
        Logger.error(e);
      },onDone:(){

      });



      // 监听播放状态
      _audioPlayer.playerStateStream.listen((PlayerState state) {
        Logger.debug("播放状态发生变化: $state");
        playerState = state.processingState;
        notifyListeners();
        // notifyMusicListeners((listener) {
        //   listener.onPlayerStateChanged(playerState);
        // });
      },onError: (e){
        Logger.error(e);
      },onDone:(){

      });

      // 监听播放时长
      _audioPlayer.durationStream.listen((value) {
        Logger.debug("音频的播放时长: $value");
        notifyMusicListeners((listener) {
          listener.onDurationChanged(value);
        });
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





  /// 播放网络音频
  Future _startPlay(String url) async {

    // 切换播放状态，加载中。
    playerState = ProcessingState.loading;
    notifyListeners();
    // 重置播放进度
    duration = 0;
    // 更新当前播放的音频



    //播放音频
    try {
      await _audioPlayer.play();
    } on TimeoutException {
      Logger.error("播放音频超时");
      // 如果播放音频超时，直接设置播放状态为播放结束，这样就不会再有回调了。
      // _audioPlayer.state = PlayerState.completed;
    } catch (e) {
      Logger.error("void startPlay()  播放音乐出现了异常：$e");
    }

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
          _playlist.add(AudioSource.uri(Uri.parse(element.playUrl!)));
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
    if (playerState == ProcessingState.ready) {
      await _audioPlayer.pause();
    }
  }

  // Stop the current track
  Future<void> stop() async {
    // 判断播放状态,是否需要停止
    if (playerState == ProcessingState.ready) {
      await _audioPlayer.stop();
    }
  }

  Future<void> play() async {
    if (_audioPlayer.playing == false && playerState == ProcessingState.ready) {
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
      Logger.debug("下一首");

      await _audioPlayer.seekToNext();
    }
  }

  // 播放上一首
  Future<void> previous() async {
    // 1. 先从播放列表中获取上一首音频
    if (_playlist.children.isEmpty) {
      Logger.debug("当前播放列表为空，不能播放");
      return;
    }else {
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
