import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:play_audio/core/models/SLAudioModel.dart';
import 'package:play_audio/core/utils/Logger.dart';
import 'package:play_audio/core/utils/MusicListener.dart';
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
  late PlaybackController _playbackController;
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
    // context.read<PlaybackController>().addMusicListener(MusicListener(
    //   onPosition: (){
    //
    //   }
    // ));

    _playbackController = context.read<PlaybackController>();

  }

  // 创建一些假数据，用于测试。
  final List<SlAudioModel> audioGroup = [
    SlAudioModel(title: "向云端", playUrl: "https://6v05y2726.goho.co/static/media/audios/21/xiangyunduan.mp3"),
    SlAudioModel(title: "Song 3", playUrl: "https://6v05y2726.goho.co/static/media/audios/20/a1.mp3"),
    SlAudioModel(title: "Song 4", playUrl: "https://6v05y2726.goho.co/static/media/audios/20/a2.mp3"),
    SlAudioModel(title: "Song 5", playUrl: "https://6v05y2726.goho.co/static/media/audios/20/a3.mp3"),
    SlAudioModel(title: "Song 6", playUrl: "https://6v05y2726.goho.co/static/media/audios/20/a4.mp3"),
    SlAudioModel(title: "Song 7", playUrl: "https://6v05y2726.goho.co/static/media/audios/20/a5.mp3"),
    SlAudioModel(title: "Song 8", playUrl: "https://6v05y2726.goho.co/static/media/audios/20/a6.mp3"),
    // SlAudioModel(title: "Song 6", playUrl: "https://6v05y2726.goho.co/static/media/audios/21/2022120519422118e8d.mp3"),
    // SlAudioModel(title: "Song 6", playUrl: "https://6v05y2726.goho.co/static/media/audios/21/2022120519422112dfe.mp3"),
    // SlAudioModel(title: "Song 6", playUrl: "https://6v05y2726.goho.co/static/media/audios/21/2022120519422114e23.mp3"),
    // SlAudioModel(title: "Song 6", playUrl: "https://6v05y2726.goho.co/static/media/audios/21/2022120519422118e8d.mp3"),

   ];
  // AudioSource.uri(Uri.parse('https://6v05y2726.goho.co/static/media/audios/21/xiangyunduan.mp3')),
  // AudioSource.uri(Uri.parse('https://6v05y2726.goho.co/static/media/audios/21/2022120519422118e8d.mp3')),
  // AudioSource.uri(Uri.parse('https://6v05y2726.goho.co/static/media/audios/21/2022120519422114e23.mp3')),
  // AudioSource.uri(Uri.parse('https://6v05y2726.goho.co/static/media/audios/21/2022120519422112dfe.mp3')),
  // AudioSource.uri(Uri.parse('https://6v05y2726.goho.co/static/media/audios/21/2022120519422118e8d.mp3')),


  Widget loadingWidget() {

    return Consumer<PlaybackController>(builder: (context, PlaybackController playbackController, child) {
      switch (playbackController.playerState) {
        case SLPlayerState.loading:
          _animationController.repeat();
          return CircularProgressIndicator(color: Colors.yellow, strokeWidth: 2.0);
        case SLPlayerState.stopped || SLPlayerState.paused || SLPlayerState.completed:
          _animationController.stop();
        case SLPlayerState.playing:
          _animationController.repeat();
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
          Expanded(child: _buildPlayerListWidget()),

          // 音频电平可视化
          _AudioLevelWidget(),

          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: Icon(Icons.skip_previous), onPressed: () {
                _playbackController.previous();
                SlAudioModel mode = audioGroup[_playbackController.playIndex];
                Logger.debug('播放上一首: ${mode.title}');
              }),
              IconButton(icon: Icon(Icons.play_arrow), onPressed: (){
                _playbackController.play();
                SlAudioModel mode = audioGroup[_playbackController.playIndex];
                Logger.debug('播放: ${mode.title}');
              }),
              IconButton(icon: Icon(Icons.pause), onPressed: () => _playbackController.pause()),
              IconButton(icon: Icon(Icons.stop), onPressed: () => _playbackController.stop()),
              IconButton(icon: Icon(Icons.skip_next), onPressed: (){
                _playbackController.next();
                SlAudioModel mode = audioGroup[_playbackController.playIndex];
                Logger.debug('播放下一首: ${mode.title}');
              }),
            ],
          ),

          // 音量控制
          Consumer<PlaybackController>(builder: (context, PlaybackController playbackController, child) {

            return Slider(
              value: playbackController.progress,
              onChanged: (double value) {

                int millSeconds = (value * playbackController.totalDurationInMilliseconds).toInt();

                playbackController.seek(millSeconds);
                Logger.debug('onChanged: $millSeconds');
            },
            );
          }),

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

  Widget _buildPlayerListWidget() {
    ListView listView = ListView.builder(
      itemCount: audioGroup.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(audioGroup[index].title!),
          onTap: () {
            _playbackController.setPlayListWithPlay(audioGroup, 0, playIndex: index);
            SlAudioModel mode = audioGroup[_playbackController.playIndex];
            Logger.debug('播放: ${mode.title}');
            // context.read<PlaybackController>().play();
          },
        );
      },
    );

    return listView;
  }

}



class _AudioLevelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    context.read<PlaybackController>().addMusicListener(MusicListener(
      getName: (){
        Logger.debug("播放的名字");
      }
    ));
    // 这里你可以使用 flutter_sound 或其他库来实现音频电平的可视化
    return Container(
      height: 50,
      color: Colors.grey,
      child: Center(child: Text('Audio Level Visualization')),
    );
  }
}
