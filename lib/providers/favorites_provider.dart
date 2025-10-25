import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  static const String _favoritesKey = 'favorites';

  Set<String> _favoriteIds = {};
  bool _isLoading = false;

  // Getters
  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  bool get hasFavorites => _favoriteIds.isNotEmpty;
  int get favoritesCount => _favoriteIds.length;

  FavoritesProvider() {
    _loadFavorites();
  }

  // Load favorites from local storage
  Future<void> _loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];
      _favoriteIds = Set<String>.from(favorites);
    } catch (e) {
      print('Error loading favorites: $e');
      _favoriteIds = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save favorites to local storage
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoriteIds.toList());
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // Check if item is favorite
  bool isFavorite(String itemId) {
    return _favoriteIds.contains(itemId);
  }

  // Toggle favorite status
  void toggleFavorite(String itemId) {
    if (_favoriteIds.contains(itemId)) {
      removeFavorite(itemId);
    } else {
      addFavorite(itemId);
    }
  }

  // Add to favorites
  void addFavorite(String itemId) {
    _favoriteIds.add(itemId);
    _saveFavorites();
    notifyListeners();
  }

  // Remove from favorites
  void removeFavorite(String itemId) {
    _favoriteIds.remove(itemId);
    _saveFavorites();
    notifyListeners();
  }

  // Add multiple favorites
  void addMultipleFavorites(List<String> itemIds) {
    _favoriteIds.addAll(itemIds);
    _saveFavorites();
    notifyListeners();
  }

  // Remove multiple favorites
  void removeMultipleFavorites(List<String> itemIds) {
    _favoriteIds.removeAll(itemIds);
    _saveFavorites();
    notifyListeners();
  }

  // Clear all favorites
  void clearFavorites() {
    _favoriteIds.clear();
    _saveFavorites();
    notifyListeners();
  }

  // Get favorite items IDs as list
  List<String> getFavoritesList() {
    return _favoriteIds.toList();
  }

  // Check if list contains any favorites
  bool hasAnyFavorite(List<String> itemIds) {
    return itemIds.any((id) => _favoriteIds.contains(id));
  }

  // Get count of favorites from a list
  int getFavoritesCountFromList(List<String> itemIds) {
    return itemIds.where((id) => _favoriteIds.contains(id)).length;
  }

  // Export favorites (for backup)
  String exportFavorites() {
    return _favoriteIds.join(',');
  }

  // Import favorites (from backup)
  void importFavorites(String data) {
    if (data.isEmpty) {
      clearFavorites();
      return;
    }

    final imported = data.split(',').where((id) => id.isNotEmpty).toSet();
    _favoriteIds = imported;
    _saveFavorites();
    notifyListeners();
  }

  // Reload favorites from storage
  Future<void> reloadFavorites() async {
    await _loadFavorites();
  }
}