import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/category.dart';
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

  // Available icons for categories
  final List<String> _availableIcons = [
    '🍽️', '🥗', '🍲', '🍕', '🍝', '🍔', '🥪', '🌮', '🥘', '🍜',
    '🥩', '🍗', '🐟', '🦞', '🍳', '☕', '🍷', '🍺', '🥤', '🍹',
    '🍰', '🧁', '🍮', '🍩', '🍪', '🍨', '🥐', '🥯', '🍞', '🫖',
  ];

  @override
  void initState() {
    super.initState();

    final category = widget.category;

    // Initialize name controllers
    final languages = ['en', 'pl', 'de', 'es', 'fr'];
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
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? languageProvider.translate('edit_category')
              : languageProvider.translate('add_category'),
        ),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: widget.onCancel,
            child: Text(
              languageProvider.translate('cancel'),
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
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
              // Icon Selection
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
                            languageProvider.translate('icon'),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Current Icon Display
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

                      // Icon Grid
                      Wrap(
                        spacing: AppTheme.spacingS,
                        runSpacing: AppTheme.spacingS,
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

              // Name Fields
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
                            languageProvider.translate('category_names'),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // English (Required)
                      TextFormField(
                        controller: _nameControllers['en'],
                        decoration: InputDecoration(
                          labelText: 'Name (English) *',
                          hintText: 'e.g., Appetizers',
                          prefixIcon: Text(
                            languageProvider.getLanguageFlag('en'),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'English name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingM),

                      // Other Languages (Optional)
                      ..._nameControllers.entries
                          .where((e) => e.key != 'en')
                          .map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                          child: TextFormField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: 'Name (${languageProvider.getLanguageName(entry.key)})',
                              hintText: 'Optional',
                              prefixIcon: Text(
                                languageProvider.getLanguageFlag(entry.key),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Settings
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
                            languageProvider.translate('settings'),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Order
                      TextFormField(
                        initialValue: _order.toString(),
                        decoration: InputDecoration(
                          labelText: languageProvider.translate('display_order'),
                          hintText: '0',
                          prefixIcon: const Icon(Icons.sort),
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
                        subtitle: Text(
                          _isActive
                              ? 'Category is visible to customers'
                              : 'Category is hidden from customers',
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

              const SizedBox(height: AppTheme.spacingXL),

              // Action Buttons (Mobile)
              if (AppTheme.isMobile(context))
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onCancel,
                        child: Text(languageProvider.translate('cancel')),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                        ),
                        child: Text(languageProvider.translate('save')),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Build name map
    final nameMap = <String, String>{};
    _nameControllers.forEach((lang, controller) {
      if (controller.text.isNotEmpty) {
        nameMap[lang] = controller.text;
      }
    });

    // Ensure at least English name exists
    if (!nameMap.containsKey('en')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('English name is required'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final category = Category(
      id: widget.category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameMap,
      icon: _selectedIcon,
      order: _order,
      isActive: _isActive,
      createdAt: widget.category?.createdAt,
    );

    widget.onSave(category);
  }
}