import 'package:flutter/foundation.dart';

class LoadingService extends ChangeNotifier {
  int _activeRequests = 0;

  int get activeRequests => _activeRequests;
  bool get isLoading => _activeRequests > 0;

  void startLoading() {
    _activeRequests++;
    notifyListeners();
  }

  void stopLoading() {
    if (_activeRequests > 0) {
      _activeRequests--;
      notifyListeners();
    }
  }

  void reset() {
    if (_activeRequests != 0) {
      _activeRequests = 0;
      notifyListeners();
    }
  }
}
