import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/admin/item_form.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({super.key});

  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Filtrowanie listy
    List<MenuItem> items = menuProvider.menuItems;
    if (_selectedCategoryId != null) {
      items = items.where((i) => i.categoryId == _selectedCategoryId).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zarządzaj Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openItemForm(context, null),
            tooltip: 'Dodaj pozycję',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('Wszystkie'),
                  selected: _selectedCategoryId == null,
                  onSelected: (selected) {
                    setState(() => _selectedCategoryId = null);
                  },
                ),
                const SizedBox(width: 8),
                ...menuProvider.categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text('${cat.getDisplayIcon()} ${cat.getName('pl')}'),
                    selected: _selectedCategoryId == cat.id,
                    onSelected: (selected) {
                      setState(() => _selectedCategoryId = selected ? cat.id : null);
                    },
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      body: menuProvider.isLoadingItems
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("Brak pozycji w menu"))
          : ListView.builder(
        padding: AppTheme.responsivePadding(context),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppTheme.spacingS),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  image: item.imageUrl != null
                      ? DecorationImage(
                      image: NetworkImage(item.imageUrl!),
                      fit: BoxFit.cover
                  )
                      : null,
                ),
                child: item.imageUrl == null
                    ? Center(child: Text(item.getDietaryIcons().firstOrNull ?? '🍽️', style: const TextStyle(fontSize: 24)))
                    : null,
              ),
              title: Text(
                item.name['pl'] ?? item.name['en'] ?? 'Brak nazwy',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.price} ${settingsProvider.currency}'),
                  if (!item.isActive)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Ukryte', style: TextStyle(fontSize: 10, color: AppTheme.errorColor)),
                    )
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openItemForm(context, item),
                    tooltip: 'Edytuj',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(item),
                    color: AppTheme.errorColor,
                    tooltip: 'Usuń',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openItemForm(BuildContext context, MenuItem? item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemForm(
          item: item,
          onSave: (savedItem) async {
            final menuProvider = Provider.of<MenuProvider>(context, listen: false);
            try {
              if (item == null) {
                await menuProvider.createMenuItem(savedItem);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dodano pozycję')));
              } else {
                await menuProvider.updateMenuItem(savedItem);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zaktualizowano pozycję')));
              }
              if (mounted) Navigator.pop(context);
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e'), backgroundColor: Colors.red));
            }
          },
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _confirmDelete(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potwierdzenie'),
        content: Text('Czy na pewno usunąć: ${item.name['pl'] ?? item.name['en']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nie'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<MenuProvider>(context, listen: false).deleteMenuItem(item.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pozycja usunięta'), backgroundColor: AppTheme.successColor),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Błąd usuwania: $e'), backgroundColor: AppTheme.errorColor),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Tak, usuń'),
          ),
        ],
      ),
    );
  }
}