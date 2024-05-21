
class Timings {


  /* "meal_id": 1,
        "hotel_id": 1,
        "name": "Breakfast",
        "start_time": "00:00:00",
        "end_time": "23:00:00",
        "flg": 1,
        "created_date": "2020-01-14T00:00:00",
        "created_user_id": 1*/

  int meal_id;
  int hotel_id;
  String name;
  String start_time;
  String end_time;
  int flg;
  String created_date;
  int created_user_id;
  bool selected = false;

  Timings({this.meal_id,this.hotel_id,this.name,this.start_time,this.end_time,
    this.flg,this.created_date,this.created_user_id});

  factory Timings.toJson(Map<String, dynamic> json) {
    return Timings(

        meal_id: json['meal_id'],
      hotel_id: json['hotel_id'],
      name: json['name'],
      start_time: json['start_time'],
      end_time:json['end_time'],
      flg:json['flg'],
      created_date:json['created_date'],
      created_user_id: json['created_user_id']
    );
  }

  factory Timings.fromJson(Map<String, dynamic> json) {
    return Timings(

        meal_id: json['meal_id'],
      hotel_id: json['hotel_id'],
      name: json['name'],
      start_time: json['start_time'],
      end_time:json['end_time'],
      flg:json['flg'],
      created_date:json['created_date'],
      created_user_id: json['created_user_id']
    );
  }
}