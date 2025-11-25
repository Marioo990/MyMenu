import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import '../../providers/language_provider.dart';

class FilterChips extends StatefulWidget {
  final MenuItemFilter filter;
  final Function(MenuItemFilter) onFilterChanged;
  final MenuItemSort sortOption;
  final Function(MenuItemSort) onSortChanged;

  const FilterChips({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.sortOption,
    required this.onSortChanged,
  });

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  static const double _maxPriceRange = 150.0;

  late Set<String> _selectedTags;
  late RangeValues _priceRange;
  int? _maxCalories;
  int? _maxSpiciness;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() {
    _selectedTags = Set<String>.from(widget.filter.tags);
    _priceRange = RangeValues(
      widget.filter.minPrice ?? 0,
      widget.filter.maxPrice ?? _maxPriceRange,
    );
    _maxCalories = widget.filter.maxCalories;
    _maxSpiciness = widget.filter.maxSpiciness;
  }

  @override
  void didUpdateWidget(FilterChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sprawdzanie zmian zewnętrznych (np. reset filtrów)
    bool tagsChanged = widget.filter.tags.length != oldWidget.filter.tags.length ||
        !widget.filter.tags.every((t) => oldWidget.filter.tags.contains(t));
    bool priceChanged = widget.filter.minPrice != oldWidget.filter.minPrice ||
        widget.filter.maxPrice != oldWidget.filter.maxPrice;
    bool otherChanged = widget.filter.maxCalories != oldWidget.filter.maxCalories ||
        widget.filter.maxSpiciness != oldWidget.filter.maxSpiciness;

    if (tagsChanged || priceChanged || otherChanged) {
      setState(() {
        _initializeState();
      });
    }
  }

  void _applyFilters() {
    final min = _priceRange.start > 0 ? _priceRange.start : null;
    final max = _priceRange.end < _maxPriceRange ? _priceRange.end : null;

    final newFilter = widget.filter.copyWith(
      tags: _selectedTags.toList(),
      minPrice: min,
      maxPrice: max,
      forceResetMinPrice: min == null,
      forceResetMaxPrice: max == null,
      maxCalories: _maxCalories,
      forceResetCalories: _maxCalories == null,
      maxSpiciness: _maxSpiciness,
      forceResetSpiciness: _maxSpiciness == null,
    );
    widget.onFilterChanged(newFilter);
  }

  void _clearFilters() {
    setState(() {
      _selectedTags.clear();
      _priceRange = const RangeValues(0, _maxPriceRange);
      _maxCalories = null;
      _maxSpiciness = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(bottom: BorderSide(color: AppTheme.textLight, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSortSection(languageProvider),
          const SizedBox(height: AppTheme.spacingM),
          const Divider(),
          const SizedBox(height: AppTheme.spacingM),
          _buildDietaryTags(languageProvider),
          const SizedBox(height: AppTheme.spacingM),
          _buildPriceRange(languageProvider),
          const SizedBox(height: AppTheme.spacingM),
          _buildCaloriesFilter(languageProvider),
          const SizedBox(height: AppTheme.spacingM),
          _buildSpicinessFilter(languageProvider),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _clearFilters,
                child: Text(languageProvider.translate('clear')),
              ),
              const SizedBox(width: AppTheme.spacingS),
              ElevatedButton(
                onPressed: _applyFilters,
                child: Text(languageProvider.translate('apply')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection(LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(languageProvider.translate('sort'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppTheme.spacingS),
        Wrap(
          spacing: AppTheme.spacingS,
          children: [
            _buildSortChip(MenuItemSort.name, languageProvider.translate('name'), Icons.sort_by_alpha),
            _buildSortChip(MenuItemSort.priceAsc, languageProvider.translate('price_low'), Icons.arrow_upward),
            _buildSortChip(MenuItemSort.priceDesc, languageProvider.translate('price_high'), Icons.arrow_downward),
            _buildSortChip(MenuItemSort.calories, languageProvider.translate('calories'), Icons.local_fire_department),
            _buildSortChip(MenuItemSort.newest, languageProvider.translate('newest'), Icons.new_releases),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(MenuItemSort sort, String label, IconData icon) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: AppTheme.spacingXS), Text(label)],
      ),
      selected: widget.sortOption == sort,
      onSelected: (selected) {
        if (selected) widget.onSortChanged(sort);
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildDietaryTags(LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(languageProvider.translate('dietary'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppTheme.spacingS),
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: [
            _buildTagChip('vegan', '🌱 ${languageProvider.translate('vegan')}'),
            _buildTagChip('vegetarian', '🥗 ${languageProvider.translate('vegetarian')}'),
            _buildTagChip('gluten-free', '🌾 ${languageProvider.translate('gluten_free')}'),
            _buildTagChip('dairy-free', '🥛 ${languageProvider.translate('dairy_free')}'),
            _buildTagChip('spicy', '🌶️ ${languageProvider.translate('spicy')}'),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedTags.contains(tag),
      onSelected: (selected) {
        setState(() {
          selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
        });
      },
      selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.secondaryColor,
    );
  }

  Widget _buildPriceRange(LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(languageProvider.translate('price_range'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppTheme.spacingS),
        Row(
          children: [
            Text('${_priceRange.start.toStringAsFixed(0)} zł'),
            Expanded(
              child: RangeSlider(
                values: _priceRange,
                min: 0,
                max: _maxPriceRange,
                divisions: 30,
                labels: RangeLabels(
                  '${_priceRange.start.toStringAsFixed(0)} zł',
                  '${_priceRange.end.toStringAsFixed(0)} zł',
                ),
                onChanged: (values) => setState(() => _priceRange = values),
              ),
            ),
            Text('${_priceRange.end.toStringAsFixed(0)} zł'),
          ],
        ),
      ],
    );
  }

  Widget _buildCaloriesFilter(LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(languageProvider.translate('max_calories'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppTheme.spacingS),
        Wrap(
          spacing: AppTheme.spacingS,
          children: [
            _buildCaloriesChip(null, languageProvider.translate('all')),
            _buildCaloriesChip(300, '< 300 kcal'),
            _buildCaloriesChip(500, '< 500 kcal'),
            _buildCaloriesChip(800, '< 800 kcal'),
          ],
        ),
      ],
    );
  }

  Widget _buildCaloriesChip(int? calories, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _maxCalories == calories,
      onSelected: (selected) => setState(() => _maxCalories = selected ? calories : null),
      selectedColor: AppTheme.successColor.withOpacity(0.2),
    );
  }

  Widget _buildSpicinessFilter(LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(languageProvider.translate('spiciness'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppTheme.spacingS),
        Wrap(
          spacing: AppTheme.spacingS,
          children: [
            _buildSpicinessChip(null, languageProvider.translate('all')),
            _buildSpicinessChip(0, languageProvider.translate('mild')),
            _buildSpicinessChip(1, '🌶️'),
            _buildSpicinessChip(2, '🌶️🌶️'),
            _buildSpicinessChip(3, '🌶️🌶️🌶️'),
          ],
        ),
      ],
    );
  }

  Widget _buildSpicinessChip(int? spiciness, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _maxSpiciness == spiciness,
      onSelected: (selected) => setState(() => _maxSpiciness = selected ? spiciness : null),
      selectedColor: AppTheme.warningColor.withOpacity(0.2),
    );
  }
}