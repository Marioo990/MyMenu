import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
// Fixed: Using alias for Category to avoid conflicts
import '../../models/category.dart' as app_models;
import '../../providers/menu_provider.dart';
import '../../providers/language_provider.dart';
// Fixed: Correct import path for CategoryForm
import '../../widgets/admin/category_form.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('manage_categories')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(null),
            tooltip: languageProvider.translate('add_category'),
          ),
        ],
      ),
      body: menuProvider.isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : menuProvider.categories.isEmpty
          ? _buildEmptyState(languageProvider)
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

  Widget _buildEmptyState(LanguageProvider languageProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            languageProvider.translate('no_categories'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          ElevatedButton.icon(
            onPressed: () => _showCategoryDialog(null),
            icon: const Icon(Icons.add),
            label: Text(languageProvider.translate('add_first_category')),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(app_models.Category category, int index) {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context);
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
                    category.getName('en'),
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
                label: Text('$itemCount ${languageProvider.translate('items')}'),
                backgroundColor: AppTheme.backgroundColor,
              ),
              const SizedBox(width: AppTheme.spacingS),
              if (category.isActive)
                Chip(
                  label: Text(languageProvider.translate('active')),
                  backgroundColor: AppTheme.successColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.successColor),
                )
              else
                Chip(
                  label: Text(languageProvider.translate('inactive')),
                  backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.errorColor),
                ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, category),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 20),
                  const SizedBox(width: AppTheme.spacingM),
                  Text(languageProvider.translate('edit')),
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
                  const SizedBox(width: AppTheme.spacingM),
                  Text(
                    category.isActive
                        ? languageProvider.translate('deactivate')
                        : languageProvider.translate('activate'),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                  const SizedBox(width: AppTheme.spacingM),
                  Text(
                    languageProvider.translate('delete'),
                    style: const TextStyle(color: AppTheme.errorColor),
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
        .where((e) => e.key != 'en')
        .map((e) => '${_getFlagForLanguage(e.key)} ${e.value}')
        .join(' • ');
    return languages.isNotEmpty ? languages : '';
  }

  String _getFlagForLanguage(String code) {
    switch (code) {
      case 'pl':
        return '🇵🇱';
      case 'de':
        return '🇩🇪';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌍';
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

      // Update order values
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
            content: Text(
              category.isActive
                  ? 'Category deactivated'
                  : 'Category activated',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _confirmDelete(app_models.Category category) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final itemCount = menuProvider.getItemsCountByCategory(category.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.translate('confirm_delete')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${languageProvider.translate('delete_category')}: ${category.getName('en')}?'),
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
                        'This category contains $itemCount items!',
                        style: TextStyle(color: AppTheme.warningColor),
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
            child: Text(languageProvider.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await menuProvider.deleteCategory(category.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(languageProvider.translate('category_deleted')),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: Text(languageProvider.translate('delete')),
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
                      content: Text(
                        category == null
                            ? 'Category created'
                            : 'Category updated',
                      ),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
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