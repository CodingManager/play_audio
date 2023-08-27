
class SlAudioModel {
  SlAudioModel({
      this.id, 
      this.title,
      this.fileType, 
      this.duration, 
      this.fileSize, 
      this.createTime, 
      this.userId, 
      this.authorName, 
      this.tags, 
      this.vip, 
      this.playUrl, 
      this.playCount,
      this.coverImg, 
      this.collectCount,
      this.isCollection,
  });

  SlAudioModel.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['name'];
    fileType = json['file_type'];
    duration = json['duration'];
    fileSize = json['file_size'];
    createTime = json['create_time'];
    authorName = json['author_name'];
    vip = json['vip'];

    playUrl = json['play_url'];


    coverImg = json['cover_img'];
    // 判断 tags 类型是否为 List<String>     // 把 tags "tags" -> [_GrowableList] 转换成 List<String>，否则会报错
    if (json['tags'] is List) {
      tags = json['tags'].cast<String>();
    } else {
      tags = [];
    }
    playCount = json['play_count'];
    collectCount = json['collect_count'];
    likeCount = json['like_count'];
    isCollection = json['is_collect'];
    coverImg = json['cover_img'];
  }
  int? id;
  String? title;
  int? fileType;
  double? duration;
  int? fileSize;
  String? createTime;
  String? userId;
  String? authorName;
  List<String>? tags;
  bool? vip;
  String? playUrl;
  String? coverImg;
  int? playCount;
  int? collectCount;
  int? likeCount;
  bool? isCollection;
  bool isSelect = false;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['file_type'] = fileType;
    map['duration'] = duration;
    map['file_size'] = fileSize;
    map['create_time'] = createTime;
    map['user_id'] = userId;
    map['author_name'] = authorName;
    map['tags'] = tags;
    map['vip'] = vip;
    map['play_url'] = playUrl;
    map['play_count'] = playCount;
    map['cover_img'] = coverImg;
    map['collect_count'] = collectCount;
    map['is_collection'] = isCollection;
    map['cover_url'] = coverImg;
    map['like_count'] = likeCount;
    return map;
  }

}