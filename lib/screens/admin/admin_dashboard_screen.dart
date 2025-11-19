import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/auth_service.dart';
import '../../providers/menu_provider.dart';
import '../../providers/language_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    // final languageProvider = Provider.of<LanguageProvider>(context); // Opcjonalne, jeśli nie używamy do innych celów
    final isDesktop = AppTheme.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Panel Administratora', // PL
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // User Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white70),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    authService.currentUser?.email ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authService.signOut();
              if (mounted) {
                AppRoutes.navigateAndRemoveUntil(
                  context,
                  AppRoutes.menu,
                  predicate: (route) => false,
                );
              }
            },
            tooltip: 'Wyloguj', // PL
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppTheme.responsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Witaj Adminie!', // PL
              style: Theme.of(context).textTheme.headlineLarge,
            ),

            const SizedBox(height: AppTheme.spacingS),

            Text(
              'Zarządzaj menu restauracji i ustawieniami', // PL
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Statistics Cards
            _buildStatisticsSection(menuProvider),

            const SizedBox(height: AppTheme.spacingXL),

            // Quick Actions
            Text(
              'Szybkie akcje', // PL
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Action Grid
            _buildActionGrid(context, isDesktop),

            const SizedBox(height: AppTheme.spacingXL),

            // Recent Activity (placeholder)
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(MenuProvider menuProvider) {
    final stats = [
      {
        'title': 'Wszystkie pozycje', // PL
        'value': menuProvider.menuItems.length.toString(),
        'icon': Icons.restaurant_menu,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Kategorie', // PL
        'value': menuProvider.categories.length.toString(),
        'icon': Icons.category,
        'color': AppTheme.secondaryColor,
      },
      {
        'title': 'Aktywne powiadomienia', // PL
        'value': menuProvider.notifications.where((n) => n.isActive()).length.toString(),
        'icon': Icons.notifications_active,
        'color': AppTheme.warningColor,
      },
      {
        'title': 'Pory dnia', // PL
        'value': menuProvider.dayPeriods.length.toString(),
        'icon': Icons.schedule,
        'color': AppTheme.successColor,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppTheme.isDesktop(context) ? 4 : 2,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
        childAspectRatio: AppTheme.isDesktop(context) ? 1.5 : 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(
          title: stat['title'] as String,
          value: stat['value'] as String,
          icon: stat['icon'] as IconData,
          color: stat['color'] as Color,
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: AppTheme.elevationM,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, bool isDesktop) {
    final actions = [
      {
        'title': 'Zarządzaj Menu', // PL
        'subtitle': 'Dodaj, edytuj lub usuń dania', // PL
        'icon': Icons.restaurant_menu,
        'color': AppTheme.primaryColor,
        'route': AppRoutes.adminItems,
      },
      {
        'title': 'Zarządzaj Kategoriami', // PL
        'subtitle': 'Organizuj kategorie menu', // PL
        'icon': Icons.category,
        'color': AppTheme.secondaryColor,
        'route': AppRoutes.adminCategories,
      },
      {
        'title': 'Powiadomienia', // PL
        'subtitle': 'Twórz ogłoszenia', // PL
        'icon': Icons.campaign,
        'color': AppTheme.warningColor,
        'route': AppRoutes.adminNotifications,
      },
      {
        'title': 'Ustawienia', // PL
        'subtitle': 'Konfiguracja restauracji', // PL
        'icon': Icons.settings,
        'color': AppTheme.successColor,
        'route': AppRoutes.adminSettings,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
        childAspectRatio: isDesktop ? 1.2 : 1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(
          context: context,
          title: action['title'] as String,
          subtitle: action['subtitle'] as String,
          icon: action['icon'] as IconData,
          color: action['color'] as Color,
          route: action['route'] as String,
        );
      },
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: AppTheme.elevationS,
      child: InkWell(
        onTap: () {
          AppRoutes.navigateTo(context, route);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: color,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ostatnia aktywność', // PL
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {
                // Navigate to activity log
              },
              child: const Text('Zobacz wszystko'), // PL
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    _getActivityIcon(index),
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(_getActivityTitle(index)),
                subtitle: Text(_getActivityTime(index)),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textLight,
                ),
                onTap: () {
                  // Handle activity tap
                },
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(int index) {
    final icons = [
      Icons.add_circle_outline,
      Icons.edit,
      Icons.delete_outline,
      Icons.notifications,
      Icons.settings,
    ];
    return icons[index % icons.length];
  }

  String _getActivityTitle(int index) {
    final activities = [
      'Dodano pozycję', // PL
      'Zaktualizowano kategorię', // PL
      'Usunięto pozycję', // PL
      'Utworzono powiadomienie', // PL
      'Zmieniono ustawienia', // PL
    ];
    return activities[index % activities.length];
  }

  String _getActivityTime(int index) {
    final times = [
      '2 minuty temu', // PL
      '15 minut temu', // PL
      '1 godzinę temu', // PL
      '3 godziny temu', // PL
      'Wczoraj', // PL
    ];
    return times[index % times.length];
  }
}