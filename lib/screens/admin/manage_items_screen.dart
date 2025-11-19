import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/settings_provider.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({super.key});

  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    // final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zarządzaj Menu'), // PL
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddItemDialog,
            tooltip: 'Dodaj pozycję', // PL
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
              // Wyświetlamy nazwę w zależności od dostępności, preferowany polski
              title: Text(item.name['pl'] ?? item.name['en'] ?? 'Brak nazwy'),
              subtitle: Text(
                  '${item.price} ${Provider.of<SettingsProvider>(context).currency}'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dodaj pozycję'), // PL
        content: const Text('Formularz dodawania pozycji pojawi się tutaj'), // PL
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'), // PL
          ),
          ElevatedButton(
            onPressed: () {
              // Add item logic
              Navigator.pop(context);
            },
            child: const Text('Zapisz'), // PL
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edytuj pozycję'), // PL
        content: Text('Formularz edycji dla: ${item.name['pl'] ?? item.name['en']}'), // PL
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'), // PL
          ),
          ElevatedButton(
            onPressed: () {
              // Edit item logic
              Navigator.pop(context);
            },
            child: const Text('Zapisz'), // PL
          ),
        ],
      ),
    );
  }

  void _confirmDelete(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potwierdzenie'), // PL
        content: Text('Czy na pewno usunąć: ${item.name['pl'] ?? item.name['en']}?'), // PL
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nie'), // PL
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<MenuProvider>(context, listen: false)
                  .deleteMenuItem(item.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pozycja usunięta'), // PL
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Tak'), // PL
          ),
        ],
      ),
    );
  }
}