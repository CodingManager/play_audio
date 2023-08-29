/// MusicListener类是一个音乐播放器的监听器，用于监听音乐播放的不同状态和事件。该类是一个音乐播放器的监听器，它包含了一系列回调函数，用于监听音乐播放过程中的不同状态和事件。通过在不同的回调函数中传入相应的处理逻辑，可以实现对音乐播放过程中不同阶段的监听和处理。例如，在音乐加载过程中、音乐开始播放、音乐播放位置变化、音乐播放状态变化以及音乐播放发生错误时，可以通过回调函数实现相应的逻辑处理。通过添加这些回调函数，可以使音乐播放器具有更好的交互性和扩展性，方便在不同场景下对音乐播放过程进行自定义处理。
class MusicListener {
  /// 以下是不同的回调函数，用于监听不同的音乐播放事件。

  /// getName是一个回调函数，用于获取音乐的名称。
  Function? getName;

  /// onLoading是一个回调函数，用于在音乐加载过程中通知监听者。
  Function? onLoading;

  /// onStart是一个回调函数，用于在音乐开始播放时通知监听者。
  Function? onStart;

  /// onPosition是一个回调函数，用于在音乐播放过程中通知监听者当前的播放位置。
  Function? onPosition;

  /// onStateChanged是一个回调函数，用于在音乐播放状态发生变化时通知监听者。
  Function? onStateChanged;

  /// onError是一个回调函数，用于在音乐播放发生错误时通知监听者。
  Function? onError;

  /// MusicListener的构造函数，用于创建一个新的监听器对象。
  MusicListener({
    this.getName,
    this.onLoading,
    this.onStart,
    this.onPosition,
    this.onStateChanged,
    this.onError,
  });
}
