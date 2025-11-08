import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/category.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/menu/category_carousel.dart';
import '../../widgets/menu/menu_item_card.dart';
import '../../widgets/menu/search_bar.dart' as custom;
import '../../widgets/menu/filter_chips.dart';


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
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    await menuProvider.refreshAll();

    // Get notification count
    final notifications = await menuProvider.getActiveNotifications();
    setState(() {
      _notificationCount = notifications.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Safely get providers with null checks
    MenuProvider? menuProvider;
    SettingsProvider? settingsProvider;
    FavoritesProvider? favoritesProvider;
    LanguageProvider? languageProvider;

    try {
      menuProvider = Provider.of<MenuProvider>(context, listen: false);
      settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
      languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    } catch (e) {
      print('❌ Error getting providers: $e');
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Provider error: $e')),
      );
    }

    final locale = languageProvider.currentLocale.languageCode;
    final currentDayPeriod = menuProvider.getCurrentDayPeriod();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 120,
              backgroundColor: AppTheme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  settingsProvider.getRestaurantNameForLocale(locale),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              actions: [
                // Language Selector
                // Language Selector - with null safety
                if (languageProvider != null)
                  PopupMenuButton<String>(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          languageProvider?.currentLanguageFlag ?? '🌐',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                    onSelected: (languageCode) {
                      languageProvider?.setLanguageCode(languageCode);
                    },
                    itemBuilder: (context) {
                      final locales = languageProvider?.supportedLocales ?? [const Locale('en')];
                      return locales.map((locale) => PopupMenuItem(
                        value: locale.languageCode,
                        child: Row(
                          children: [
                            Text(
                              languageProvider?.getLanguageFlag(locale.languageCode) ?? '🌐',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Text(languageProvider?.getLanguageName(locale.languageCode) ?? locale.languageCode),
                          ],
                        ),
                      )).toList();
                    },
                  ),

                // Notifications
                // Notifications
                if (menuProvider != null)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {
                          _showNotifications();
                        },
                      ),
                      if (_notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              _notificationCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),

// Info
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, '/info');
                  },
                ),

// Admin Access
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.white54),
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin');
                  },
                ),

                // Info
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () {
                    AppRoutes.navigateTo(context, AppRoutes.info);
                  },
                ),

                // Admin Access
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.white54),
                  onPressed: () {
                    AppRoutes.navigateTo(context, AppRoutes.adminLogin);
                  },
                ),
              ],
            ),

            // Day Period Indicator
            if (settingsProvider.dayPeriodsEnabled && currentDayPeriod != null)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentDayPeriod.getDisplayIcon(),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        currentDayPeriod.getName(locale),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Text(
                        currentDayPeriod.getTimeRangeString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Categories
            SliverToBoxAdapter(
              child: CategoryCarousel(
                categories: _buildCategoryList(menuProvider, languageProvider),
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: (categoryId) {
                  setState(() {
                    _selectedCategoryId = categoryId;
                  });
                },
                locale: locale,
              ),
            ),

            // Search Bar & Filter Toggle
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  children: [
                    // Search Bar
                    custom.SearchBar(
                      onSearchChanged: (query) {
                        setState(() {
                          _filter = _filter.copyWith(searchQuery: query);
                        });
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingM),

                    // Filter Toggle Button
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: Icon(_showFilters ? Icons.expand_less : Icons.expand_more),
                      label: Text(languageProvider.translate('filter')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showFilters ? AppTheme.secondaryColor : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filters (if shown)
            if (_showFilters)
              SliverToBoxAdapter(
                child: FilterChips(
                  filter: _filter,
                  onFilterChanged: (filter) {
                    setState(() {
                      _filter = filter;
                    });
                  },
                  sortOption: _sortOption,
                  onSortChanged: (sort) {
                    setState(() {
                      _sortOption = sort;
                    });
                  },
                ),
              ),

            // Menu Items
            if (menuProvider.isLoadingItems)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                sliver: _buildMenuItemsList(
                  menuProvider,
                  favoritesProvider,
                  languageProvider,
                  locale,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Category> _buildCategoryList(MenuProvider menuProvider, LanguageProvider languageProvider) {
    final categories = <Category>[];

    // Add special categories
    categories.add(SpecialCategories.getAllCategory({
      'en': 'All',
      'pl': 'Wszystkie',
    }));

    if (Provider.of<FavoritesProvider>(context).hasFavorites) {
      categories.add(SpecialCategories.getFavoritesCategory({
        'en': 'Favorites',
        'pl': 'Ulubione',
      }));
    }

    // Add regular categories
    categories.addAll(menuProvider.categories);

    return categories;
  }

  Widget _buildMenuItemsList(
      MenuProvider menuProvider,
      FavoritesProvider favoritesProvider,
      LanguageProvider languageProvider,
      String locale,
      ) {
    // Get filtered items
    List<MenuItem> items = menuProvider.menuItems;

    // Apply category filter
    if (_selectedCategoryId == SpecialCategories.favorites) {
      items = items.where((item) => favoritesProvider.isFavorite(item.id)).toList();
    } else if (_selectedCategoryId != null && _selectedCategoryId != SpecialCategories.all) {
      items = items.where((item) => item.categoryId == _selectedCategoryId).toList();
    }

    // Apply day period filter
    final currentDayPeriod = menuProvider.getCurrentDayPeriod();
    if (currentDayPeriod != null) {
      items = items.where((item) => item.isAvailableNow(currentDayPeriod.id)).toList();
    }

    // Apply custom filters
    items = items.where((item) => _filter.matches(item, locale)).toList();

    // Apply sorting
    items = menuProvider.getSortedItems(items, _sortOption, locale);

    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            child: Column(
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppTheme.textLight,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  languageProvider.translate('no_items_found'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: MenuItemCard(
              item: item,
              isFavorite: favoritesProvider.isFavorite(item.id),
              onFavoriteToggle: () {
                favoritesProvider.toggleFavorite(item.id);
              },
              onTap: () {
                AppRoutes.navigateTo(
                  context,
                  AppRoutes.itemDetail,
                  arguments: {'itemId': item.id},
                );
              },
              locale: locale,
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return _buildNotificationsList(scrollController);
          },
        );
      },
    );
  }

  Widget _buildNotificationsList(ScrollController scrollController) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.currentLocale.languageCode;

    return FutureBuilder<List<dynamic>>(
      future: menuProvider.getActiveNotifications(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(languageProvider.translate('no_notifications')),
          );
        }

        final notifications = snapshot.data!;

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(AppTheme.spacingM),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.secondaryColor,
                  child: Icon(Icons.campaign, color: Colors.white),
                ),
                title: Text(notification.getTitle(locale)),
                subtitle: Text(notification.getMessage(locale)),
                onTap: () {
                  Navigator.pop(context);
                  // Handle notification tap
                },
              ),
            );
          },
        );
      },
    );
  }
}