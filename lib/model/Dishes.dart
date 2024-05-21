class Dishes {
  /* {
        "dish_id": 1,
        "name": "Idly",
        "icon": "dish1.png",
        "hotel_id": 1,
        "meal_ids": "3,4",
        "category_ids": "1,2,3",
        "rate": 5.00,
        "flg": 1,
        "created_date": "2020-02-01T00:00:00",
        "created_user_id": 1,
        "type": 1,
        "description": "With dfgjdfg"
    },*/

  int dish_id;
  String name;
  String icon;
  int hotel_id;
  String meal_ids;
  String category_ids;
  String rate;
  int flg;
  String created_date;
  int created_user_id;
  int type;
  String description;
  String ImageURL;
  bool selected = false;
  String hintText;

  Dishes(
      {this.dish_id,
      this.name,
      this.icon,
      this.hotel_id,
      this.meal_ids,
      this.category_ids,
      this.rate,
      this.flg,
      this.created_date,
      this.created_user_id,
      this.type,
      this.description,
      this.ImageURL,
      this.hintText});

  factory Dishes.toJson(Map<String, dynamic> json) {
    return Dishes(
        dish_id: json['dish_id'],
        name: json['name'],
        icon: json['icon'],
        hotel_id: json['hotel_id'],
        meal_ids: json['meal_ids'],
        category_ids: json['category_ids'],
        rate: json['rate'],
        flg: json['flg'],
        created_date: json['created_date'],
        created_user_id: json['created_user_id'],
        type: json['type'],
        description: json['description'],
        ImageURL: json['ImageURL'],
        hintText: json['hintText']);
  }

  factory Dishes.fromJson(Map<String, dynamic> json) {
    return Dishes(
        dish_id: json['dish_id'],
        name: json['name'],
        icon: json['icon'],
        hotel_id: json['hotel_id'],
        meal_ids: json['meal_ids'],
        category_ids: json['category_ids'],
        rate: json['rate'],
        flg: json['flg'],
        created_date: json['created_date'],
        created_user_id: json['created_user_id'],
        type: json['type'],
        description: json['description'],
        ImageURL: json['ImageURL'],
        hintText: json['hintText']);
  }
}
