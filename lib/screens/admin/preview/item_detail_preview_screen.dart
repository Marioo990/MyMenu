import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme.dart';
import '../../../models/menu_item.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/language_provider.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Consumer4<MenuProvider, SettingsProvider, FavoritesProvider, LanguageProvider>(
      builder: (context, menuProvider, settingsProvider, favoritesProvider, languageProvider, child) {
        final item = menuProvider.getMenuItem(itemId);
        final locale = languageProvider.currentLocale.languageCode;

        if (item == null) return const Scaffold(body: Center(child: Text("Item not found")));

        final isFavorite = favoritesProvider.isFavorite(item.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(item.getName(locale)),
                  background: item.imageUrl != null
                      ? CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover)
                      : Container(color: AppTheme.primaryColor),
                ),
                actions: [
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    onPressed: () => favoritesProvider.toggleFavorite(item.id),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppTheme.responsivePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.getDescription(locale), style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: AppTheme.spacingL),
                      Text("${item.price} ${settingsProvider.currency}", style: Theme.of(context).textTheme.headlineMedium),
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
}