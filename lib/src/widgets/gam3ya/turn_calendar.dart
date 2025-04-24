// widgets/gam3ya/turn_calendar.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:intl/intl.dart';

class TurnCalendar extends StatefulWidget {
  final Gam3ya gam3ya;
  final String currentUserId;
  final Map<String, String> memberNames;
  final bool showDetailedView;

  const TurnCalendar({
    super.key,
    required this.gam3ya,
    required this.currentUserId,
    required this.memberNames,
    this.showDetailedView = false,
  });

  @override
  State<TurnCalendar> createState() => _TurnCalendarState();
}

class _TurnCalendarState extends State<TurnCalendar> {
  late ScrollController _scrollController;
  int _currentCycleIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentCycle();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentCycle() {
    if (widget.gam3ya.status == Gam3yaStatus.active) {
      // Calculate the current cycle based on today's date
      final now = DateTime.now();
      int monthsSinceStart = (now.year - widget.gam3ya.startDate.year) * 12 +
          now.month - widget.gam3ya.startDate.month;
          
      int cycleInterval;
      switch (widget.gam3ya.duration) {
        case Gam3yaDuration.monthly:
          cycleInterval = 1;
          break;
        case Gam3yaDuration.quarterly:
          cycleInterval = 3;
          break;
        case Gam3yaDuration.yearly:
          cycleInterval = 12;
          break;
      }
      
      _currentCycleIndex = (monthsSinceStart ~/ cycleInterval).clamp(0, widget.gam3ya.totalMembers - 1);
      
      if (_scrollController.hasClients) {
        // Calculate position to scroll to (each card height + padding)
        final double itemHeight = 120.0;
        final double scrollPosition = _currentCycleIndex * itemHeight;
        
        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    }
  }

  DateTime _getCycleDate(int cycleIndex) {
    int monthsToAdd;
    switch (widget.gam3ya.duration) {
      case Gam3yaDuration.monthly:
        monthsToAdd = cycleIndex;
        break;
      case Gam3yaDuration.quarterly:
        monthsToAdd = cycleIndex * 3;
        break;
      case Gam3yaDuration.yearly:
        monthsToAdd = cycleIndex * 12;
        break;
    }
    
    return DateTime(
      widget.gam3ya.startDate.year,
      widget.gam3ya.startDate.month + monthsToAdd,
      widget.gam3ya.startDate.day,
    );
  }
  
  String _getMemberForTurn(int turn) {
    final member = widget.gam3ya.members.firstWhere(
      (m) => m.turnNumber == turn,
      orElse: () => Gam3yaMember(
        userId: 'unknown',
        turnNumber: turn,
        joinDate: DateTime.now(),
      ),
    );
    
    return widget.memberNames[member.userId] ?? 'غير محدد (N/A)';
  }

  bool _isUserTurn(int turn) {
    return widget.gam3ya.members.any(
      (member) => member.userId == widget.currentUserId && member.turnNumber == turn,
    );
  }

  bool _isPastCycle(int cycleIndex) {
    final cycleDate = _getCycleDate(cycleIndex);
    return cycleDate.isBefore(DateTime.now());
  }
  
  bool _isCurrentCycle(int cycleIndex) {
    return cycleIndex == _currentCycleIndex;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.gam3ya.members.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد أعضاء في الجمعية حتى الآن',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'جدول الأدوار',
            style: theme.textTheme.titleLarge,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: widget.gam3ya.totalMembers,
            itemBuilder: (context, index) {
              final turn = index + 1;
              final memberName = _getMemberForTurn(turn);
              final cycleDate = _getCycleDate(index);
              final formattedDate = DateFormat('yyyy/MM/dd').format(cycleDate);
              final isUserTurn = _isUserTurn(turn);
              final isPastCycle = _isPastCycle(index);
              final isCurrentCycle = _isCurrentCycle(index);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TurnCalendarCard(
                  turn: turn,
                  memberName: memberName, 
                  date: formattedDate,
                  amount: widget.gam3ya.amount,
                  isUserTurn: isUserTurn,
                  isPastCycle: isPastCycle,
                  isCurrentCycle: isCurrentCycle,
                  showDetailedView: widget.showDetailedView,
                ).animate()
                  .fadeIn(
                    duration: Duration(milliseconds: 300 + (index * 50)), 
                    delay: Duration(milliseconds: 50 * index)
                  )
                  .slideY(
                    begin: 0.2, 
                    duration: Duration(milliseconds: 300 + (index * 50))
                  ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TurnCalendarCard extends StatelessWidget {
  final int turn;
  final String memberName;
  final String date;
  final double amount;
  final bool isUserTurn;
  final bool isPastCycle;
  final bool isCurrentCycle;
  final bool showDetailedView;

  const TurnCalendarCard({
    super.key,
    required this.turn,
    required this.memberName,
    required this.date,
    required this.amount,
    this.isUserTurn = false,
    this.isPastCycle = false,
    this.isCurrentCycle = false,
    this.showDetailedView = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color cardColor;
    IconData statusIcon;
    
    if (isUserTurn) {
      cardColor = theme.colorScheme.primary.withOpacity(0.15);
      statusIcon = Icons.person;
    } else if (isCurrentCycle) {
      cardColor = theme.colorScheme.tertiary.withOpacity(0.15);
      statusIcon = Icons.calendar_today;
    } else if (isPastCycle) {
      cardColor = Colors.grey.withOpacity(0.1);
      statusIcon = Icons.check_circle_outline;
    } else {
      cardColor = theme.cardTheme.color ?? Colors.white;
      statusIcon = Icons.schedule;
    }
    
    return Card(
      elevation: isCurrentCycle ? 4 : 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUserTurn 
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : isCurrentCycle 
                ? BorderSide(color: theme.colorScheme.tertiary, width: 1.5)
                : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Turn number circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUserTurn
                    ? theme.colorScheme.primary
                    : isCurrentCycle 
                        ? theme.colorScheme.tertiary
                        : theme.disabledColor,
              ),
              child: Center(
                child: Text(
                  turn.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Turn details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    memberName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUserTurn 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  
                  if (showDetailedView) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${amount.toStringAsFixed(2)} ج.م',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Status icon
            CircleAvatar(
              radius: 18,
              backgroundColor: isUserTurn
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : isCurrentCycle 
                      ? theme.colorScheme.tertiary.withOpacity(0.2)
                      : isPastCycle
                          ? Colors.grey.withOpacity(0.2)
                          : Colors.transparent,
              child: Icon(
                statusIcon,
                size: 20,
                color: isUserTurn
                    ? theme.colorScheme.primary
                    : isCurrentCycle 
                        ? theme.colorScheme.tertiary
                        : isPastCycle
                            ? Colors.grey
                            : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}