import 'dart:math';

import 'package:just_audio/just_audio.dart';

import 'SLAudioModel.dart';

// 循环模式
enum CycleType {
  queue, // 顺序播放
  one, // 单曲循环
  random // 随机播放
}

/// 这是一个播放列表，用于管理播放列表的播放顺序。
class SLAudioPlayList {

  /// 播放列表
  final playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: []);


  // 播放列表数据
  List<SlAudioModel> songList = [];
  // 当前播放的索引
  int index = 0;
  // 循环模式
  CycleType cycleType = CycleType.queue;
  // 当前播放的歌曲
  SlAudioModel? currentPlayAudio;

  /// 设置当前播放的音频模型
  void setCurrentPlayAudio(SlAudioModel audio) {
    currentPlayAudio = audio;
  }


  // 清除播放列表，这里需要考虑到播放列表的唯一性，所以需要判断是否已经存在。
  void clear() {
    songList.clear();
    playlist.clear();
    index = 0;
  }

  /// 设置播放列表，必须是 SlAudioModel 模型。
  setPlayList(List<SlAudioModel> audios, int playIndex) {
    playlist.clear();
    songList = audios;
    for (SlAudioModel element in audios) {
      playlist.add(AudioSource.uri(Uri.parse(element.playUrl!)));
    }
    index = playIndex;
  }

  /// 修改播放列表的索引，用于切换播放的音频。
  setCurrentIndex(int index) {
    // 修改 playlist 的索引
    playlist.move(this.index, index);

    this.index = index;


  }

  /// 获取当前播放的歌曲
  SlAudioModel? getCurrentIndexAudioModel() {
    if (songList.isEmpty) {
      return null;
    }

    return songList[index];
  }

  /// 获取下一条音频的数据
  SlAudioModel? next() {
    // 1.先判断当前的播放列表是否为空，如果为空，就返回空。
    if (songList.isEmpty) {
      return null;
    }
    //2.如果不为空，就判断当前的播放模式。
    switch (cycleType) {
      case CycleType.queue || CycleType.one:
        // 1.顺序播放和单曲循环模式下，如何用户点击下一首，则继续切换，
        // 2.如果当前的index大于等于播放列表的长度，就从头开始播放。
        index++;
        if (index >= songList.length) {
          index = 0;
        }
        break;
      case CycleType.random:
        // 随机播放，如果列表数量大于2，就随机播放，否则就顺序播放。
        if (songList.length > 2) {
          index = Random().nextInt(songList.length);
        } else {
          index++;
          if (index >= songList.length) {
            index = 0;
          }
        }
        break;
    }
    // 3.返回当前的音频数据。
    return songList[index];
  }

  /// 获取上一条音频的数据
  SlAudioModel? previous() {
    if (songList.isEmpty) {
      return null;
    }
    switch (cycleType) {
      case CycleType.queue || CycleType.one:
        index--;
        if (index < 0) {
          index = songList.length - 1;
        }
        break;
      case CycleType.random:
        if (songList.length > 2) {
          index = Random().nextInt(songList.length);
        } else {
          index--;
          if (index < 0) {
            index = songList.length - 1;
          }
        }
        break;
    }
    return songList[index];

  }

  /// 获取随机的下一条音频数据
  SlAudioModel? randomNext() {
    if (songList.isEmpty) {
      return null;
    }
    int rdmIndex = 0;
    if (songList.length > 1) {
      rdmIndex = Random().nextInt(songList.length);
      if (rdmIndex == index) {
        // 如果和当前index相同，就+1。
        rdmIndex++;
        if (rdmIndex >= songList.length) {
          rdmIndex = 0;
        }
      }
    }
    index = rdmIndex;
    return songList[index];
  }

  /// 切换列表的循环模式，顺序播放、单曲循环、随机播放。
  void changCycleType() {
    switch (cycleType) {
      case CycleType.queue:
        cycleType = CycleType.one;
        break;
      case CycleType.one:
        cycleType = CycleType.random;
        break;
      case CycleType.random:
        cycleType = CycleType.queue;
        break;
    }
  }

  String getCycleName() {
    String cycleName;
    switch(cycleType) {
      case CycleType.queue: cycleName = '顺序播放';break;
      case CycleType.one: cycleName = '单曲循环';break;
      case CycleType.random: cycleName = '随机播放';break;
    }
    return cycleName;
  }
}
