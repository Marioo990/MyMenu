import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/language_provider.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer4<MenuProvider, SettingsProvider, FavoritesProvider, LanguageProvider>(
      builder: (context, menuProvider, settingsProvider, favoritesProvider, languageProvider, child) {
        final item = menuProvider.getMenuItem(widget.itemId);
        final locale = languageProvider.currentLocale.languageCode;

        if (item == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(languageProvider.translate('error')),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(languageProvider.translate('no_items_found')),
                ],
              ),
            ),
          );
        }

        final isFavorite = favoritesProvider.isFavorite(item.id);
        final showImages = settingsProvider.showImages;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: showImages && item.imageUrl != null ? 300 : 100,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      item.getName(locale),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  background: showImages && item.imageUrl != null
                      ? _buildHeroImage(item)
                      : Container(color: AppTheme.primaryColor),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppTheme.accentColor : null,
                    ),
                    onPressed: () {
                      favoritesProvider.toggleFavorite(item.id);
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppTheme.responsivePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price and Category
                      _buildPriceAndCategory(item, locale, context, menuProvider),

                      const SizedBox(height: AppTheme.spacingL),

                      // Dietary Icons and Spiciness
                      _buildDietaryInfo(item),

                      const SizedBox(height: AppTheme.spacingL),

                      // Description
                      _buildSection(
                        title: languageProvider.translate('description'),
                        child: Text(
                          item.getDescription(locale),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingL),

                      // Nutrition Info
                      if (item.calories != null || item.macros != null)
                        _buildNutritionInfo(item, languageProvider),

                      // Allergens
                      if (item.allergens.isNotEmpty)
                        _buildAllergens(item, languageProvider),

                      // Ingredients (if available in description)
                      if (item.description.values.any((d) => d.contains('Składniki:') || d.contains('Ingredients:')))
                        _buildIngredients(item, locale, languageProvider),

                      const SizedBox(height: AppTheme.spacingXXL),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroImage(MenuItem item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: item.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppTheme.backgroundColor,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppTheme.backgroundColor,
            child: const Icon(
              Icons.restaurant,
              size: 80,
              color: AppTheme.textLight,
            ),
          ),
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndCategory(MenuItem item, String locale, BuildContext context, MenuProvider menuProvider) {
    final category = menuProvider.getCategory(item.categoryId);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Category
        if (category != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.getDisplayIcon(),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  category.getName(locale),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),

        // Price
        Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
              child: Text(
                _formatPrice(item.price, settingsProvider),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDietaryInfo(MenuItem item) {
    final dietaryIcons = item.getDietaryIcons();
    if (dietaryIcons.isEmpty && !item.isSpicy()) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AppTheme.spacingM,
      runSpacing: AppTheme.spacingS,
      children: [
        ...dietaryIcons.map((icon) => _buildInfoChip(icon, '')),
        if (item.isSpicy())
          _buildInfoChip(
            item.getSpicinessEmoji(),
            _getSpicinessLabel(item.spiciness),
          ),
      ],
    );
  }

  Widget _buildInfoChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          if (label.isNotEmpty) ...[
            const SizedBox(width: AppTheme.spacingS),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingM),
        child,
      ],
    );
  }

  Widget _buildNutritionInfo(MenuItem item, LanguageProvider languageProvider) {
    return _buildSection(
      title: languageProvider.translate('nutrition'),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Column(
          children: [
            if (item.calories != null)
              _buildNutritionRow(
                languageProvider.translate('calories'),
                '${item.calories} kcal',
                Icons.local_fire_department,
              ),
            if (item.macros != null) ...[
              if (item.macros!['protein'] != null)
                _buildNutritionRow(
                  languageProvider.translate('protein'),
                  '${item.macros!['protein']}g',
                  Icons.fitness_center,
                ),
              if (item.macros!['carbs'] != null)
                _buildNutritionRow(
                  languageProvider.translate('carbs'),
                  '${item.macros!['carbs']}g',
                  Icons.bakery_dining,
                ),
              if (item.macros!['fat'] != null)
                _buildNutritionRow(
                  languageProvider.translate('fat'),
                  '${item.macros!['fat']}g',
                  Icons.water_drop,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergens(MenuItem item, LanguageProvider languageProvider) {
    return _buildSection(
      title: languageProvider.translate('allergens'),
      child: Wrap(
        spacing: AppTheme.spacingS,
        runSpacing: AppTheme.spacingS,
        children: item.allergens.map((allergen) {
          return Chip(
            label: Text(allergen),
            backgroundColor: AppTheme.warningColor.withOpacity(0.1),
            side: BorderSide(color: AppTheme.warningColor.withOpacity(0.5)),
            avatar: const Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: AppTheme.warningColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIngredients(MenuItem item, String locale, LanguageProvider languageProvider) {
    // Extract ingredients from description if formatted properly
    final description = item.getDescription(locale);
    final ingredientsMarker = locale == 'pl' ? 'Składniki:' : 'Ingredients:';

    if (!description.contains(ingredientsMarker)) {
      return const SizedBox.shrink();
    }

    final ingredientsPart = description.split(ingredientsMarker).last;
    final ingredients = ingredientsPart.split(',').map((i) => i.trim()).toList();

    return _buildSection(
      title: languageProvider.translate('ingredients'),
      child: Wrap(
        spacing: AppTheme.spacingS,
        runSpacing: AppTheme.spacingS,
        children: ingredients.map((ingredient) {
          return Chip(
            label: Text(ingredient),
            backgroundColor: AppTheme.backgroundColor,
          );
        }).toList(),
      ),
    );
  }

  String _formatPrice(double price, SettingsProvider settingsProvider) {
    final currency = settingsProvider.currency;
    final priceStr = price.toStringAsFixed(2);

    switch (currency) {
      case 'PLN':
        return '$priceStr zł';
      case 'EUR':
        return '€$priceStr';
      case 'USD':
        return '\$$priceStr';
      case 'GBP':
        return '£$priceStr';
      default:
        return '$priceStr $currency';
    }
  }

  String _getSpicinessLabel(int spiciness) {
    switch (spiciness) {
      case 1:
        return 'Mild';
      case 2:
        return 'Medium';
      case 3:
        return 'Hot';
      default:
        return '';
    }
  }
}