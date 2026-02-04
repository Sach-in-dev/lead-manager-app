import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/lead.dart';
import '../providers/lead_provider.dart';
import 'add_edit_lead_screen.dart';

class LeadDetailsScreen extends StatelessWidget {
  final Lead lead;

  const LeadDetailsScreen({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    // Re-fetch lead from provider to ensure we have the latest version (if updated)
    // Using select is cleaner but for simplicity we'll just consume the provider or use the passed lead object
    // with a Consumer to listen for updates.
    
    return Consumer<LeadProvider>(
      builder: (context, leadProvider, child) {
        // Find the lead in the provider list by ID
        final currentLead = leadProvider.leads.firstWhere(
          (l) => l.id == lead.id,
          orElse: () => lead, // Fallback if deleted (should navigate back ideally)
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(currentLead.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditLeadScreen(lead: currentLead),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmation(context, leadProvider, currentLead);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(currentLead),
                const SizedBox(height: 20),
                _buildDetailRow(Icons.phone, 'Phone', currentLead.phone),
                const Divider(),
                _buildDetailRow(Icons.email, 'Email', currentLead.email),
                const Divider(),
                _buildDetailRow(Icons.calendar_today, 'Date Created', 
                  DateFormat.yMMMd().format(currentLead.dateCreated)),
                const Divider(),
                if (currentLead.notes != null && currentLead.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text("Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(currentLead.notes!),
                ],
                const SizedBox(height: 24),
                const Text("History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentLead.history.length,
                  itemBuilder: (context, index) {
                    final activity = currentLead.history[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (index != currentLead.history.length - 1)
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.description,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  DateFormat('MMM d, h:mm a').format(activity.timestamp),
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Lead lead) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blueGrey,
            child: Text(
              lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue),
            ),
            child: Text(
              lead.status.toString().split('.').last.toUpperCase(),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, LeadProvider provider, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lead'),
        content: Text('Are you sure you want to delete ${lead.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteLead(lead.id);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to list
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
