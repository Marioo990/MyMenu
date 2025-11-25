import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/category.dart';
import '../../providers/menu_provider.dart';
import '../../providers/language_provider.dart';

class CategoryForm extends StatefulWidget {
  final Category? category;
  final Function(Category) onSave;
  final VoidCallback onCancel;

  const CategoryForm({
    super.key,
    this.category,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _nameControllers = {};
  late String _selectedIcon;
  late int _order;
  late bool _isActive;

  // Pełna lista ikon
  final List<String> _availableIcons = [
    '🍽️', '🥗', '🍲', '🍕', '🍝', '🍔', '🥪', '🌮', '🥘', '🍜',
    '🥩', '🍗', '🐟', '🦞', '🍳', '☕', '🍷', '🍺', '🥤', '🍹',
    '🍰', '🧁', '🍮', '🍩', '🍪', '🍨', '🥐', '🥯', '🍞', '🫖',
  ];

  @override
  void initState() {
    super.initState();

    final category = widget.category;

    // Inicjalizacja kontrolerów dla języków (PL i EN jako główne)
    final languages = ['en', 'pl'];
    for (final lang in languages) {
      _nameControllers[lang] = TextEditingController(
        text: category?.name[lang] ?? '',
      );
    }

    _selectedIcon = category?.icon ?? '🍽️';
    _order = category?.order ?? 0;
    _isActive = category?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final languageProvider = Provider.of<LanguageProvider>(context); // Nieużywane bezpośrednio w UI formularza
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edytuj kategorię' : 'Dodaj kategorię'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: widget.onCancel,
            child: const Text(
              'Anuluj',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Zapisz'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sekcja IKON
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_emotions, color: AppTheme.primaryColor),
                          const SizedBox(width: AppTheme.spacingM),
                          Text(
                            'Ikona',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Podgląd wybranej ikony
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _selectedIcon,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingL),

                      // Siatka ikon
                      Wrap(
                        spacing: AppTheme.spacingS,
                        runSpacing: AppTheme.spacingS,
                        alignment: WrapAlignment.center,
                        children: _availableIcons.map((icon) {
                          final isSelected = icon == _selectedIcon;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIcon = icon;
                              });
                            },
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.1)
                                    : AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.textLight.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // 2. Sekcja NAZW
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.text_fields, color: AppTheme.secondaryColor),
                          const SizedBox(width: AppTheme.spacingM),
                          Text(
                            'Nazwa kategorii',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Generowanie pól dla każdego języka
                      ..._nameControllers.entries.map((entry) {
                        final lang = entry.key;
                        final controller = entry.value;
                        final label = lang == 'pl' ? 'Nazwa (Polski)' : 'Nazwa (Angielski)';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: label,
                              prefixIcon: const Icon(Icons.language),
                              helperText: lang == 'en' ? 'Wymagane jako nazwa domyślna' : null,
                            ),
                            validator: (value) {
                              if (lang == 'en' && (value?.isEmpty ?? true)) {
                                return 'Nazwa angielska jest wymagana (technicznie)';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // 3. Sekcja USTAWIEŃ
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.settings, color: AppTheme.warningColor),
                          const SizedBox(width: AppTheme.spacingM),
                          Text(
                            'Ustawienia',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Kolejność
                      TextFormField(
                        initialValue: _order.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Kolejność wyświetlania',
                          hintText: '0',
                          prefixIcon: Icon(Icons.sort),
                          helperText: 'Mniejsze liczby wyświetlane są wcześniej',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _order = int.tryParse(value) ?? 0;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingM),

                      // Status aktywności
                      SwitchListTile(
                        title: const Text('Aktywna'),
                        subtitle: Text(
                          _isActive
                              ? 'Kategoria jest widoczna dla klientów'
                              : 'Kategoria jest ukryta',
                        ),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                        secondary: Icon(
                          _isActive ? Icons.visibility : Icons.visibility_off,
                          color: _isActive ? AppTheme.successColor : AppTheme.textLight,
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // 1. Pobieramy restaurantId z MenuProvidera (który ma je ustawione po zalogowaniu)
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final restaurantId = menuProvider.restaurantId;

    // Walidacja krytyczna dla SaaS
    if (restaurantId == null || restaurantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BŁĄD KRYTYCZNY: Brak identyfikatora restauracji. Zaloguj się ponownie.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // 2. Budowanie mapy nazw
    final nameMap = <String, String>{};
    _nameControllers.forEach((lang, controller) {
      if (controller.text.isNotEmpty) {
        nameMap[lang] = controller.text;
      }
    });

    // Zabezpieczenie: fallbacki językowe
    if (!nameMap.containsKey('en') && nameMap.containsKey('pl')) {
      nameMap['en'] = nameMap['pl']!;
    }
    if (!nameMap.containsKey('pl') && nameMap.containsKey('en')) {
      nameMap['pl'] = nameMap['en']!;
    }

    // 3. Tworzenie obiektu z restaurantId
    final category = Category(
      id: widget.category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      restaurantId: restaurantId, // <-- To jest kluczowe
      name: nameMap,
      icon: _selectedIcon,
      order: _order,
      isActive: _isActive,
      createdAt: widget.category?.createdAt,
    );

    widget.onSave(category);
  }
}