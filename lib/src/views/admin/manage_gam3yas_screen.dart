// screens/admin/manage_gam3yas_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:gam3ya/src/widgets/animations/fade_animation.dart';
import 'package:gam3ya/src/widgets/common/error_widget.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';

import '../../controllers/gam3ya_provider.dart';
import '../../models/enum_models.dart';

class ManageGam3yasScreen extends ConsumerStatefulWidget {
  const ManageGam3yasScreen({super.key});

  @override
  ConsumerState<ManageGam3yasScreen> createState() =>
      _ManageGam3yasScreenState();
}

class _ManageGam3yasScreenState extends ConsumerState<ManageGam3yasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Gam3yaStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load gam3yas when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gam3yasNotifierProvider.notifier).loadAllGam3yas();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getStatusDisplayName(Gam3yaStatus status) {
    switch (status) {
      case Gam3yaStatus.pending:
        return 'Pending';
      case Gam3yaStatus.active:
        return 'Active';
      case Gam3yaStatus.completed:
        return 'Completed';
      case Gam3yaStatus.rejected:
        return 'Rejected';
      case Gam3yaStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(Gam3yaStatus status) {
    switch (status) {
      case Gam3yaStatus.pending:
        return Colors.orange;
      case Gam3yaStatus.active:
        return Colors.green;
      case Gam3yaStatus.completed:
        return Colors.blue;
      case Gam3yaStatus.rejected:
        return Colors.red;
      case Gam3yaStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilterChip(Gam3yaStatus status) {
    final isSelected = _filterStatus == status;

    return FilterChip(
      label: Text(_getStatusDisplayName(status)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? status : null;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: _getStatusColor(status).withOpacity(0.2),
      checkmarkColor: _getStatusColor(status),
      labelStyle: TextStyle(
        color: isSelected ? _getStatusColor(status) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Gam3yas...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim();
          });
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text(
            'Filter by status:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(Gam3yaStatus.pending),
          const SizedBox(width: 8),
          _buildFilterChip(Gam3yaStatus.active),
          const SizedBox(width: 8),
          _buildFilterChip(Gam3yaStatus.completed),
          const SizedBox(width: 8),
          _buildFilterChip(Gam3yaStatus.rejected),
          const SizedBox(width: 8),
          _buildFilterChip(Gam3yaStatus.cancelled),
          const SizedBox(width: 16),
          if (_filterStatus != null)
            TextButton.icon(
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filter'),
              onPressed: () {
                setState(() {
                  _filterStatus = null;
                });
              },
            ),
        ],
      ),
    );
  }

  List<Gam3ya> _filterGam3yas(List<Gam3ya> gam3yas) {
    return gam3yas.where((gam3ya) {
      // Filter by search query
      final matchesSearch =
          _searchQuery.isEmpty ||
          gam3ya.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          gam3ya.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by status
      final matchesStatus =
          _filterStatus == null || gam3ya.status == _filterStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Widget _buildGam3yaCard(Gam3ya gam3ya) {
    return FadeAnimation(
      duration: const Duration(milliseconds: 300),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      gam3ya.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(gam3ya.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(gam3ya.status),
                      style: TextStyle(
                        color: _getStatusColor(gam3ya.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                gam3ya.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: ${gam3ya.amount.toStringAsFixed(2)} EGP'),
                      Text(
                        'Members: ${gam3ya.members.length}/${gam3ya.totalMembers}',
                      ),
                      Text(
                        'Start Date: ${DateFormat('dd/MM/yyyy').format(gam3ya.startDate)}',
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration: ${gam3ya.duration.toString().split('.').last}',
                      ),
                      Text(
                        'Access: ${gam3ya.access.toString().split('.').last}',
                      ),
                      Text('Min Reputation: ${gam3ya.minRequiredReputation}'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // View Details Button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('Details'),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/gam3ya/details',
                        arguments: gam3ya.id,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Status management buttons
                  if (gam3ya.status == Gam3yaStatus.pending)
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            _showApprovalDialog(gam3ya);
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            _showRejectionDialog(gam3ya);
                          },
                        ),
                      ],
                    ),
                  // For active Gam3yas
                  if (gam3ya.status == Gam3yaStatus.active)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: () {
                        _showCancellationDialog(gam3ya);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApprovalDialog(Gam3ya gam3ya) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Approve Gam3ya'),
            content: Text('Are you sure you want to approve "${gam3ya.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  ref
                      .read(gam3yasNotifierProvider.notifier)
                      .updateGam3yaStatus(gam3ya.id, Gam3yaStatus.active);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Gam3ya "${gam3ya.name}" has been approved',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Approve'),
              ),
            ],
          ),
    );
  }

  void _showRejectionDialog(Gam3ya gam3ya) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Gam3ya'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure you want to reject "${gam3ya.name}"?'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for rejection',
                    hintText: 'Provide a reason for rejection',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  ref
                      .read(gam3yasNotifierProvider.notifier)
                      .updateGam3yaStatus(
                        gam3ya.id,
                        Gam3yaStatus.rejected,
                        //reason: reasonController.text,
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Gam3ya "${gam3ya.name}" has been rejected',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  void _showCancellationDialog(Gam3ya gam3ya) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Gam3ya'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure you want to cancel "${gam3ya.name}"?'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for cancellation',
                    hintText: 'Provide a reason for cancellation',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  ref
                      .read(gam3yasNotifierProvider.notifier)
                      .updateGam3yaStatus(
                        gam3ya.id,
                        Gam3yaStatus.cancelled,
                        // reason: reasonController.text,
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Gam3ya "${gam3ya.name}" has been cancelled',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: const Text('Cancel Gam3ya'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gam3yasState = ref.watch(gam3yasProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(color: Colors.white),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterSection(),
          const Divider(),
          Expanded(
            child: gam3yasState.when(
              data: (gam3yas) {
                // Filter gam3yas based on tab, search query and filter
                List<Gam3ya> filteredGam3yas;

                switch (_tabController.index) {
                  case 1: // Pending tab
                    filteredGam3yas =
                        gam3yas
                            .where((g) => g.status == Gam3yaStatus.pending)
                            .toList();
                    break;
                  case 2: // Active tab
                    filteredGam3yas =
                        gam3yas
                            .where((g) => g.status == Gam3yaStatus.active)
                            .toList();
                    break;
                  default: // All tab
                    filteredGam3yas = gam3yas;
                }

                // Apply additional filters
                filteredGam3yas = _filterGam3yas(filteredGam3yas);

                if (filteredGam3yas.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Gam3yas found with current filters',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: List.generate(3, (index) {
                    // We'll use the same list but filter differently based on tab
                    List<Gam3ya> tabFilteredGam3yas;

                    switch (index) {
                      case 1: // Pending tab
                        tabFilteredGam3yas =
                            filteredGam3yas
                                .where((g) => g.status == Gam3yaStatus.pending)
                                .toList();
                        break;
                      case 2: // Active tab
                        tabFilteredGam3yas =
                            filteredGam3yas
                                .where((g) => g.status == Gam3yaStatus.active)
                                .toList();
                        break;
                      default: // All tab
                        tabFilteredGam3yas = filteredGam3yas;
                    }

                    if (tabFilteredGam3yas.isEmpty) {
                      return const Center(
                        child: Text(
                          'No Gam3yas found in this category',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: tabFilteredGam3yas.length,
                      itemBuilder:
                          (context, i) =>
                              _buildGam3yaCard(tabFilteredGam3yas[i]),
                    );
                  }),
                );
              },
              loading:
                  () => const Center(
                    child: LoadingIndicator(message: 'Loading Gam3yas...'),
                  ),
              error:
                  (error, stackTrace) => ErrorDisplayWidget(
                    message: error.toString(),
                    onRetry:
                        () =>
                            ref
                                .read(gam3yasNotifierProvider.notifier)
                                .loadAllGam3yas(),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refresh the list
          ref.read(gam3yasNotifierProvider.notifier).loadAllGam3yas();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Refreshing Gam3yas list...')),
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
