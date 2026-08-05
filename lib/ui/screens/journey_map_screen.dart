import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/reading_plan_provider.dart';
import '../../theme/app_colors.dart';
import 'reading_plan_browser.dart';

class JourneyMapScreen extends ConsumerStatefulWidget {
  final String planId;
  const JourneyMapScreen({super.key, required this.planId});

  @override
  ConsumerState<JourneyMapScreen> createState() => _JourneyMapScreenState();
}

class _JourneyMapScreenState extends ConsumerState<JourneyMapScreen> {
  late PageController _pageController;
  int _currentWeek = 1;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(readingPlanProvider(widget.planId));
    final theme = Theme.of(context);
    
    if (planState.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.goldAccent)));
    }

    final totalDays = planState.planData.length;
    final totalWeeks = (totalDays / 7).ceil();
    final currentDay = planState.currentDay > 0 ? planState.currentDay : 1;
    final initialWeek = ((currentDay - 1) / 7).floor();

    if (!_initialized) {
      _initialized = true;
      _pageController = PageController(initialPage: initialWeek);
      _currentWeek = initialWeek + 1;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Week $_currentWeek',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'EB Garamond',
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentWeek = index + 1;
          });
        },
        itemCount: totalWeeks,
        itemBuilder: (context, weekIndex) {
          final startDay = weekIndex * 7;
          final daysInWeek = (startDay + 7 <= totalDays) ? 7 : totalDays - startDay;
          final weekDays = planState.planData.sublist(startDay, startDay + daysInWeek);
          
          return _WeeklyJourneyPath(
            weekDays: weekDays,
            planState: planState,
            theme: theme,
            planId: widget.planId,
          );
        },
      ),
    );
  }
}

class _WeeklyJourneyPath extends StatelessWidget {
  final List<PlanDayData> weekDays;
  final ReadingPlanState planState;
  final ThemeData theme;
  final String planId;

  const _WeeklyJourneyPath({
    required this.weekDays,
    required this.planState,
    required this.theme,
    required this.planId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: _JourneyPathPainter(
            weekDays: weekDays,
            completedDays: planState.completedReadings,
            theme: theme,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            itemCount: weekDays.length,
            itemBuilder: (context, index) {
              final dayData = weekDays[index];
              final isLeft = index % 2 == 0;
              final isCompleted = planState.completedReadings.contains(dayData.day);
              final isToday = planState.currentDay == dayData.day;

              return Container(
                margin: const EdgeInsets.only(bottom: 64),
                child: Row(
                  mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    if (!isLeft) const Spacer(),
                    _buildNode(context, dayData, isCompleted, isToday),
                    if (isLeft) const Spacer(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNode(BuildContext context, PlanDayData dayData, bool isCompleted, bool isToday) {
    final bool isMilestone = dayData.day % 7 == 0;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) => Scaffold(
            body: DayView(planId: planId, dayNum: dayData.day),
          ),
        ));
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80, // fixed height helps path calculation
            decoration: BoxDecoration(
              color: isCompleted 
                  ? AppColors.goldAccent 
                  : (isToday ? AppColors.goldAccent.withValues(alpha: 0.15) : theme.colorScheme.surface),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isCompleted 
                      ? AppColors.goldAccent.withValues(alpha: 0.4) 
                      : (isToday ? AppColors.goldAccent.withValues(alpha: 0.4) : theme.shadowColor.withValues(alpha: 0.05)),
                  blurRadius: isToday ? 20 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: isCompleted 
                    ? AppColors.goldAccent 
                    : (isToday ? AppColors.goldAccent : theme.dividerColor.withValues(alpha: 0.15)), 
                width: isCompleted ? 0 : 4,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(isMilestone ? Icons.emoji_events_rounded : Icons.check_rounded, color: Colors.white, size: 40)
                  : (isMilestone 
                      ? Icon(Icons.emoji_events_rounded, color: isToday ? AppColors.goldAccent : theme.colorScheme.onSurface.withValues(alpha: 0.3), size: 36)
                      : Text(
                          '${dayData.day}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isToday ? AppColors.goldAccent : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                    ),
            ),
          ),
          Positioned(
            bottom: -32,
            child: Text(
              dayData.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: (isToday || isCompleted) ? AppColors.goldAccent : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyPathPainter extends CustomPainter {
  final List<PlanDayData> weekDays;
  final Set<int> completedDays;
  final ThemeData theme;

  _JourneyPathPainter({
    required this.weekDays,
    required this.completedDays,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double nodeHeight = 80.0; // matched to new node height
    final double nodeMargin = 64.0;
    final double totalHeightPerItem = nodeHeight + nodeMargin;
    
    final double topOffset = 48.0; // padding top of ListView

    final double leftX = 24.0 + (80.0 / 2); // padding + half node width
    final double rightX = size.width - leftX;

    if (weekDays.length <= 1) return;

    for (int i = 0; i < weekDays.length - 1; i++) {
      final isLeft = i % 2 == 0;
      final startY = topOffset + (i * totalHeightPerItem) + (nodeHeight / 2);
      final endY = topOffset + ((i + 1) * totalHeightPerItem) + (nodeHeight / 2);
      
      final currentX = isLeft ? leftX : rightX;
      final nextX = isLeft ? rightX : leftX;
      
      final path = Path();
      path.moveTo(currentX, startY);

      // Control points for a smooth S-curve
      path.cubicTo(
        currentX, startY + (nodeMargin / 2),
        nextX, endY - (nodeMargin / 2),
        nextX, endY,
      );

      // A segment is completed if the origin node is completed
      final isSegmentCompleted = completedDays.contains(weekDays[i].day);

      final paint = Paint()
        ..color = isSegmentCompleted ? AppColors.goldAccent : theme.dividerColor.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
