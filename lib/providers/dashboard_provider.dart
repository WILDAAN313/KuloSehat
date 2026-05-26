import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List diseases = [];
  Map tip = {};
  bool isLoading = true;

  Future<void> fetchData() async {
    try {
      final data = await _api.getDashboard();

      diseases = data["diseases"] ?? [];
      tip = data["tips"] ?? {};
    } catch (e) {
      debugPrint("API Error: $e");
      diseases = [];
      tip = {};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
