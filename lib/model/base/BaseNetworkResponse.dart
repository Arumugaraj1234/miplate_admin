class BaseNetworkResponse {


  /*
    "Code": 1,
    "Message": "success",
    "Data":*/

    int Code;
    String Message;
    String Data;
    String ImageURL;

    BaseNetworkResponse({this.Code, this.Message, this.Data, this.ImageURL});


    factory BaseNetworkResponse.fromJson(Map<String, dynamic> json) {
        return BaseNetworkResponse(
            Code: json['Code'],
            Message: json['Message'],
            Data: json['Data'],
            ImageURL:json['ImageURL']
        );
    }

}