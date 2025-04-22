import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumDataTable extends StatefulWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool showCheckboxColumn;
  final bool showHeader;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double borderRadius;
  final Duration animationDuration;
  final bool isDisabled;
  final bool showShadow;
  final bool showRippleEffect;
  final bool showDivider;
  final Color? dividerColor;
  final double dividerHeight;
  final bool showTitle;
  final String? title;
  final TextStyle? titleStyle;
  final bool showSubtitle;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final bool showLeading;
  final Widget? leading;
  final bool showTrailing;
  final Widget? trailing;
  final bool showBadge;
  final Color? badgeColor;
  final double badgeSize;
  final TextStyle? badgeTextStyle;
  final VoidCallback? onRowTap;
  final VoidCallback? onRowLongPress;
  final bool isError;
  final String? errorText;
  final TextStyle? errorTextStyle;
  final bool showPagination;
  final int currentPage;
  final int totalPages;
  final Function(int)? onPageChanged;
  final bool showSearch;
  final String? searchHint;
  final Function(String)? onSearch;
  final bool showFilter;
  final List<String>? filterOptions;
  final Function(String)? onFilter;
  final bool showSort;
  final List<String>? sortOptions;
  final Function(String)? onSort;
  final bool showExport;
  final List<String>? exportOptions;
  final Function(String)? onExport;
  final bool showImport;
  final List<String>? importOptions;
  final Function(String)? onImport;

  const PremiumDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckboxColumn = true,
    this.showHeader = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.borderRadius = 0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.isDisabled = false,
    this.showShadow = true,
    this.showRippleEffect = true,
    this.showDivider = false,
    this.dividerColor,
    this.dividerHeight = 1,
    this.showTitle = true,
    this.title,
    this.titleStyle,
    this.showSubtitle = false,
    this.subtitle,
    this.subtitleStyle,
    this.showLeading = true,
    this.leading,
    this.showTrailing = true,
    this.trailing,
    this.showBadge = false,
    this.badgeColor,
    this.badgeSize = 16,
    this.badgeTextStyle,
    this.onRowTap,
    this.onRowLongPress,
    this.isError = false,
    this.errorText,
    this.errorTextStyle,
    this.showPagination = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.onPageChanged,
    this.showSearch = false,
    this.searchHint,
    this.onSearch,
    this.showFilter = false,
    this.filterOptions,
    this.onFilter,
    this.showSort = false,
    this.sortOptions,
    this.onSort,
    this.showExport = false,
    this.exportOptions,
    this.onExport,
    this.showImport = false,
    this.importOptions,
    this.onImport,
  });

  @override
  State<PremiumDataTable> createState() => _PremiumDataTableState();
}

class _PremiumDataTableState extends State<PremiumDataTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: widget.backgroundColor ?? colorScheme.surface,
      elevation: widget.showShadow ? widget.elevation : 0,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showTitle && widget.title != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.showLeading && widget.leading != null)
                        widget.leading!,
                      if (widget.showLeading && widget.leading != null)
                        const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title!,
                              style: (widget.titleStyle ??
                                      theme.textTheme.titleLarge)
                                  ?.copyWith(
                                color: widget.foregroundColor ??
                                    colorScheme.onSurface,
                              ),
                            ),
                            if (widget.showSubtitle && widget.subtitle != null)
                              Text(
                                widget.subtitle!,
                                style: (widget.subtitleStyle ??
                                        theme.textTheme.bodySmall)
                                    ?.copyWith(
                                  color: widget.foregroundColor
                                          ?.withOpacity(0.7) ??
                                      colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.showTrailing && widget.trailing != null)
                        widget.trailing!,
                      if (widget.showTrailing && widget.trailing != null)
                        const SizedBox(width: 16),
                      if (widget.showBadge)
                        Container(
                          width: widget.badgeSize,
                          height: widget.badgeSize,
                          decoration: BoxDecoration(
                            color: widget.badgeColor ?? colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '!',
                              style: (widget.badgeTextStyle ??
                                      theme.textTheme.labelSmall)
                                  ?.copyWith(
                                color: colorScheme.onError,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (widget.showSearch)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: widget.searchHint ?? 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(widget.borderRadius),
                          ),
                        ),
                        onChanged: widget.onSearch,
                      ),
                    ),
                  if (widget.showFilter ||
                      widget.showSort ||
                      widget.showExport ||
                      widget.showImport)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          if (widget.showFilter)
                            DropdownButton<String>(
                              hint: const Text('Filter'),
                              items: widget.filterOptions?.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  widget.onFilter?.call(value);
                                }
                              },
                            ),
                          if (widget.showSort)
                            DropdownButton<String>(
                              hint: const Text('Sort'),
                              items: widget.sortOptions?.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  widget.onSort?.call(value);
                                }
                              },
                            ),
                          if (widget.showExport)
                            DropdownButton<String>(
                              hint: const Text('Export'),
                              items: widget.exportOptions?.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  widget.onExport?.call(value);
                                }
                              },
                            ),
                          if (widget.showImport)
                            DropdownButton<String>(
                              hint: const Text('Import'),
                              items: widget.importOptions?.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  widget.onImport?.call(value);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          if (widget.showDivider)
            Divider(
              color: widget.dividerColor ?? colorScheme.outlineVariant,
              height: widget.dividerHeight,
            ),
          DataTable(
            columns: widget.columns,
            rows: widget.rows,
            showCheckboxColumn: widget.showCheckboxColumn,
            headingRowColor: MaterialStateProperty.all(
              widget.backgroundColor ?? colorScheme.surface,
            ),
            dataRowColor: MaterialStateProperty.all(
              widget.backgroundColor ?? colorScheme.surface,
            ),
            headingTextStyle:
                (widget.titleStyle ?? theme.textTheme.titleMedium)?.copyWith(
              color: widget.foregroundColor ?? colorScheme.onSurface,
            ),
            dataTextStyle:
                (widget.subtitleStyle ?? theme.textTheme.bodyMedium)?.copyWith(
              color: widget.foregroundColor ?? colorScheme.onSurface,
            ),
            onSelectAll: (selected) {
              // Handle select all
            },
          ),
          if (widget.showPagination)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: widget.currentPage > 1
                        ? () =>
                            widget.onPageChanged?.call(widget.currentPage - 1)
                        : null,
                  ),
                  Text(
                    'Page ${widget.currentPage} of ${widget.totalPages}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: widget.currentPage < widget.totalPages
                        ? () =>
                            widget.onPageChanged?.call(widget.currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
