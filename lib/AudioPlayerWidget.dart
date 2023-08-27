import 'package:flutter/material.dart';
import 'package:play_audio/core/models/SLAudioModel.dart';
import 'package:play_audio/core/utils/Logger.dart';
import 'package:provider/provider.dart';

import 'core/services/PlaybackController.dart';

class AudioPlayerWidget extends StatefulWidget{
  const AudioPlayerWidget({super.key});

  @override
  State createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>{

  // 创建一些假数据，用于测试。
  final List<SlAudioModel> audioGroup = [
    SlAudioModel(title: "Song 1", playUrl: "https://cloud.seatable.cn/seafhttp/files/86678244-f503-4671-a832-e50a18eff923/Emily%20Hearn%20-%20I%E2%80%99m%20Fine.mp3"),
    SlAudioModel(title: "Song 2", playUrl: "https://lh-sycdn.kuwo.cn/93d630e1d006d068cdf515477a4b944c/64e8a8dd/resource/n1/24/83/805920657.mp3"),
    SlAudioModel(title: "Song 3", playUrl: "https://lk-sycdn.kuwo.cn/61fcce8dacf3e5f1354249137232cdbf/64e8a82e/resource/n2/7/64/655420780.mp3"),
    SlAudioModel(title: "Song 4", playUrl: "https://lk-sycdn.kuwo.cn/2b0924b01b36bd2a372c9ddd72c5aeae/64e8a843/resource/n3/36/48/4080861161.mp3"),
    SlAudioModel(title: "Song 5", playUrl: "https://lj-sycdn.kuwo.cn/920b2a6eceb78094829cc23cd2c405a8/64e8a8a8/resource/n1/95/57/3577134560.mp3"),
  ];

  @override
  Widget build(BuildContext context) {

    final playbackController = context.watch<PlaybackController>();

    return Scaffold(
      appBar: AppBar(title: Text('Music Player')),
      body: Column(
        children: [
          // 音乐封面图片显示
          Container(
            width: 300,
            height: 300,
            child: Image.asset('assets/audio/images/play_controll_default_cover_01.png',fit: BoxFit.fill),
          ),

          // 播放列表
          Expanded(child: _PlaylistWidget()),

          // 音频电平可视化
          _AudioLevelWidget(),

          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer<PlaybackController>(builder: (context, PlaybackController playbackController, child) {
                Logger.debug(playbackController.playerState);
                return Text("播放状态");
              }),

              IconButton(icon: Icon(Icons.skip_previous), onPressed: () => context.read<PlaybackController>().previous()),
              IconButton(icon: Icon(Icons.play_arrow), onPressed: () => context.read<PlaybackController>().setPlayList(audioGroup, 0, isPlay: true)),
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
