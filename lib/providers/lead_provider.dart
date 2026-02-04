import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lead.dart';
import '../services/storage_service.dart';

class LeadProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Lead> _leads = [];
  bool _isLoading = false;
  String _searchQuery = '';
  LeadStatus? _filterStatus;
  bool _isDarkMode = false;

  List<Lead> get leads => _leads;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  LeadStatus? get filterStatus => _filterStatus;
  bool get isDarkMode => _isDarkMode;

  List<Lead> get filteredLeads {
    return _leads.where((lead) {
      final matchesSearch = lead.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lead.phone.contains(_searchQuery);
      final matchesStatus = _filterStatus == null || lead.status == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Stats Getters
  int get totalLeads => _leads.length;
  int get newLeadsCount => _leads.where((l) => l.status == LeadStatus.newLead).length;
  int get contactedLeadsCount => _leads.where((l) => l.status == LeadStatus.contacted).length;
  int get qualifiedLeadsCount => _leads.where((l) => l.status == LeadStatus.qualified).length;
  int get convertedLeadsCount => _leads.where((l) => l.status == LeadStatus.converted).length;
  int get lostLeadsCount => _leads.where((l) => l.status == LeadStatus.lost).length;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(LeadStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> loadLeads() async {
    _isLoading = true;
    notifyListeners();
    try {
      _leads = await _storageService.loadLeads();
      // Load theme preference (simple implementation via SharedPreferences directly or through StorageService)
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    } catch (e) {
      print("Error loading leads: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> addLead(Lead lead) async {
    lead.addActivity('Lead created');
    _leads.add(lead);
    notifyListeners();
    await _storageService.saveLeads(_leads);
  }

  Future<void> updateLead(Lead updatedLead) async {
    final index = _leads.indexWhere((lead) => lead.id == updatedLead.id);
    if (index != -1) {
      final oldLead = _leads[index];
      
      // Auto-log status changes
      if (oldLead.status != updatedLead.status) {
        updatedLead.addActivity('Status changed from ${oldLead.status.toString().split('.').last} to ${updatedLead.status.toString().split('.').last}');
      }
      
      _leads[index] = updatedLead;
      notifyListeners();
      await _storageService.saveLeads(_leads);
    }
  }

  Future<void> deleteLead(String id) async {
    _leads.removeWhere((lead) => lead.id == id);
    notifyListeners();
    await _storageService.saveLeads(_leads);
  }
}
