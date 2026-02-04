import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lead_provider.dart';
import '../models/lead.dart';
import 'add_edit_lead_screen.dart';
import 'lead_details_screen.dart';
import 'dashboard_screen.dart';
import '../widgets/hover_scale_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeadProvider>(context, listen: false).loadLeads();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Dashboard' : 'My Leads'),
      ),
      body: _currentIndex == 0 ? const DashboardScreen() : const LeadsListWithSearch(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Leads',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditLeadScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LeadsListWithSearch extends StatefulWidget {
  const LeadsListWithSearch({super.key});

  @override
  State<LeadsListWithSearch> createState() => _LeadsListWithSearchState();
}

class _LeadsListWithSearchState extends State<LeadsListWithSearch> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search & Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search leads...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                onChanged: (value) {
                  Provider.of<LeadProvider>(context, listen: false).setSearchQuery(value);
                },
              ),
              const SizedBox(height: 12),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Consumer<LeadProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      children: [
                        _buildFilterChip(context, 'All', null, provider),
                        ...LeadStatus.values.map((status) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _buildFilterChip(
                              context, 
                              status.toString().split('.').last, 
                              status, 
                              provider
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: Consumer<LeadProvider>(
            builder: (context, leadProvider, child) {
              if (leadProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final leads = leadProvider.filteredLeads;

              if (leads.isEmpty) {
                return const Center(
                  child: Text(
                    'No leads found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: leads.length,
                itemBuilder: (context, index) {
                  final lead = leads[index];
                  // Staggered Animation Wrapper
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween(begin: 0, end: 1),
                    curve: Interval((1 / leads.length) * index, 1.0, curve: Curves.easeOut),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: HoverScaleCard(
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeadDetailsScreen(lead: lead),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                 CircleAvatar(
                                    backgroundColor: _getStatusColor(lead.status).withOpacity(0.2),
                                    child: Text(
                                      lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        color: _getStatusColor(lead.status),
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lead.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          lead.phone,
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(lead.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      lead.status.toString().split('.').last,
                                      style: TextStyle(
                                        color: _getStatusColor(lead.status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, LeadStatus? status, LeadProvider provider) {
    final isSelected = provider.filterStatus == status;
    return FilterChip(
      label: Text(label.toUpperCase()),
      selected: isSelected,
      onSelected: (bool selected) {
        provider.setFilterStatus(selected ? status : null);
      },
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2),
        ),
      ),
      showCheckmark: false,
    );
  }

  Color _getStatusColor(LeadStatus status) {
    switch (status) {
      case LeadStatus.newLead:
        return Colors.blue;
      case LeadStatus.contacted:
        return Colors.orange;
      case LeadStatus.qualified:
        return Colors.purple;
      case LeadStatus.converted:
        return Colors.green;
      case LeadStatus.lost:
        return Colors.red;
    }
  }
}
