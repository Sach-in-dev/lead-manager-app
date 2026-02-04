import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lead.dart';

class StorageService {
  static const String _leadsKey = 'leads_data';

  Future<void> saveLeads(List<Lead> leads) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(leads.map((e) => e.toJson()).toList());
    await prefs.setString(_leadsKey, encodedData);
  }

  Future<List<Lead>> loadLeads() async {
    final prefs = await SharedPreferences.getInstance();
    final String? leadsString = prefs.getString(_leadsKey);

    if (leadsString == null) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(leadsString);
    return jsonList.map((e) => Lead.fromJson(e)).toList();
  }
}
