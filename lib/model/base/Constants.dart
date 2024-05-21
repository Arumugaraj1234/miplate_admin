import 'package:flutter/material.dart';

class Constants {
  //static String BASE_URL = "https://gurkha-api.azurewebsites.net/api/Admin";
  //static String BASE_URL = "http://64.15.141.244:80/Gurkha/WebApi/api/Admin";
  static String BASE_URL = "https://gurkha-web-api.azurewebsites.net/api/Admin";

  //MARK:- HEADER CONSTANTS

}

const kHeader = {"Content-Type": "application/json"};
//const kBaseUrl = "http://64.15.141.244:80/Gurkha/WebApi/api/Admin/";
//const kBaseUrl = "https://gurkha-api.azurewebsites.net/api/Admin/";
const kBaseUrl = "https://gurkha-web-api.azurewebsites.net/api/Admin/";
const kUrlToSaveTimings = kBaseUrl + 'SaveTiming';
const kUrlToGetToggleStatus = kBaseUrl + 'GetToggle';
const kUrlToUpdateToggleStatus = kBaseUrl + 'UpdateToggle';
const kUrlToCompleteOrder = kBaseUrl + 'CompleteOrder';
const kUrlToGetAllCurrentOrders = kBaseUrl + 'GetAllOrders';
