import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/language_provider.dart';

class SearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String? initialQuery;

  const SearchBar({
    super.key,
    required this.onSearchChanged,
    this.initialQuery,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late final TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onSearchChanged(_searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
    _focusNode.unfocus();
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDesktop = AppTheme.isDesktop(context);

    return AnimatedContainer(
      duration: AppTheme.animationNormal,
      height: _isExpanded ? 56 : 48,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        boxShadow: _isExpanded
            ? [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: languageProvider.translate('search_menu'),
          hintStyle: TextStyle(color: AppTheme.textLight),
          prefixIcon: AnimatedContainer(
            duration: AppTheme.animationFast,
            child: Icon(
              Icons.search,
              color: _isExpanded ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: AppTheme.textSecondary,
            ),
            onPressed: _clearSearch,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.backgroundColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? AppTheme.spacingL : AppTheme.spacingM,
            vertical: AppTheme.spacingM,
          ),
        ),
        onTap: () {
          setState(() {
            _isExpanded = true;
          });
        },
        onSubmitted: (value) {
          _focusNode.unfocus();
          setState(() {
            _isExpanded = false;
          });
        },
        textInputAction: TextInputAction.search,
      ),
    );
  }
}

// Alternative Animated Search Bar with Icon Transition
class AnimatedSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterTap;

  const AnimatedSearchBar({
    super.key,
    required this.onSearchChanged,
    this.onFilterTap,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.animationNormal,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _searchController.addListener(() {
      widget.onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _animationController.forward();
        _focusNode.requestFocus();
      } else {
        _animationController.reverse();
        _searchController.clear();
        widget.onSearchChanged('');
        _focusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    // final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Search Icon / Back Button
                      IconButton(
                        icon: AnimatedSwitcher(
                          duration: AppTheme.animationFast,
                          child: Icon(
                            _isSearching ? Icons.arrow_back : Icons.search,
                            key: ValueKey(_isSearching),
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        onPressed: _toggleSearch,
                      ),

                      // Text Field
                      Expanded(
                        child: AnimatedContainer(
                          duration: AppTheme.animationNormal,
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            enabled: _isSearching,
                            decoration: InputDecoration(
                              hintText: _isSearching
                                  ? languageProvider.translate('search_hint')
                                  : languageProvider.translate('tap_to_search'),
                              hintStyle: TextStyle(
                                color: AppTheme.textLight,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.isEmpty) {
                                _toggleSearch();
                              }
                            },
                          ),
                        ),
                      ),

                      // Clear Button
                      AnimatedOpacity(
                        opacity: _searchController.text.isNotEmpty ? 1.0 : 0.0,
                        duration: AppTheme.animationFast,
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _searchController.text.isNotEmpty
                              ? () {
                            _searchController.clear();
                            widget.onSearchChanged('');
                          }
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Filter Button
          if (widget.onFilterTap != null) ...[
            const SizedBox(width: AppTheme.spacingM),
            AnimatedContainer(
              duration: AppTheme.animationNormal,
              width: _isSearching ? 48 : 56,
              child: Material(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                child: InkWell(
                  onTap: widget.onFilterTap,
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: const Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Suggestion Search Bar with Autocomplete
class SuggestionSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final List<String> suggestions;

  const SuggestionSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.suggestions,
  });

  @override
  State<SuggestionSearchBar> createState() => _SuggestionSearchBarState();
}

class _SuggestionSearchBarState extends State<SuggestionSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    widget.onSearchChanged(query);

    setState(() {
      _filteredSuggestions = widget.suggestions
          .where((suggestion) => suggestion.toLowerCase().contains(query))
          .take(5)
          .toList();
    });

    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - (AppTheme.spacingM * 2),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: AppTheme.elevationM,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.search, size: 20),
                    title: Text(suggestion),
                    onTap: () {
                      _searchController.text = suggestion;
                      widget.onSearchChanged(suggestion);
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: languageProvider.translate('search_menu'),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              widget.onSearchChanged('');
            },
          )
              : null,
          filled: true,
          fillColor: AppTheme.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}