class ImageClass {
  String id, url, title, user_id_creator;
  ImageClass(this.id, this.url, this.title, this.user_id_creator);
  ImageClass.fromJson(Map<String, dynamic> json)
    :
      id = json['_id'],
      url = json['url'],
      title = json['title'],
      user_id_creator = json['user_id_creator']
    ;

  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'url': url,
      'title': title,
      'user_id_creator': user_id_creator,
    };
}

//class ImagesClass {
//  List<ImageClass> images;

//  //ImagesClass.fromJson(Map<String, dynamic> json)
//  //  :
//  //    id = json['_id'],
//  //    url = json['url'],
//  //    title = json['title'],
//  //    user_id_creator = json['user_id_creator'],
//  //  ;
//}
