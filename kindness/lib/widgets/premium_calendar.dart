import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumCalendar extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime)? onDaySelected;
  final Function(DateTime)? onPageChanged;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double? borderRadius;
  final Duration? animationDuration;
  final bool isDisabled;
  final bool showShadow;
  final bool showRippleEffect;
  final bool showHeader;
  final TextStyle? headerStyle;
  final bool showWeekdayLabels;
  final TextStyle? weekdayLabelStyle;
  final bool showTodayButton;
  final String? todayButtonText;
  final TextStyle? todayButtonStyle;
  final bool showClearButton;
  final String? clearButtonText;
  final TextStyle? clearButtonStyle;
  final bool showRangeSelection;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final Function(DateTime, DateTime)? onRangeSelected;
  final bool showMultiSelection;
  final List<DateTime>? selectedDates;
  final Function(List<DateTime>)? onMultiSelected;
  final bool showHolidays;
  final List<DateTime>? holidays;
  final Color? holidayColor;
  final bool showEvents;
  final Map<DateTime, List<dynamic>>? events;
  final Color? eventColor;
  final bool showMarkers;
  final Map<DateTime, List<dynamic>>? markers;
  final Color? markerColor;
  final bool showTooltips;
  final String? tooltipFormat;
  final bool isError;
  final String? errorText;
  final TextStyle? errorTextStyle;

  const PremiumCalendar({
    Key? key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.focusedDay,
    this.selectedDay,
    this.onDaySelected,
    this.onPageChanged,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.borderRadius,
    this.animationDuration,
    this.isDisabled = false,
    this.showShadow = true,
    this.showRippleEffect = true,
    this.showHeader = true,
    this.headerStyle,
    this.showWeekdayLabels = true,
    this.weekdayLabelStyle,
    this.showTodayButton = true,
    this.todayButtonText,
    this.todayButtonStyle,
    this.showClearButton = true,
    this.clearButtonText,
    this.clearButtonStyle,
    this.showRangeSelection = false,
    this.rangeStart,
    this.rangeEnd,
    this.onRangeSelected,
    this.showMultiSelection = false,
    this.selectedDates,
    this.onMultiSelected,
    this.showHolidays = false,
    this.holidays,
    this.holidayColor,
    this.showEvents = false,
    this.events,
    this.eventColor,
    this.showMarkers = false,
    this.markers,
    this.markerColor,
    this.showTooltips = false,
    this.tooltipFormat,
    this.isError = false,
    this.errorText,
    this.errorTextStyle,
  }) : super(key: key);

  @override
  State<PremiumCalendar> createState() => _PremiumCalendarState();
}

class _PremiumCalendarState extends State<PremiumCalendar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late DateTime _focusedDay;
  late DateTime? _selectedDay;
  late DateTime? _rangeStart;
  late DateTime? _rangeEnd;
  late List<DateTime> _selectedDates;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _focusedDay = widget.focusedDay ?? widget.initialDate ?? DateTime.now();
    _selectedDay = widget.selectedDay;
    _rangeStart = widget.rangeStart;
    _rangeEnd = widget.rangeEnd;
    _selectedDates = widget.selectedDates ?? [];
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDaySelected(DateTime day) {
    if (widget.isDisabled) return;

    setState(() {
      if (widget.showRangeSelection) {
        if (_rangeStart == null) {
          _rangeStart = day;
          _rangeEnd = null;
        } else if (_rangeEnd == null) {
          if (day.isBefore(_rangeStart!)) {
            _rangeEnd = _rangeStart;
            _rangeStart = day;
          } else {
            _rangeEnd = day;
          }
          widget.onRangeSelected?.call(_rangeStart!, _rangeEnd!);
        } else {
          _rangeStart = day;
          _rangeEnd = null;
        }
      } else if (widget.showMultiSelection) {
        if (_selectedDates.contains(day)) {
          _selectedDates.remove(day);
        } else {
          _selectedDates.add(day);
        }
        widget.onMultiSelected?.call(_selectedDates);
      } else {
        _selectedDay = day;
        widget.onDaySelected?.call(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            boxShadow: widget.showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showHeader) _buildHeader(),
              if (widget.showWeekdayLabels) _buildWeekdayLabels(),
              _buildCalendar(),
              if (widget.showTodayButton) _buildTodayButton(),
              if (widget.showClearButton) _buildClearButton(),
              if (widget.isError) _buildError(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month - 1,
                );
                widget.onPageChanged?.call(_focusedDay);
              });
            },
          ),
          Text(
            '${_focusedDay.year} ${_getMonthName(_focusedDay.month)}',
            style: widget.headerStyle ?? Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month + 1,
                );
                widget.onPageChanged?.call(_focusedDay);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            day,
            style: widget.weekdayLabelStyle ??
                Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendar() {
    final daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final dayOffset = index - startingWeekday;
        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return const SizedBox();
        }

        final day =
            DateTime(_focusedDay.year, _focusedDay.month, dayOffset + 1);
        final isSelected = _selectedDay == day ||
            (_rangeStart == day) ||
            (_rangeEnd == day) ||
            _selectedDates.contains(day);
        final isInRange = _rangeStart != null &&
            _rangeEnd != null &&
            day.isAfter(_rangeStart!) &&
            day.isBefore(_rangeEnd!);
        final isToday = day.year == DateTime.now().year &&
            day.month == DateTime.now().month &&
            day.day == DateTime.now().day;
        final isHoliday = widget.showHolidays &&
            (widget.holidays?.any((h) =>
                    h.year == day.year &&
                    h.month == day.month &&
                    h.day == day.day) ??
                false);
        final hasEvent =
            widget.showEvents && (widget.events?.containsKey(day) ?? false);
        final hasMarker =
            widget.showMarkers && (widget.markers?.containsKey(day) ?? false);

        return GestureDetector(
          onTap: () => _handleDaySelected(day),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isInRange
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : null,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isHoliday
                            ? widget.holidayColor ?? Colors.red
                            : isToday
                                ? Theme.of(context).primaryColor
                                : null,
                    fontWeight: isToday ? FontWeight.bold : null,
                  ),
                ),
                if (hasEvent)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            widget.eventColor ?? Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (hasMarker)
                  Positioned(
                    top: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.markerColor ??
                            Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _focusedDay = DateTime.now();
          _selectedDay = DateTime.now();
          widget.onDaySelected?.call(_selectedDay!);
          widget.onPageChanged?.call(_focusedDay);
        });
      },
      child: Text(
        widget.todayButtonText ?? 'Today',
        style:
            widget.todayButtonStyle ?? Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget _buildClearButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedDay = null;
          _rangeStart = null;
          _rangeEnd = null;
          _selectedDates.clear();
        });
      },
      child: Text(
        widget.clearButtonText ?? 'Clear',
        style:
            widget.clearButtonStyle ?? Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        widget.errorText ?? 'Invalid date',
        style: widget.errorTextStyle ??
            Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
