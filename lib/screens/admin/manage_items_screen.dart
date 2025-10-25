import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_provider.dart';
import '../../providers/language_provider.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({super.key});

  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('manage_menu')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddItemDialog,
            tooltip: languageProvider.translate('add_item'),
          ),
        ],
      ),
      body: menuProvider.isLoadingItems
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: AppTheme.responsivePadding(context),
        itemCount: menuProvider.menuItems.length,
        itemBuilder: (context, index) {
          final item = menuProvider.menuItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  item.getDietaryIcons().isNotEmpty
                      ? item.getDietaryIcons().first
                      : '🍽️',
                ),
              ),
              title: Text(item.getName('en')),
              subtitle: Text('${item.price} ${Provider.of<SettingsProvider>(context).currency}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditItemDialog(item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(item),
                    color: AppTheme.errorColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddItemDialog() {
    // Show dialog to add new item
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Provider.of<LanguageProvider>(context).translate('add_item')),
        content: const Text('Add item form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Provider.of<LanguageProvider>(context).translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              // Add item logic
              Navigator.pop(context);
            },
            child: Text(Provider.of<LanguageProvider>(context).translate('save')),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(MenuItem item) {
    // Show dialog to edit item
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Provider.of<LanguageProvider>(context).translate('edit_item')),
        content: Text('Edit form for ${item.getName('en')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Provider.of<LanguageProvider>(context).translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              // Edit item logic
              Navigator.pop(context);
            },
            child: Text(Provider.of<LanguageProvider>(context).translate('save')),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Provider.of<LanguageProvider>(context).translate('confirm')),
        content: Text('${Provider.of<LanguageProvider>(context).translate('are_you_sure')} ${item.getName('en')}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Provider.of<LanguageProvider>(context).translate('no')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<MenuProvider>(context, listen: false)
                  .deleteMenuItem(item.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(Provider.of<LanguageProvider>(context, listen: false)
                        .translate('item_deleted')),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(Provider.of<LanguageProvider>(context).translate('yes')),
          ),
        ],
      ),
    );
  }
}