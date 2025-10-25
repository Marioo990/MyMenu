import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/menu_item.dart';
import '../../models/category.dart';
import '../../models/day_period.dart';
import '../../models/notification.dart';
import '../../providers/menu_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/menu/category_carousel.dart';
import '../../widgets/menu/menu_item_card.dart';
import '../../widgets/menu/search_bar.dart' as app;
import '../../widgets/menu/filter_chips.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? selectedCategoryId;
  String searchQuery = '';
  MenuItemFilter filter = MenuItemFilter();
  MenuItemSort sortOption = MenuItemSort.name;
  bool showFilters = false;
  final ScrollController _scrollController = ScrollController();
  RestaurantNotification? activeBanner;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _checkNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    await menuProvider.loadCategories();
    await menuProvider.loadMenuItems();
    await menuProvider.loadDayPeriods();
  }

  void _checkNotifications() {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    menuProvider.getActiveNotifications().then((notifications) {
      final bannerNotifications = notifications
          .where((n) => n.showAsBanner && n.isActive())
          .toList();

      if (bannerNotifications.isNotEmpty) {
        // Sort by priority and show the highest priority
        bannerNotifications.sort((a, b) => b.priority.compareTo(a.priority));
        setState(() {
          activeBanner = bannerNotifications.first;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.currentLocale.languageCode;

    // Get current day period if enabled
    DayPeriod? currentDayPeriod;
    if (settingsProvider.dayPeriodsEnabled) {
      currentDayPeriod = DayPeriod.getCurrentPeriod(menuProvider.dayPeriods);
    }

    // Build categories list including special categories
    final categories = _buildCategoriesWithSpecial(
      menuProvider.categories,
      favoritesProvider.hasFavorites,
      locale,
    );

    // Get filtered and sorted items
    final items = _getFilteredAndSortedItems(
      menuProvider.menuItems,
      favoritesProvider.favoriteIds,
      currentDayPeriod,
      locale,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Header
            _buildHeader(context, settingsProvider, languageProvider),

            // Notification Banner
            if (activeBanner != null)
              _buildNotificationBanner(activeBanner!, locale),

            // Day Period Display
            if (currentDayPeriod != null)
              _buildDayPeriodBanner(currentDayPeriod, locale),

            // Categories Carousel
            CategoryCarousel(
              categories: categories,
              selectedCategoryId: selectedCategoryId,
              onCategorySelected: (categoryId) {
                setState(() {
                  selectedCategoryId = categoryId;
                });
              },
              locale: locale,
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              child: app.SearchBar(
                onSearchChanged: (query) {
                  setState(() {
                    searchQuery = query;
                    filter = filter.copyWith(searchQuery: query);
                  });
                },
                onFilterPressed: () {
                  setState(() {
                    showFilters = !showFilters;
                  });
                },
              ),
            ),

            // Filter Chips
            if (showFilters)
              FilterChips(
                filter: filter,
                onFilterChanged: (newFilter) {
                  setState(() {
                    filter = newFilter;
                  });
                },
                sortOption: sortOption,
                onSortChanged: (newSort) {
                  setState(() {
                    sortOption = newSort;
                  });
                },
              ),

            // Menu Items List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadInitialData,
                child: items.isEmpty
                    ? _buildEmptyState(locale)
                    : _buildMenuItemsList(items, favoritesProvider, locale),
              ),
            ),
          ],
        ),
      ),

      // Info FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRoutes.navigateTo(context, AppRoutes.info);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.info_outline),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      SettingsProvider settingsProvider,
      LanguageProvider languageProvider,
      ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Restaurant Logo/Name
          Expanded(
            child: Text(
              settingsProvider.restaurantName,
              style: Theme.of(context).textTheme.headlineLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Language Selector
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (locale) {
              languageProvider.setLocale(locale);
            },
            itemBuilder: (context) {
              return languageProvider.supportedLocales.map((locale) {
                return PopupMenuItem<Locale>(
                  value: locale,
                  child: Row(
                    children: [
                      Text(_getLanguageFlag(locale.languageCode)),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(_getLanguageName(locale.languageCode)),
                    ],
                  ),
                );
              }).toList();
            },
          ),

          // Notifications Bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // Navigate to notifications
                  AppRoutes.navigateTo(context, AppRoutes.notifications);
                },
              ),
              // Badge for new notifications
              if (_hasNewNotifications())
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBanner(RestaurantNotification notification, String locale) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          if (notification.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              child: CachedNetworkImage(
                imageUrl: notification.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          if (notification.imageUrl != null)
            const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.getTitle(locale),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  notification.getMessage(locale),
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notification.ctaText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppTheme.spacingS),
                    child: TextButton(
                      onPressed: () {
                        _handleNotificationDeepLink(notification);
                      },
                      child: Text(notification.ctaText!),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                activeBanner = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayPeriodBanner(DayPeriod dayPeriod, String locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayPeriod.getDisplayIcon(),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                dayPeriod.getName(locale),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                dayPeriod.getTimeRangeString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (dayPeriod.getDescription(locale) != null)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacingXS),
              child: Text(
                dayPeriod.getDescription(locale)!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItemsList(
      List<MenuItem> items,
      FavoritesProvider favoritesProvider,
      String locale,
      ) {
    if (AppTheme.isDesktop(context)) {
      // Grid layout for desktop
      return GridView.builder(
        controller: _scrollController,
        padding: AppTheme.responsivePadding(context),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 1.5,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return MenuItemCard(
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
          );
        },
      );
    } else {
      // List layout for mobile/tablet
      return ListView.builder(
        controller: _scrollController,
        padding: AppTheme.responsivePadding(context),
        itemCount: items.length,
        itemBuilder: (context, index) {
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
      );
    }
  }

  Widget _buildEmptyState(String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            _getEmptyStateMessage(locale),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<Category> _buildCategoriesWithSpecial(
      List<Category> originalCategories,
      bool hasFavorites,
      String locale,
      ) {
    final categories = <Category>[];

    // Add favorites category if there are favorites
    if (hasFavorites) {
      categories.add(SpecialCategories.getFavoritesCategory({
        'pl': 'Ulubione',
        'en': 'Favorites',
      }));
    }

    // Add all items category
    categories.add(SpecialCategories.getAllCategory({
      'pl': 'Wszystkie',
      'en': 'All',
    }));

    // Add regular categories
    categories.addAll(originalCategories);

    return categories;
  }

  List<MenuItem> _getFilteredAndSortedItems(
      List<MenuItem> allItems,
      Set<String> favoriteIds,
      DayPeriod? currentDayPeriod,
      String locale,
      ) {
    // Start with all items
    var items = List<MenuItem>.from(allItems);

    // Apply category filter
    if (selectedCategoryId != null) {
      if (selectedCategoryId == SpecialCategories.favorites) {
        items = items.where((item) => favoriteIds.contains(item.id)).toList();
      } else if (selectedCategoryId != SpecialCategories.all) {
        items = items.where((item) => item.categoryId == selectedCategoryId).toList();
      }
    }

    // Apply day period filter if enabled
    if (currentDayPeriod != null) {
      filter = filter.copyWith(dayPeriod: currentDayPeriod.id);
    }

    // Apply other filters
    items = items.where((item) => filter.matches(item, locale)).toList();

    // Sort items
    switch (sortOption) {
      case MenuItemSort.name:
        items.sort((a, b) => a.getName(locale).compareTo(b.getName(locale)));
        break;
      case MenuItemSort.priceAsc:
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case MenuItemSort.priceDesc:
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case MenuItemSort.calories:
        items.sort((a, b) {
          if (a.calories == null) return 1;
          if (b.calories == null) return -1;
          return a.calories!.compareTo(b.calories!);
        });
        break;
      case MenuItemSort.newest:
        items.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
    }

    return items;
  }

  void _handleNotificationDeepLink(RestaurantNotification notification) {
    final deepLinkData = notification.parseDeepLink();
    if (deepLinkData == null) return;

    switch (deepLinkData.type) {
      case DeepLinkType.category:
        setState(() {
          selectedCategoryId = deepLinkData.id;
        });
        break;
      case DeepLinkType.item:
        AppRoutes.navigateTo(
          context,
          AppRoutes.itemDetail,
          arguments: {'itemId': deepLinkData.id},
        );
        break;
      case DeepLinkType.info:
        AppRoutes.navigateTo(context, AppRoutes.info);
        break;
    }
  }

  bool _hasNewNotifications() {
    // Check if there are unread notifications
    // This would be implemented with a notification provider
    return false;
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'pl':
        return '🇵🇱';
      case 'en':
        return '🇬🇧';
      case 'de':
        return '🇩🇪';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌐';
    }
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'pl':
        return 'Polski';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      default:
        return languageCode.toUpperCase();
    }
  }

  String _getEmptyStateMessage(String locale) {
    switch (locale) {
      case 'pl':
        return 'Brak pozycji w menu';
      case 'en':
        return 'No menu items found';
      default:
        return 'No menu items found';
    }
  }
}