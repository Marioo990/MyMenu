import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../models/category.dart';
import '../../../models/menu_item.dart';
import '../../../models/day_period.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../widgets/menu/category_carousel.dart';
import '../../../widgets/menu/menu_item_card.dart';
import '../../../widgets/menu/search_bar.dart' as custom;
import '../../../widgets/menu/filter_chips.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? _selectedCategoryId;
  MenuItemFilter _filter = MenuItemFilter();
  MenuItemSort _sortOption = MenuItemSort.name;
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Consumer4<MenuProvider, SettingsProvider, FavoritesProvider, LanguageProvider>(
      builder: (context, menuProvider, settingsProvider, favoritesProvider, languageProvider, child) {
        final locale = languageProvider.currentLocale.languageCode;
        final currentDayPeriod = menuProvider.getCurrentDayPeriod();

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true, pinned: true, expandedHeight: 120,
                backgroundColor: AppTheme.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(settingsProvider.getRestaurantNameForLocale(locale)),
                  centerTitle: true,
                ),
              ),
              if (settingsProvider.dayPeriodsEnabled && currentDayPeriod != null)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    child: Text("Aktualna pora: ${currentDayPeriod.getName(locale)}"),
                  ),
                ),
              SliverToBoxAdapter(
                child: CategoryCarousel(
                  categories: menuProvider.categories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
                  locale: locale,
                ),
              ),
              SliverToBoxAdapter(
                child: custom.SearchBar(
                  onSearchChanged: (q) => setState(() => _filter = _filter.copyWith(searchQuery: q)),
                ),
              ),
              if (_showFilters)
                SliverToBoxAdapter(
                  child: FilterChips(
                    filter: _filter,
                    onFilterChanged: (f) => setState(() => _filter = f),
                    sortOption: _sortOption,
                    onSortChanged: (s) => setState(() => _sortOption = s),
                  ),
                ),
              // Lista elementów
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    // Prosta logika wyświetlania - w pełnej wersji użyj _buildMenuItemsList
                    if (menuProvider.menuItems.isEmpty) return const SizedBox.shrink();
                    final item = menuProvider.menuItems[index];
                    return MenuItemCard(
                      item: item,
                      isFavorite: favoritesProvider.isFavorite(item.id),
                      onFavoriteToggle: () => favoritesProvider.toggleFavorite(item.id),
                      onTap: () {},
                      locale: locale,
                    );
                  },
                  childCount: menuProvider.menuItems.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}