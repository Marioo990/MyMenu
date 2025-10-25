import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/category.dart';

class CategoryCarousel extends StatefulWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;
  final String locale;

  const CategoryCarousel({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.locale,
  });

  @override
  State<CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<CategoryCarousel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDesktop = AppTheme.isDesktop(context);

    return Container(
      height: isDesktop ? 80 : 110,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = category.id == widget.selectedCategoryId;

          return Padding(
            padding: EdgeInsets.only(
              right: index < widget.categories.length - 1 ? AppTheme.spacingS : 0,
            ),
            child: _buildCategoryChip(
              category,
              isSelected,
              isDesktop,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(Category category, bool isSelected, bool isDesktop) {
    return AnimatedContainer(
      duration: AppTheme.animationFast,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Toggle selection - if already selected, deselect (show all)
            if (isSelected) {
              widget.onCategorySelected(null);
            } else {
              widget.onCategorySelected(category.id);
            }

            // Scroll to make selected category visible
            if (!isSelected) {
              _scrollToCategory(category);
            }
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? AppTheme.spacingL : AppTheme.spacingM,
              vertical: isDesktop ? AppTheme.spacingM : AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textLight.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Text(
                  category.getDisplayIcon(),
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 32,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXS),

                // Name
                Text(
                  category.getName(widget.locale),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Item count badge (optional)
                if (_shouldShowItemCount(category))
                  Padding(
                    padding: const EdgeInsets.only(top: AppTheme.spacingXS),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                      ),
                      child: Text(
                        _getItemCount(category).toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToCategory(Category category) {
    // Calculate position to scroll to
    final index = widget.categories.indexOf(category);
    if (index == -1) return;

    // Estimate item width (this is approximate)
    const itemWidth = 100.0;
    final targetPosition = index * itemWidth;

    // Scroll to position with animation
    _scrollController.animateTo(
      targetPosition,
      duration: AppTheme.animationNormal,
      curve: Curves.easeInOut,
    );
  }

  bool _shouldShowItemCount(Category category) {
    // Don't show count for special categories
    return category.id != SpecialCategories.all &&
        category.id != SpecialCategories.favorites;
  }

  int _getItemCount(Category category) {
    // This would be implemented with actual item count from provider
    // For now, return a placeholder
    return 0;
  }
}