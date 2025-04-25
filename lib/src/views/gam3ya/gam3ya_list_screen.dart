// screens/gam3ya/gam3ya_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/controllers/gam3ya_provider.dart';
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:gam3ya/src/widgets/animations/fade_animation.dart';
import 'package:gam3ya/src/widgets/common/error_widget.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
import 'package:gam3ya/src/widgets/gam3ya/gam3ya_card.dart';

class Gam3yaListScreen extends ConsumerStatefulWidget {
  const Gam3yaListScreen({super.key});

  @override
  ConsumerState<Gam3yaListScreen> createState() => _Gam3yaListScreenState();
}

class _Gam3yaListScreenState extends ConsumerState<Gam3yaListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterQuery = '';
  Gam3yaDuration? _selectedDuration;
  Gam3yaSize? _selectedSize;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Fetch gam3yas when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gam3yasNotifierProvider.notifier).loadAllGam3yas();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Gam3yas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by name',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filterQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Duration:'),
                Wrap(
                  spacing: 8.0,
                  children: [
                    FilterChip(
                      label: const Text('Monthly'),
                      selected: _selectedDuration == Gam3yaDuration.monthly,
                      onSelected: (selected) {
                        setState(() {
                          _selectedDuration = selected ? Gam3yaDuration.monthly : null;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Quarterly'),
                      selected: _selectedDuration == Gam3yaDuration.quarterly,
                      onSelected: (selected) {
                        setState(() {
                          _selectedDuration = selected ? Gam3yaDuration.quarterly : null;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Yearly'),
                      selected: _selectedDuration == Gam3yaDuration.yearly,
                      onSelected: (selected) {
                        setState(() {
                          _selectedDuration = selected ? Gam3yaDuration.yearly : null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Size:'),
                Wrap(
                  spacing: 8.0,
                  children: [
                    FilterChip(
                      label: const Text('Small'),
                      selected: _selectedSize == Gam3yaSize.small,
                      onSelected: (selected) {
                        setState(() {
                          _selectedSize = selected ? Gam3yaSize.small : null;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Medium'),
                      selected: _selectedSize == Gam3yaSize.medium,
                      onSelected: (selected) {
                        setState(() {
                          _selectedSize = selected ? Gam3yaSize.medium : null;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Large'),
                      selected: _selectedSize == Gam3yaSize.large,
                      onSelected: (selected) {
                        setState(() {
                          _selectedSize = selected ? Gam3yaSize.large : null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filterQuery = '';
                          _selectedDuration = null;
                          _selectedSize = null;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Apply filter
                        ref.read(gam3yaFilterProvider.notifier).state = (
                          query: _filterQuery,
                          duration: _selectedDuration,
                          size: _selectedSize,
                        );
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Gam3ya> _filterGam3yas(List<Gam3ya> gam3yas, int tabIndex) {
    final filter = ref.watch(gam3yaFilterProvider);
    
    // First filter by tab
    List<Gam3ya> filteredList;
    switch (tabIndex) {
      case 0: // All
        filteredList = gam3yas;
        break;
      case 1: // Active
        filteredList = gam3yas.where((g) => g.status == Gam3yaStatus.active).toList();
        break;
      case 2: // Pending
        filteredList = gam3yas.where((g) => g.status == Gam3yaStatus.pending).toList();
        break;
      default:
        filteredList = gam3yas;
    }
    
    // Apply search filter
    if (filter.query.isNotEmpty) {
      filteredList = filteredList
          .where((g) => g.name.toLowerCase().contains(filter.query.toLowerCase()))
          .toList();
    }
    
    // Apply duration filter
    if (filter.duration != null) {
      filteredList = filteredList
          .where((g) => g.duration == filter.duration)
          .toList();
    }
    
    // Apply size filter
    if (filter.size != null) {
      filteredList = filteredList
          .where((g) => g.size == filter.size)
          .toList();
    }
    
    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    final gam3yas = ref.watch(gam3yasProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gam3yas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: gam3yas.when(
        data: (data) => TabBarView(
          controller: _tabController,
          children: [0, 1, 2].map((tabIndex) {
            final filteredGam3yas = _filterGam3yas(data, tabIndex);
            
            if (filteredGam3yas.isEmpty) {
              return const Center(
                child: Text('No Gam3yas found'),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredGam3yas.length,
              itemBuilder: (context, index) {
                print ("$index");
                return FadeAnimation(
                  delay: Duration(milliseconds: index),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Gam3yaCard(
                      gam3ya: filteredGam3yas[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/gam3ya/details',
                          arguments: filteredGam3yas[index].id,
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorDisplayWidget(
          message: 'Failed to load Gam3yas: $error',
          onRetry: () => ref.read(gam3yasNotifierProvider.notifier).loadAllGam3yas(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/gam3ya/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Define a simple filter class
class Gam3yaFilter {
  final String query;
  final Gam3yaDuration? duration;
  final Gam3yaSize? size;
  
  const Gam3yaFilter({
    this.query = '',
    this.duration,
    this.size,
  });
}

// Create a provider for filters
final gam3yaFilterProvider = StateProvider<({
  String query,
  Gam3yaDuration? duration,
  Gam3yaSize? size,
})>((ref) => (
  query: '',
  duration: null,
  size: null,
));