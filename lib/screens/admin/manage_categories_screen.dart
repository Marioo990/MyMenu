import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Używamy importów absolutnych (package:), aby uniknąć błędów typów i case-sensitivity
import 'package:restaurant_menu/config/theme.dart';
import 'package:restaurant_menu/models/category.dart' as app_models;
import 'package:restaurant_menu/providers/menu_provider.dart';
// import 'package:restaurant_menu/providers/language_provider.dart'; // Opcjonalne, jeśli nieużywane
import 'package:restaurant_menu/widgets/admin/category_form.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zarządzaj Kategoriami'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(null),
            tooltip: 'Dodaj kategorię',
          ),
        ],
      ),
      body: menuProvider.isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : menuProvider.categories.isEmpty
          ? _buildEmptyState()
          : ReorderableListView.builder(
        padding: AppTheme.responsivePadding(context),
        itemCount: menuProvider.categories.length,
        onReorder: _onReorder,
        itemBuilder: (context, index) {
          final category = menuProvider.categories[index];
          return _buildCategoryCard(category, index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.category_outlined,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Brak kategorii',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          ElevatedButton.icon(
            onPressed: () => _showCategoryDialog(null),
            icon: const Icon(Icons.add),
            label: const Text('Dodaj pierwszą kategorię'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(app_models.Category category, int index) {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final itemCount = menuProvider.getItemsCountByCategory(category.id);

    return Card(
      key: ValueKey(category.id),
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            child: const Icon(Icons.drag_handle, color: AppTheme.textLight),
          ),
        ),
        title: Row(
          children: [
            Text(
              category.getDisplayIcon(),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name['pl'] ?? category.name['en'] ?? 'Bez nazwy',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (category.name.length > 1)
                    Text(
                      _getOtherLanguages(category),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppTheme.spacingS),
          child: Row(
            children: [
              Chip(
                label: Text('$itemCount pozycji'),
                backgroundColor: AppTheme.backgroundColor,
              ),
              const SizedBox(width: AppTheme.spacingS),
              if (category.isActive)
                Chip(
                  label: const Text('Aktywna'),
                  backgroundColor: AppTheme.successColor.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppTheme.successColor),
                )
              else
                Chip(
                  label: const Text('Nieaktywna'),
                  backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppTheme.errorColor),
                ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, category),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 16),
                  Text('Edytuj'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    category.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  SizedBox(width: 16),
                  Text(
                    category.isActive ? 'Dezaktywuj' : 'Aktywuj',
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                  SizedBox(width: 16),
                  Text(
                    'Usuń',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOtherLanguages(app_models.Category category) {
    final languages = category.name.entries
        .where((e) => e.key != 'pl')
        .map((e) => '${_getFlagForLanguage(e.key)} ${e.value}')
        .join(' • ');
    return languages.isNotEmpty ? languages : '';
  }

  String _getFlagForLanguage(String code) {
    switch (code) {
      case 'en': return '🇬🇧';
      case 'pl': return '🇵🇱';
      case 'de': return '🇩🇪';
      case 'es': return '🇪🇸';
      case 'fr': return '🇫🇷';
      default: return '🌍';
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      final categories = List<app_models.Category>.from(menuProvider.categories);
      final category = categories.removeAt(oldIndex);
      categories.insert(newIndex, category);

      for (int i = 0; i < categories.length; i++) {
        final updatedCategory = categories[i].copyWith(order: i);
        menuProvider.updateCategory(updatedCategory);
      }
    });
  }

  void _handleMenuAction(String action, app_models.Category category) {
    switch (action) {
      case 'edit':
        _showCategoryDialog(category);
        break;
      case 'toggle':
        _toggleCategoryStatus(category);
        break;
      case 'delete':
        _confirmDelete(category);
        break;
    }
  }

  void _toggleCategoryStatus(app_models.Category category) async {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final updatedCategory = category.copyWith(isActive: !category.isActive);

    try {
      await menuProvider.updateCategory(updatedCategory);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(category.isActive ? 'Kategoria dezaktywowana' : 'Kategoria aktywowana'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  void _confirmDelete(app_models.Category category) {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final itemCount = menuProvider.getItemsCountByCategory(category.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potwierdź usunięcie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usunąć kategorię: ${category.name['pl'] ?? category.name['en']}?'),
            if (itemCount > 0) ...[
              const SizedBox(height: AppTheme.spacingM),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppTheme.warningColor),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Text(
                        'Ta kategoria zawiera $itemCount pozycji!',
                        style: const TextStyle(color: AppTheme.warningColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await menuProvider.deleteCategory(category.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kategoria usunięta pomyślnie'), backgroundColor: AppTheme.successColor),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Błąd: $e'), backgroundColor: AppTheme.errorColor),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(app_models.Category? category) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CategoryForm(
            category: category,
            onSave: (updatedCategory) async {
              final menuProvider = Provider.of<MenuProvider>(context, listen: false);
              try {
                if (category == null) {
                  await menuProvider.createCategory(updatedCategory);
                } else {
                  await menuProvider.updateCategory(updatedCategory);
                }
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(category == null ? 'Kategoria utworzona' : 'Kategoria zaktualizowana'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Błąd: $e'), backgroundColor: AppTheme.errorColor),
                  );
                }
              }
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}