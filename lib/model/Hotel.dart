class Hotel{


  /*"hotel_id": 1,
        "name": "Balti Curries",
        "icon": "hotel1.png",
        "address": "Falmouth",
        "hotel_lat": 0.000000,
        "hotel_lon": 0.000000,
        "total_orders": 0,
        "flg": 1,
        "created_date": "2020-04-04T00:00:00",
        "rating": null,
        "discount_percentage": 10,
        "enable_order": null
*/

  int hotel_id=0;
  String phone_no="";
  String name="";
  String password="";
  String icon="";
  String address;
  String hotel_lat;
  String hotel_lon;
  String total_orders;
  int flg;
  String created_date;
  String rating;
  String discount_percentage;
  String enable_order;


  Hotel({this.phone_no,this.hotel_id,this.name,this.password,this.icon,this.address,
    this.hotel_lat,this.hotel_lon,this.total_orders,this.flg,this.created_date,this.rating,this.discount_percentage,this.enable_order});

}