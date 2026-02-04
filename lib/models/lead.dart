import 'package:uuid/uuid.dart';

enum LeadStatus {
  newLead,
  contacted,
  qualified,
  lost,
  converted
}

class LeadActivity {
  final String id;
  final String description;
  final DateTime timestamp;

  LeadActivity({
    String? id,
    required this.description,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  factory LeadActivity.fromJson(Map<String, dynamic> json) {
    return LeadActivity(
      id: json['id'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Lead {
  final String id;
  String name;
  String phone;
  String email;
  LeadStatus status;
  final DateTime dateCreated;
  String? notes;
  final List<LeadActivity> history;

  Lead({
    String? id,
    required this.name,
    required this.phone,
    required this.email,
    this.status = LeadStatus.newLead,
    DateTime? dateCreated,
    this.notes,
    List<LeadActivity>? history,
  })  : id = id ?? const Uuid().v4(),
        dateCreated = dateCreated ?? DateTime.now(),
        history = history ?? [];

  factory Lead.fromJson(Map<String, dynamic> json) {
    var historyList = json['history'] as List<dynamic>?;
    List<LeadActivity> historyItems = historyList != null
        ? historyList.map((i) => LeadActivity.fromJson(i)).toList()
        : [];

    return Lead(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      status: LeadStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => LeadStatus.newLead,
      ),
      dateCreated: DateTime.parse(json['dateCreated']),
      notes: json['notes'],
      history: historyItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'status': status.toString(),
      'dateCreated': dateCreated.toIso8601String(),
      'notes': notes,
      'history': history.map((x) => x.toJson()).toList(),
    };
  }

  Lead copyWith({
    String? name,
    String? phone,
    String? email,
    LeadStatus? status,
    String? notes,
    List<LeadActivity>? history,
  }) {
    return Lead(
      id: this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      dateCreated: this.dateCreated,
      notes: notes ?? this.notes,
      history: history ?? this.history,
    );
  }
  
  void addActivity(String description) {
    history.insert(0, LeadActivity(description: description));
  }
}
