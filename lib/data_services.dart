import 'package:flutter/cupertino.dart';
import 'package:miplate/model/toggle_model.dart';
import 'package:provider/provider.dart';
import 'package:miplate/model/order_details_model.dart';

class DataServices with ChangeNotifier {
  List<OrderDetailsModel> _currentOrders = [];

  List<OrderDetailsModel> get currentOrders => _currentOrders;

  void setCurrentOrders(List<OrderDetailsModel> orders) {
    _currentOrders = orders;
    print(orders);
    notifyListeners();
  }

  void modifyDeliveryTime({int index, String time}) {
    _currentOrders[index].modifiedDeliveryTime = time;
    notifyListeners();
  }

  void increaseCount(int index) {
    _currentOrders[index].noOfTimesClicked++;
    print(_currentOrders[index].noOfTimesClicked);
    notifyListeners();
  }

  void decreaseCount(int index) {
    print(_currentOrders[index].noOfTimesClicked);
    if (_currentOrders[index].noOfTimesClicked > 0) {
      _currentOrders[index].noOfTimesClicked--;
    }
    print(_currentOrders[index].noOfTimesClicked);
    notifyListeners();
  }

  void removeOrderFromCurrentOrder(int index) {
    _currentOrders.removeAt(index);
    notifyListeners();
  }

  List<OrderDetailsModel> _historyOrders = [];
  List<OrderDetailsModel> get historyOrders => _historyOrders;
  void setHistoryOrders(List<OrderDetailsModel> orders) {
    _historyOrders = orders;
    print(_historyOrders);
    notifyListeners();
  }

  ToggleModel _restaurantToggle =
      ToggleModel(name: 'Restaurant', status: 1, id: 1);
  ToggleModel get restaurantToggle => _restaurantToggle;
  void setRestaurantToggle(ToggleModel model) {
    _restaurantToggle = model;
    notifyListeners();
  }

  void updateRestaurantToggleStatus(int flag) {
    _restaurantToggle.status = flag;
    notifyListeners();
  }

  ToggleModel _deliveryToggle = ToggleModel(name: 'Delivery', status: 1, id: 3);
  ToggleModel get deliveryToggle => _deliveryToggle;
  void setDeliveryToggle(ToggleModel model) {
    _deliveryToggle = model;
    notifyListeners();
  }

  void updateDeliveryToggleStatus(int flag) {
    _deliveryToggle.status = flag;
    notifyListeners();
  }

  ToggleModel _collectionToggle =
      ToggleModel(name: 'Collection', status: 1, id: 2);
  ToggleModel get collectionToggle => _collectionToggle;
  void setCollectionToggle(ToggleModel model) {
    _collectionToggle = model;
    notifyListeners();
  }

  void updateCollectionToggleStatus(int flag) {
    _collectionToggle.status = flag;
    notifyListeners();
  }
}
