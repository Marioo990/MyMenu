import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/menu_item.dart';
// Removed unused import: import '../../models/category.dart';
import '../../providers/menu_provider.dart';
import '../../providers/language_provider.dart';

class ItemForm extends StatefulWidget {
  final MenuItem? item;
  final Function(MenuItem) onSave;
  final VoidCallback onCancel;

  const ItemForm({
    super.key,
    this.item,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};
  final _priceController = TextEditingController();
  final _caloriesController = TextEditingController();

  // Macros controllers
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();
  final _sodiumController = TextEditingController();

  String? _selectedCategoryId;
  final Set<String> _selectedTags = {};
  final Set<String> _selectedAllergens = {};
  final Set<String> _selectedDayPeriods = {};
  int _spiciness = 0;
  int _order = 0;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    // Initialize name and description controllers
    final languages = ['en', 'pl', 'de', 'es', 'fr'];
    for (final lang in languages) {
      _nameControllers[lang] = TextEditingController(
        text: item?.name[lang] ?? '',
      );
      _descriptionControllers[lang] = TextEditingController(
        text: item?.description[lang] ?? '',
      );
    }

    // Initialize other fields
    _priceController.text = item?.price.toStringAsFixed(2) ?? '';
    _caloriesController.text = item?.calories?.toString() ?? '';
    _selectedCategoryId = item?.categoryId;
    _spiciness = item?.spiciness ?? 0;
    _order = item?.order ?? 0;
    _isActive = item?.isActive ?? true;

    // Initialize tags and allergens
    if (item != null) {
      _selectedTags.addAll(item.tags);
      _selectedAllergens.addAll(item.allergens);
      _selectedDayPeriods.addAll(item.dayPeriods);
    }

    // Initialize macros
    if (item?.macros != null) {
      _proteinController.text = item!.macros!['protein']?.toString() ?? '';
      _carbsController.text = item.macros!['carbs']?.toString() ?? '';
      _fatController.text = item.macros!['fat']?.toString() ?? '';
      _fiberController.text = item.macros!['fiber']?.toString() ?? '';
      _sugarController.text = item.macros!['sugar']?.toString() ?? '';
      _sodiumController.text = item.macros!['sodium']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    for (final controller in _descriptionControllers.values) {
      controller.dispose();
    }
    _priceController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? languageProvider.translate('edit_item')
              : languageProvider.translate('add_item'),
        ),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: widget.onCancel,
            child: Text(languageProvider.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            child: Text(languageProvider.translate('save')),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildBasicInfoSection(menuProvider, languageProvider),

              const SizedBox(height: AppTheme.spacingL),

              // Dietary Information
              _buildDietarySection(languageProvider),

              const SizedBox(height: AppTheme.spacingL),

              // Nutrition Information
              _buildNutritionSection(languageProvider),

              const SizedBox(height: AppTheme.spacingL),

              // Availability
              _buildAvailabilitySection(menuProvider, languageProvider),

              const SizedBox(height: AppTheme.spacingL),

              // Settings
              _buildSettingsSection(languageProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(MenuProvider menuProvider, LanguageProvider languageProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Category Selection
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: languageProvider.translate('category'),
                prefixIcon: const Icon(Icons.category),
              ),
              items: menuProvider.categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Text(category.getDisplayIcon()),
                      const SizedBox(width: AppTheme.spacingM),
                      Text(category.getName('en')),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Name Fields
            TextFormField(
              controller: _nameControllers['en'],
              decoration: const InputDecoration(
                labelText: 'Name (English) *',
                prefixIcon: Text('🇬🇧', style: TextStyle(fontSize: 20)),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'English name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Other language names
            ..._nameControllers.entries
                .where((e) => e.key != 'en')
                .map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                child: TextFormField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: 'Name (${languageProvider.getLanguageName(entry.key)})',
                    prefixIcon: Text(
                      languageProvider.getLanguageFlag(entry.key),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: AppTheme.spacingL),

            // Description Fields
            TextFormField(
              controller: _descriptionControllers['en'],
              decoration: const InputDecoration(
                labelText: 'Description (English) *',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'English description is required';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Other language descriptions
            ..._descriptionControllers.entries
                .where((e) => e.key != 'en')
                .map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                child: TextFormField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: 'Description (${languageProvider.getLanguageName(entry.key)})',
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              );
            }).toList(),

            const SizedBox(height: AppTheme.spacingL),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price *',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Price is required';
                }
                if (double.tryParse(value!) == null) {
                  return 'Invalid price';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietarySection(LanguageProvider languageProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: AppTheme.secondaryColor),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  'Dietary Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Dietary Tags
            Text(
              'Dietary Tags',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Wrap(
              spacing: AppTheme.spacingS,
              runSpacing: AppTheme.spacingS,
              children: AppConstants.dietaryTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Allergens
            Text(
              'Allergens',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Wrap(
              spacing: AppTheme.spacingS,
              runSpacing: AppTheme.spacingS,
              children: AppConstants.commonAllergens.map((allergen) {
                final isSelected = _selectedAllergens.contains(allergen);
                return FilterChip(
                  label: Text(allergen),
                  selected: isSelected,
                  selectedColor: AppTheme.warningColor.withOpacity(0.2),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergens.add(allergen);
                      } else {
                        _selectedAllergens.remove(allergen);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Spiciness
            Text(
              'Spiciness Level',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                for (int i = 0; i <= 3; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacingS),
                    child: ChoiceChip(
                      label: Text(_getSpicinessLabel(i)),
                      selected: _spiciness == i,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _spiciness = i;
                          });
                        }
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection(LanguageProvider languageProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: AppTheme.warningColor),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  'Nutrition Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Calories
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories',
                prefixIcon: Icon(Icons.local_fire_department),
                suffixText: 'kcal',
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Macros
            Text(
              'Macronutrients',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppTheme.spacingM),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: 'Protein',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(
                      labelText: 'Carbs',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    decoration: const InputDecoration(
                      labelText: 'Fat',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingM),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fiberController,
                    decoration: const InputDecoration(
                      labelText: 'Fiber',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _sugarController,
                    decoration: const InputDecoration(
                      labelText: 'Sugar',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _sodiumController,
                    decoration: const InputDecoration(
                      labelText: 'Sodium',
                      suffixText: 'mg',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection(MenuProvider menuProvider, LanguageProvider languageProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: AppTheme.successColor),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  'Availability',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Day Periods
            if (menuProvider.dayPeriods.isNotEmpty) ...[
              Text(
                'Day Periods',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Wrap(
                spacing: AppTheme.spacingS,
                runSpacing: AppTheme.spacingS,
                children: menuProvider.dayPeriods.map((period) {
                  final isSelected = _selectedDayPeriods.contains(period.id);
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(period.getDisplayIcon()),
                        const SizedBox(width: AppTheme.spacingXS),
                        Text(period.getName('en')),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDayPeriods.add(period.id);
                        } else {
                          _selectedDayPeriods.remove(period.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(LanguageProvider languageProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: AppTheme.textSecondary),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Display Order
            TextFormField(
              initialValue: _order.toString(),
              decoration: const InputDecoration(
                labelText: 'Display Order',
                prefixIcon: Icon(Icons.sort),
                helperText: 'Lower numbers appear first',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _order = int.tryParse(value) ?? 0;
              },
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Active Status
            SwitchListTile(
              title: Text(languageProvider.translate('active')),
              subtitle: const Text('Item is visible to customers'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getSpicinessLabel(int level) {
    switch (level) {
      case 0:
        return 'None';
      case 1:
        return '🌶️';
      case 2:
        return '🌶️🌶️';
      case 3:
        return '🌶️🌶️🌶️';
      default:
        return 'None';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Build name and description maps
    final nameMap = <String, String>{};
    final descriptionMap = <String, String>{};

    _nameControllers.forEach((lang, controller) {
      if (controller.text.isNotEmpty) {
        nameMap[lang] = controller.text;
      }
    });

    _descriptionControllers.forEach((lang, controller) {
      if (controller.text.isNotEmpty) {
        descriptionMap[lang] = controller.text;
      }
    });

    // Build macros map
    final macros = <String, dynamic>{};
    if (_proteinController.text.isNotEmpty) {
      macros['protein'] = double.tryParse(_proteinController.text);
    }
    if (_carbsController.text.isNotEmpty) {
      macros['carbs'] = double.tryParse(_carbsController.text);
    }
    if (_fatController.text.isNotEmpty) {
      macros['fat'] = double.tryParse(_fatController.text);
    }
    if (_fiberController.text.isNotEmpty) {
      macros['fiber'] = double.tryParse(_fiberController.text);
    }
    if (_sugarController.text.isNotEmpty) {
      macros['sugar'] = double.tryParse(_sugarController.text);
    }
    if (_sodiumController.text.isNotEmpty) {
      macros['sodium'] = double.tryParse(_sodiumController.text);
    }

    final item = MenuItem(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameMap,
      description: descriptionMap,
      price: double.parse(_priceController.text),
      categoryId: _selectedCategoryId!,
      calories: int.tryParse(_caloriesController.text),
      allergens: _selectedAllergens.toList(),
      spiciness: _spiciness,
      dayPeriods: _selectedDayPeriods.toList(),
      tags: _selectedTags.toList(),
      macros: macros.isNotEmpty ? macros : null,
      isActive: _isActive,
      order: _order,
      createdAt: widget.item?.createdAt,
    );

    widget.onSave(item);
  }
}