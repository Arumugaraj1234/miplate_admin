import 'package:flutter/material.dart';

class DishDetailModel {
  int id;
  String imageLink;
  String name;
  String region;
  VegOrNonVeg vegOrNonVegType;
  String category;
  double price;
  int count;
  String dishSize;
  bool isSelected;
  String hintDetails;
  bool isFavorite;

  DishDetailModel(
      {this.id,
      this.imageLink,
      this.name,
      this.region,
      this.vegOrNonVegType,
      this.category,
      this.price,
      this.count,
      this.dishSize,
      this.isSelected,
      this.hintDetails,
      this.isFavorite});

  double get totalPrice => price * count;
}

enum VegOrNonVeg { veg, nonVeg }
