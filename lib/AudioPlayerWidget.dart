import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:play_audio/core/models/SLAudioModel.dart';
import 'package:play_audio/core/utils/Logger.dart';
import 'package:play_audio/core/utils/PlayerAudioEnum.dart';
import 'package:provider/provider.dart';

import 'core/services/PlaybackController.dart';

class AudioPlayerWidget extends StatefulWidget{
  const AudioPlayerWidget({super.key});

  @override
  State createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with TickerProviderStateMixin {

  // 播放动画控制器
  late final AnimationController _animationController;

  /// 线性动画
  late final Animation<double> _linearAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 创建动画控制器
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    //
    // // 创建线性动画
    _linearAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  // 创建一些假数据，用于测试。
  final List<SlAudioModel> audioGroup = [
    SlAudioModel(title: "香云缎", playUrl: "https://6v05y2726.goho.co/static/media/audios/21/xiangyunduan.mp3"),
    SlAudioModel(title: "Song 3", playUrl: "https://6v05y2726.goho.co/static/audio/1d83e3f9-bd2d-4962-8286-96cfaa0933b3.mp3"),
    SlAudioModel(title: "Song 5", playUrl: "https://6v05y2726.goho.co/static/audio/4fe53f09-e31a-43ca-8134-60807c5045b1.mp3"),
    SlAudioModel(title: "Song 6", playUrl: "https://6v05y2726.goho.co/static/audio/4bcafb48-65e3-4537-941f-faae89434372.mp3"),

   ];


  Widget loadingWidget() {

    return Consumer<PlaybackController>(builder: (context, PlaybackController playbackController, child) {
      switch (playbackController.playerState) {
        case MyPlayerState.loading:
          _animationController.repeat();
          return CircularProgressIndicator(color: Colors.yellow, strokeWidth: 2.0);
        case MyPlayerState.playing:
          _animationController.repeat();
          break;
        case MyPlayerState.paused:
          _animationController.stop();
          break;
        case MyPlayerState.stopped:
          _animationController.stop();
          break;
        default:
          break;
      }
      // 返回一个什么都不显示的widget
      return Container();
    });

  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(title: Text('Music Player')),
      body: Column(
        children: [

          RotationTransition(
            turns: _linearAnimation,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2),
                image: DecorationImage(image: AssetImage('assets/audio/images/play_controll_default_cover_01.png'), fit: BoxFit.fill),
              ),
              child: loadingWidget(),
            ),
          ),
          // 播放列表
          Expanded(child: _PlaylistWidget()),

          // 音频电平可视化
          _AudioLevelWidget(),

          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: Icon(Icons.skip_previous), onPressed: () => context.read<PlaybackController>().previous()),
              IconButton(icon: Icon(Icons.play_arrow), onPressed: () => context.read<PlaybackController>().setPlayList(audioGroup,0, playIndex:0, isPlay: true)),
              IconButton(icon: Icon(Icons.pause), onPressed: () => context.read<PlaybackController>().pause()),
              IconButton(icon: Icon(Icons.stop), onPressed: () => context.read<PlaybackController>().stop()),
              IconButton(icon: Icon(Icons.skip_next), onPressed: () => context.read<PlaybackController>().next()),
            ],
          ),

          // 音量控制
          Slider(
            value: 0.5, // 默认值，你可以根据实际情况进行绑定
            onChanged: (value) => {
              // 实现音量控制
              Logger.debug(value)
            },
          ),

          // 本地下载按钮
          ElevatedButton(
            onPressed: () {
              // 实现下载功能
            },
            child: Text('Download'),
          ),
        ],
      ),
    );
  }

}



class _PlaylistWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 假设你有一个歌曲列表
    List<String> songs = ['Song 1', 'Song 2', 'Song 3'];
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(songs[index]),
          onTap: () {
            // 播放选中的歌曲
          },
        );
      },
    );
  }
}

class _AudioLevelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 这里你可以使用 flutter_sound 或其他库来实现音频电平的可视化
    return Container(
      height: 50,
      color: Colors.grey,
      child: Center(child: Text('Audio Level Visualization')),
    );
  }
}
