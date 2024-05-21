class Category {


  /*{
    "Code": 1,
    "Message": "success",
    "Data": {
        "category_id": 1,
        "name": "Starters",
        "icon": "category1.png",
        "hotel_id": 1,
        "flg": 1,
        "created_date": "2020-04-04T00:00:00",
        "created_user_id": 1
    },
    "ImageURL": "http://64.15.141.244/Hotel/Dashboard/Images/Category/"
}*/

  int category_id;
  String name;
  String icon;
  int hotel_id;
  int flg;
  String created_date;
  int created_user_id;
  String ImageURL;
  bool selected = false;

  Category({this.category_id,this.name,this.icon,this.hotel_id,this.flg,this.created_date,this.created_user_id,
    this.ImageURL,this.selected});

  factory Category.toJson(Map<String, dynamic> json) {
    return Category(

      category_id: json['category_id'],
      name: json['name'],
      icon: json['icon'],
      hotel_id: json['hotel_id'],
      flg: json['flg'],
      created_date:json['created_date'],
      created_user_id:json['created_user_id'],
      ImageURL:json['ImageURL'],
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        category_id: json['category_id'],
        name: json['name'],
        icon: json['icon'],
        hotel_id: json['hotel_id'],
        flg: json['flg'],
        created_date:json['created_date'],
        created_user_id:json['created_user_id'],
        ImageURL:json['ImageURL']
    );
  }
}