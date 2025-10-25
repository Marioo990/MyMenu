import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;
  final String locale;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final showImages = settingsProvider.showImages && settingsProvider.showThumbnails;

    return Card(
      elevation: AppTheme.elevationS,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (showImages)
                _buildThumbnail(context),

              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: showImages ? AppTheme.spacingM : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with icons
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.getName(locale),
                                    style: Theme.of(context).textTheme.headlineSmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingS),
                                ...item.getDietaryIcons().map((icon) =>
                                    Padding(
                                      padding: const EdgeInsets.only(left: AppTheme.spacingXS),
                                      child: Text(icon, style: const TextStyle(fontSize: 16)),
                                    ),
                                ),
                                if (item.isSpicy())
                                  Padding(
                                    padding: const EdgeInsets.only(left: AppTheme.spacingXS),
                                    child: Text(
                                      item.getSpicinessEmoji(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Favorite button
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? AppTheme.accentColor : AppTheme.textSecondary,
                            ),
                            onPressed: onFavoriteToggle,
                          ),
                        ],
                      ),

                      // Description
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        item.getDescription(locale),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Bottom row with price and calories
                      const SizedBox(height: AppTheme.spacingS),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Calories
                          if (item.calories != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingS,
                                vertical: AppTheme.spacingXS,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    size: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: AppTheme.spacingXS),
                                  Text(
                                    '${item.calories} kcal',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),

                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM,
                              vertical: AppTheme.spacingS,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                            ),
                            child: Text(
                              _formatPrice(item.price, context),
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Allergens warning
                      if (item.allergens.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: AppTheme.spacingS),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: AppTheme.warningColor,
                              ),
                              const SizedBox(width: AppTheme.spacingXS),
                              Expanded(
                                child: Text(
                                  _getAllergensText(locale),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.warningColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        color: AppTheme.backgroundColor,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: hasImage
          ? CachedNetworkImage(
        imageUrl: item.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderImage(),
      )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 40,
          color: AppTheme.textLight,
        ),
      ),
    );
  }

  String _formatPrice(double price, BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final currency = settingsProvider.currency;

    // Format price with proper decimal places
    final priceStr = price.toStringAsFixed(2);

    // Return with currency symbol
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

  String _getAllergensText(String locale) {
    switch (locale) {
      case 'pl':
        return 'Zawiera alergeny';
      case 'en':
        return 'Contains allergens';
      default:
        return 'Contains allergens';
    }
  }
}