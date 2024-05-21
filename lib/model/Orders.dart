class Orders {
  /* "order": {
            "order_id": 31,
            "hotel_id": 1,
            "supplier_id": 0,
            "table_id": 0,
            "customer_id": 17,
            "order_type": 2,
            "delivery_address": "57,Killigrew Street,Cornwall,England,TR11 3PW",
            "post_code": null,
            "delivery_lat": 50.153611,
            "delivery_lon": -5.073735,
            "amount": 27.00,
            "discount": 0.00,
            "tax": 0.00,
            "total": 27.00,
            "payment_type": 1,
            "txn_id": null,
            "order_status": 1,
            "payment_status": 0,
            "order_date": "2020-08-07T16:36:28.06",
            "is_print": false,
            "c": "",
            "delivery_time": null
        },*/

  int order_id = 0;
  int hotel_id = 0;
  int supplier_id = 0;
  int table_id = 0;
  int customer_id = 0;
  int order_type = 0;
  String delivery_address = "";
  String post_code = "";
  double delivery_lat = 0;
  double delivery_lon = 0;
  double amount = 0;
  double discount = 0;
  double tax = 0;
  double total = 0;
  int payment_type = 0;
  String txn_id = "";
  String order_status;
  String payment_status;
  String order_date;
  String is_print = "";
  String c = "";
  String delivery_time = "";
  DateTime time;

  Orders(
      {this.order_id,
      this.hotel_id,
      this.supplier_id,
      this.table_id,
      this.customer_id,
      this.order_type,
      this.delivery_address,
      this.post_code,
      this.delivery_lat,
      this.delivery_lon,
      this.amount,
      this.discount,
      this.tax,
      this.total,
      this.payment_type,
      this.txn_id,
      this.order_status,
      this.payment_status,
      this.order_date,
      this.is_print,
      this.c,
      this.delivery_time,
      this.time});
}
