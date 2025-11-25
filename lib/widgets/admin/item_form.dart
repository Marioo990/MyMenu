import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:image_picker_web/image_picker_web.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/firebase_service.dart';

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
  final Map<String, TextEditingController> _ingredientsControllers = {};

  final _priceController = TextEditingController();
  final _caloriesController = TextEditingController();

  // Macros
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  String? _selectedCategoryId;
  final Set<String> _selectedTags = {};
  final Set<String> _selectedAllergens = {};
  final Set<String> _selectedAvailabilityIds = {}; // NOWOŚĆ: Zamiast dayPeriods
  int _spiciness = 0;
  int _order = 0;
  bool _isActive = true;

  // Image handling
  String? _imageUrl;
  Uint8List? _newImageBytes;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    final languages = ['en', 'pl'];
    for (final lang in languages) {
      _nameControllers[lang] = TextEditingController(text: item?.name[lang] ?? '');

      String desc = item?.description[lang] ?? '';
      String ingredients = '';
      String separator = lang == 'pl' ? 'Składniki:' : 'Ingredients:';

      if (desc.contains(separator)) {
        final parts = desc.split(separator);
        desc = parts[0].trim();
        if (parts.length > 1) ingredients = parts[1].trim();
      }

      _descriptionControllers[lang] = TextEditingController(text: desc);
      _ingredientsControllers[lang] = TextEditingController(text: ingredients);
    }

    _priceController.text = item?.price.toString() ?? '';
    _caloriesController.text = item?.calories?.toString() ?? '';
    _selectedCategoryId = item?.categoryId;
    _imageUrl = item?.imageUrl;
    _spiciness = item?.spiciness ?? 0;
    _order = item?.order ?? 0;
    _isActive = item?.isActive ?? true;

    if (item != null) {
      _selectedTags.addAll(item.tags);
      _selectedAllergens.addAll(item.allergens);
      _selectedAvailabilityIds.addAll(item.availabilityIds); // Pobranie availabilityIds
    }

    if (item?.macros != null) {
      _proteinController.text = item!.macros!['protein']?.toString() ?? '';
      _carbsController.text = item.macros!['carbs']?.toString() ?? '';
      _fatController.text = item.macros!['fat']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    for (var c in _nameControllers.values) c.dispose();
    for (var c in _descriptionControllers.values) c.dispose();
    for (var c in _ingredientsControllers.values) c.dispose();
    _priceController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final Uint8List? bytes = await ImagePickerWeb.getImageAsBytes();
      if (bytes != null) {
        setState(() {
          _newImageBytes = bytes;
        });
      }
    } catch (e) {
      print('Błąd wyboru zdjęcia: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edytuj pozycję' : 'Nowa pozycja'),
        actions: [
          if (_isUploading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
          if (!_isUploading) ...[
            TextButton(onPressed: widget.onCancel, child: const Text('Anuluj')),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor, foregroundColor: Colors.white),
              child: const Text('Zapisz'),
            ),
            const SizedBox(width: 16),
          ]
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sekcja Zdjęcia i Kategorii
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(color: Colors.grey[400]!),
                        image: _newImageBytes != null
                            ? DecorationImage(image: MemoryImage(_newImageBytes!), fit: BoxFit.cover)
                            : (_imageUrl != null
                            ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                            : null),
                      ),
                      child: _newImageBytes == null && _imageUrl == null
                          ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.add_a_photo, size: 40), Text("Dodaj zdjęcie")],
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingL),
                  Expanded(
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(labelText: 'Kategoria *', prefixIcon: Icon(Icons.category)),
                          items: menuProvider.categories.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text("${c.getDisplayIcon()} ${c.getName('pl')}"),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedCategoryId = v),
                          validator: (v) => v == null ? 'Wymagane' : null,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(labelText: 'Cena *', prefixIcon: Icon(Icons.attach_money)),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) => v!.isEmpty ? 'Wymagane' : null,
                        ),
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: AppTheme.spacingL),
              const Divider(),

              // 2. Nazwy i Opisy
              _buildSectionHeader('Informacje o daniu'),
              _buildLanguageFields('pl', 'Polski', Icons.restaurant),
              const SizedBox(height: AppTheme.spacingM),
              _buildLanguageFields('en', 'Angielski', Icons.language),

              const SizedBox(height: AppTheme.spacingL),
              const Divider(),

              // 3. Dieta i Alergeny
              _buildSectionHeader('Dieta i Alergeny'),
              Wrap(
                spacing: 8,
                children: AppConstants.dietaryTags.map((tag) => FilterChip(
                  label: Text(tag),
                  selected: _selectedTags.contains(tag),
                  onSelected: (s) => setState(() => s ? _selectedTags.add(tag) : _selectedTags.remove(tag)),
                )).toList(),
              ),
              const SizedBox(height: 8),
              const Text("Alergeny:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: AppConstants.commonAllergens.map((a) => FilterChip(
                  label: Text(a),
                  selected: _selectedAllergens.contains(a),
                  selectedColor: Colors.red[100],
                  onSelected: (s) => setState(() => s ? _selectedAllergens.add(a) : _selectedAllergens.remove(a)),
                )).toList(),
              ),

              // 4. Dostępność (Pory dnia) - NOWOŚĆ
              const SizedBox(height: AppTheme.spacingL),
              const Divider(),
              _buildSectionHeader('Dostępność (Pory Dnia)'),
              Wrap(
                spacing: 8,
                children: menuProvider.dayPeriods.map((period) {
                  final periodId = period.id;
                  return FilterChip(
                    label: Text("${period.getDisplayIcon()} ${period.getName('pl')}"),
                    selected: _selectedAvailabilityIds.contains(periodId),
                    onSelected: (s) => setState(() => s ? _selectedAvailabilityIds.add(periodId) : _selectedAvailabilityIds.remove(periodId)),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppTheme.spacingL),
              const Divider(),

              // 5. Wartości odżywcze
              _buildSectionHeader('Wartości odżywcze'),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _caloriesController, decoration: const InputDecoration(labelText: 'Kalorie (kcal)'))),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _proteinController, decoration: const InputDecoration(labelText: 'Białko (g)'))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _carbsController, decoration: const InputDecoration(labelText: 'Węglowodany (g)'))),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _fatController, decoration: const InputDecoration(labelText: 'Tłuszcz (g)'))),
                ],
              ),

              const SizedBox(height: AppTheme.spacingL),
              const Divider(),

              // 6. Ustawienia
              _buildSectionHeader('Ustawienia'),
              Row(
                children: [
                  const Text("Ostrość: "),
                  ...List.generate(4, (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(index == 0 ? 'Łagodne' : '🌶️' * index),
                      selected: _spiciness == index,
                      onSelected: (s) => setState(() => _spiciness = index),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Aktywne'),
                subtitle: const Text('Widoczne dla klientów'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor)),
    );
  }

  Widget _buildLanguageFields(String langCode, String langName, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(langName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameControllers[langCode],
              decoration: InputDecoration(labelText: 'Nazwa ($langCode)', prefixIcon: Icon(icon)),
              validator: (v) => langCode == 'en' && (v?.isEmpty ?? true) ? 'Nazwa (EN) jest wymagana' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionControllers[langCode],
              decoration: InputDecoration(labelText: 'Opis ($langCode)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ingredientsControllers[langCode],
              decoration: InputDecoration(
                labelText: 'Składniki ($langCode) - opcjonalne',
                prefixIcon: const Icon(Icons.list),
                helperText: 'Będą wyświetlane w sekcji szczegółów',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      // POBRANIE RESTAURANT ID Z PROVIDERA
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      final restaurantId = menuProvider.restaurantId;

      if (restaurantId == null) throw Exception("Brak kontekstu restauracji! (restaurantId is null)");

      // 1. Upload image if new one selected
      String? finalImageUrl = widget.item?.imageUrl; // Use existing if not changed
      if (_newImageBytes != null) {
        final firebaseService = Provider.of<FirebaseService>(context, listen: false);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        // Upload do folderu konkretnej restauracji
        finalImageUrl = await firebaseService.uploadImage(restaurantId, fileName, _newImageBytes!);
      }

      // 2. Prepare Data
      final nameMap = <String, String>{};
      final descMap = <String, String>{};

      _nameControllers.forEach((lang, ctrl) {
        if (ctrl.text.isNotEmpty) nameMap[lang] = ctrl.text;
      });

      _descriptionControllers.forEach((lang, ctrl) {
        String fullDesc = ctrl.text;
        String ingredients = _ingredientsControllers[lang]?.text ?? '';

        if (ingredients.isNotEmpty) {
          String prefix = lang == 'pl' ? 'Składniki:' : 'Ingredients:';
          fullDesc = '$fullDesc\n\n$prefix $ingredients';
        }

        if (fullDesc.isNotEmpty) descMap[lang] = fullDesc;
      });

      final macros = <String, dynamic>{};
      if (_proteinController.text.isNotEmpty) macros['protein'] = double.tryParse(_proteinController.text);
      if (_carbsController.text.isNotEmpty) macros['carbs'] = double.tryParse(_carbsController.text);
      if (_fatController.text.isNotEmpty) macros['fat'] = double.tryParse(_fatController.text);

      // 3. Create Object
      final item = MenuItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        restaurantId: restaurantId,
        name: nameMap,
        description: descMap,
        price: double.tryParse(_priceController.text) ?? 0.0,
        categoryId: _selectedCategoryId!,
        imageUrl: finalImageUrl,
        calories: int.tryParse(_caloriesController.text),
        allergens: _selectedAllergens.toList(),
        spiciness: _spiciness,
        availabilityIds: _selectedAvailabilityIds.toList(), // NOWE POLE
        tags: _selectedTags.toList(),
        macros: macros.isNotEmpty ? macros : null,
        isActive: _isActive,
        order: _order,
        createdAt: widget.item?.createdAt,
      );

      widget.onSave(item);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd zapisu: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}