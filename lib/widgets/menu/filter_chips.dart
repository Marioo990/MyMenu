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
  late Set<String> _selectedTags;
  late RangeValues _priceRange;
  int? _maxCalories;
  int? _maxSpiciness;

  @override
  void initState() {
    super.initState();
    _selectedTags = Set<String>.from(widget.filter.tags);
    _priceRange = RangeValues(
      widget.filter.minPrice ?? 0,
      widget.filter.maxPrice ?? 100,
    );
    _maxCalories = widget.filter.maxCalories;
    _maxSpiciness = widget.filter.maxSpiciness;
  }

  void _applyFilters() {
    final newFilter = widget.filter.copyWith(
      tags: _selectedTags.toList(),
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 100 ? _priceRange.end : null,
      maxCalories: _maxCalories,
      maxSpiciness: _maxSpiciness,
    );
    widget.onFilterChanged(newFilter);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.textLight, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sort Options
          _buildSortSection(languageProvider),

          const SizedBox(height: AppTheme.spacingM),
          const Divider(),
          const SizedBox(height: AppTheme.spacingM),

          // Dietary Tags
          _buildDietaryTags(languageProvider),

          const SizedBox(height: AppTheme.spacingM),

          // Price Range
          _buildPriceRange(languageProvider),

          const SizedBox(height: AppTheme.spacingM),

          // Calories Filter
          _buildCaloriesFilter(languageProvider),

          const SizedBox(height: AppTheme.spacingM),

          // Spiciness Filter
          _buildSpicinessFilter(languageProvider),

          const SizedBox(height: AppTheme.spacingM),

          // Action Buttons
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
        Text(
          languageProvider.translate('sort'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Wrap(
          spacing: AppTheme.spacingS,
          children: [
            _buildSortChip(
              MenuItemSort.name,
              languageProvider.translate('name'),
              Icons.sort_by_alpha,
            ),
            _buildSortChip(
              MenuItemSort.priceAsc,
              languageProvider.translate('price_low'),
              Icons.arrow_upward,
            ),
            _buildSortChip(
              MenuItemSort.priceDesc,
              languageProvider.translate('price_high'),
              Icons.arrow_downward,
            ),
            _buildSortChip(
              MenuItemSort.calories,
              languageProvider.translate('calories'),
              Icons.local_fire_department,
            ),
            _buildSortChip(
              MenuItemSort.newest,
              languageProvider.translate('newest'),
              Icons.new_releases,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(MenuItemSort sort, String label, IconData icon) {
    final isSelected = widget.sortOption == sort;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: AppTheme.spacingXS),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          widget.onSortChanged(sort);
        }
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildDietaryTags(LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.translate('dietary'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: [
            _buildTagChip('vegan', '🌱 ${languageProvider.translate('vegan')}'),
            _buildTagChip('vegetarian', '🥗 ${languageProvider.translate('vegetarian')}'),
            _buildTagChip('gluten-free', '🌾 ${languageProvider.translate('gluten_free')}'),
            _buildTagChip('dairy-free', '🥛 ${languageProvider.translate('dairy_free')}'),
            _buildTagChip('high-protein', '💪 ${languageProvider.translate('high_protein')}'),
            _buildTagChip('low-carb', '🍞 ${languageProvider.translate('low_carb')}'),
            _buildTagChip('fish', '🐟 ${languageProvider.translate('fish')}'),
            _buildTagChip('meat', '🥩 ${languageProvider.translate('meat')}'),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag, String label) {
    final isSelected = _selectedTags.contains(tag);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedTags.add(tag);
          } else {
            _selectedTags.remove(tag);
          }
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
        Text(
          languageProvider.translate('price_range'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Row(
          children: [
            Text('${_priceRange.start.toStringAsFixed(0)} zł'),
            Expanded(
              child: RangeSlider(
                values: _priceRange,
                min: 0,
                max: 100,
                divisions: 20,
                labels: RangeLabels(
                  '${_priceRange.start.toStringAsFixed(0)} zł',
                  '${_priceRange.end.toStringAsFixed(0)} zł',
                ),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
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
        Text(
          languageProvider.translate('max_calories'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Wrap(
          spacing: AppTheme.spacingS,
          children: [
            _buildCaloriesChip(null, languageProvider.translate('all')),
            _buildCaloriesChip(300, '< 300 kcal'),
            _buildCaloriesChip(500, '< 500 kcal'),
            _buildCaloriesChip(700, '< 700 kcal'),
            _buildCaloriesChip(1000, '< 1000 kcal'),
          ],
        ),
      ],
    );
  }

  Widget _buildCaloriesChip(int? calories, String label) {
    final isSelected = _maxCalories == calories;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _maxCalories = selected ? calories : null;
        });
      },
      selectedColor: AppTheme.successColor.withOpacity(0.2),
    );
  }

  Widget _buildSpicinessFilter(LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.translate('spiciness'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
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
    final isSelected = _maxSpiciness == spiciness;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _maxSpiciness = selected ? spiciness : null;
        });
      },
      selectedColor: AppTheme.warningColor.withOpacity(0.2),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedTags.clear();
      _priceRange = const RangeValues(0, 100);
      _maxCalories = null;
      _maxSpiciness = null;
    });
    _applyFilters();
  }
}