import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/auth_service.dart';
import '../../providers/menu_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/language_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    final isDesktop = AppTheme.isDesktop(context);
    final isTablet = AppTheme.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('dashboard')),
        actions: [
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await menuProvider.refreshAll();
              await settingsProvider.reloadSettings();
            },
            tooltip: 'Refresh data',
          ),

          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.adminSettings);
            },
            tooltip: languageProvider.translate('settings'),
          ),

          // User Menu
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                // Navigate to profile
                  break;
                case 'logout':
                  await authService.signOut();
                  if (mounted) {
                    AppRoutes.navigateAndRemoveUntil(
                      context,
                      AppRoutes.adminLogin,
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(authService.currentUser?.email ?? 'Admin'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(languageProvider.translate('logout')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Row(
        children: [
          // Side Navigation (Desktop/Tablet)
          if (isDesktop || isTablet)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              extended: isDesktop,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.dashboard),
                  label: Text(languageProvider.translate('overview')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.restaurant_menu),
                  label: Text(languageProvider.translate('menu_items')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.category),
                  label: Text(languageProvider.translate('categories')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.notifications),
                  label: Text(languageProvider.translate('notifications')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.analytics),
                  label: Text(languageProvider.translate('analytics')),
                ),
              ],
            ),

          // Main Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),

      // Bottom Navigation (Mobile)
      bottomNavigationBar: !isDesktop && !isTablet
          ? BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: languageProvider.translate('overview'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_menu),
            label: languageProvider.translate('menu'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.category),
            label: languageProvider.translate('categories'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: languageProvider.translate('alerts'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: languageProvider.translate('stats'),
          ),
        ],
      )
          : null,
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildMenuItemsTab();
      case 2:
        return _buildCategoriesTab();
      case 3:
        return _buildNotificationsTab();
      case 4:
        return _buildAnalyticsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    final menuProvider = Provider.of<MenuProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SingleChildScrollView(
      padding: AppTheme.responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.displaySmall,
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Stats Cards
          Wrap(
            spacing: AppTheme.spacingL,
            runSpacing: AppTheme.spacingL,
            children: [
              _buildStatCard(
                'Total Items',
                menuProvider.menuItems.length.toString(),
                Icons.restaurant_menu,
                AppTheme.primaryColor,
              ),
              _buildStatCard(
                'Categories',
                menuProvider.categories.length.toString(),
                Icons.category,
                AppTheme.secondaryColor,
              ),
              _buildStatCard(
                'Active Notifications',
                menuProvider.notifications
                    .where((n) => n.isActive())
                    .length
                    .toString(),
                Icons.notifications_active,
                AppTheme.warningColor,
              ),
              _buildStatCard(
                'Languages',
                settingsProvider.activeLanguages.length.toString(),
                Icons.language,
                AppTheme.successColor,
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: AppTheme.spacingL),

          Wrap(
            spacing: AppTheme.spacingM,
            runSpacing: AppTheme.spacingM,
            children: [
              _buildQuickAction(
                'Add Item',
                Icons.add_circle,
                    () => AppRoutes.navigateTo(context, AppRoutes.adminItems),
              ),
              _buildQuickAction(
                'Add Category',
                Icons.create_new_folder,
                    () => AppRoutes.navigateTo(context, AppRoutes.adminCategories),
              ),
              _buildQuickAction(
                'Create Notification',
                Icons.campaign,
                    () => AppRoutes.navigateTo(context, AppRoutes.adminNotifications),
              ),
              _buildQuickAction(
                'Export Data',
                Icons.download,
                _handleExportData,
              ),
              _buildQuickAction(
                'Import Data',
                Icons.upload,
                _handleImportData,
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: AppTheme.spacingL),

          _buildRecentActivityList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: AppTheme.elevationS,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Card(
      elevation: AppTheme.elevationS,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.edit,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            title: Text('Item updated: Pizza Margherita'),
            subtitle: Text('2 hours ago'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppTheme.textLight,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItemsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.restaurant_menu,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Menu Items Management',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton.icon(
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.adminItems);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Manage Items'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.category,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Categories Management',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton.icon(
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.adminCategories);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Manage Categories'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Notifications Management',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton.icon(
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.adminNotifications);
            },
            icon: const Icon(Icons.campaign),
            label: const Text('Manage Notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.analytics,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Analytics & Reports',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.spacingL),
          const Text(
            'View detailed analytics about menu performance',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _handleExportData() {
    // Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data...')),
    );
  }

  void _handleImportData() {
    // Implement data import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality coming soon')),
    );
  }
}