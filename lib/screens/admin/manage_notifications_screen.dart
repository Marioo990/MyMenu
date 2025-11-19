import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/notification.dart';
import '../../providers/menu_provider.dart';
import '../../providers/language_provider.dart';

class ManageNotificationsScreen extends StatefulWidget {
  const ManageNotificationsScreen({super.key});

  @override
  State<ManageNotificationsScreen> createState() => _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    // final languageProvider = Provider.of<LanguageProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zarządzaj powiadomieniami'), // PL
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showNotificationDialog(null),
              tooltip: 'Dodaj powiadomienie', // PL
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Aktywne'), // PL
              Tab(text: 'Zaplanowane'), // PL
              Tab(text: 'Wygasłe'), // PL
            ],
          ),
        ),
        body: menuProvider.isLoadingNotifications
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildNotificationsList(
              menuProvider.notifications.where((n) => n.isActive()).toList(),
              'Brak aktywnych powiadomień', // PL
            ),
            _buildNotificationsList(
              menuProvider.notifications.where((n) => n.isPending()).toList(),
              'Brak zaplanowanych powiadomień', // PL
            ),
            _buildNotificationsList(
              menuProvider.notifications.where((n) => n.isExpired()).toList(),
              'Brak wygasłych powiadomień', // PL
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<RestaurantNotification> notifications, String emptyMessage) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppTheme.responsivePadding(context),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(RestaurantNotification notification) {
    // Preferujemy polski tytuł i treść
    final title = notification.title['pl'] ?? notification.title['en'] ?? 'Bez tytułu';
    final message = notification.message['pl'] ?? notification.message['en'] ?? 'Brak treści';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (notification.isActive()) {
      statusColor = AppTheme.successColor;
      statusIcon = Icons.check_circle;
      statusText = 'Aktywne'; // PL
    } else if (notification.isPending()) {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.schedule;
      statusText = 'Zaplanowane'; // PL
    } else {
      statusColor = AppTheme.textLight;
      statusIcon = Icons.cancel;
      statusText = 'Wygasłe'; // PL
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Wrap(
              spacing: AppTheme.spacingS,
              children: [
                Chip(
                  label: Text(statusText),
                  backgroundColor: statusColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: statusColor, fontSize: 12),
                ),
                if (notification.pin)
                  Chip(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.push_pin, size: 14),
                        SizedBox(width: 4),
                        Text('Przypięte'), // PL
                      ],
                    ),
                    backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppTheme.secondaryColor, fontSize: 12),
                  ),
                Chip(
                  label: Text('Priorytet: ${notification.priority}'), // PL
                  backgroundColor: AppTheme.backgroundColor,
                  labelStyle: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range
                _buildDetailRow(
                  Icons.date_range,
                  '${_formatDate(notification.startAt)} - ${_formatDate(notification.endAt)}',
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Display Options
                _buildDetailRow(
                  Icons.visibility,
                  'Baner: ${notification.showAsBanner ? '✓' : '✗'} | Zakładka: ${notification.showInTab ? '✓' : '✗'}', // PL
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Push Options
                _buildDetailRow(
                  Icons.send,
                  'Web Push: ${notification.webPush ? '✓' : '✗'} | W aplikacji: ${notification.inApp ? '✓' : '✗'}', // PL
                ),

                if (notification.deepLink != null) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  _buildDetailRow(
                    Icons.link,
                    notification.deepLink!,
                  ),
                ],

                const SizedBox(height: AppTheme.spacingL),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showNotificationDialog(notification),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edytuj'), // PL
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(notification),
                      icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                      label: const Text(
                        'Usuń', // PL
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showNotificationDialog(RestaurantNotification? notification) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _NotificationFormDialog(
            notification: notification,
            onSave: (updatedNotification) async {
              final menuProvider = Provider.of<MenuProvider>(context, listen: false);
              try {
                if (notification == null) {
                  await menuProvider.createNotification(updatedNotification);
                } else {
                  await menuProvider.updateNotification(updatedNotification);
                }
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        notification == null
                            ? 'Powiadomienie utworzone' // PL
                            : 'Powiadomienie zaktualizowane', // PL
                      ),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Błąd: $e'), // PL
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(RestaurantNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potwierdź usunięcie'), // PL
        content: Text('Usunąć powiadomienie: ${notification.title['pl'] ?? notification.title['en']}?'), // PL
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'), // PL
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final menuProvider = Provider.of<MenuProvider>(context, listen: false);
              try {
                await menuProvider.deleteNotification(notification.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Powiadomienie usunięte'), // PL
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Błąd: $e'), // PL
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Usuń'), // PL
          ),
        ],
      ),
    );
  }
}

class _NotificationFormDialog extends StatefulWidget {
  final RestaurantNotification? notification;
  final Function(RestaurantNotification) onSave;
  final VoidCallback onCancel;

  const _NotificationFormDialog({
    required this.notification,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_NotificationFormDialog> createState() => _NotificationFormDialogState();
}

class _NotificationFormDialogState extends State<_NotificationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleEnController;
  late final TextEditingController _titlePlController;
  late final TextEditingController _messageEnController;
  late final TextEditingController _messagePlController;
  late DateTime _startAt;
  late DateTime _endAt;
  late int _priority;
  late bool _showAsBanner;
  late bool _showInTab;
  late bool _pin;

  @override
  void initState() {
    super.initState();
    final notification = widget.notification;

    _titleEnController = TextEditingController(text: notification?.title['en'] ?? '');
    _titlePlController = TextEditingController(text: notification?.title['pl'] ?? '');
    _messageEnController = TextEditingController(text: notification?.message['en'] ?? '');
    _messagePlController = TextEditingController(text: notification?.message['pl'] ?? '');

    _startAt = notification?.startAt ?? DateTime.now();
    _endAt = notification?.endAt ?? DateTime.now().add(const Duration(days: 7));
    _priority = notification?.priority ?? 0;
    _showAsBanner = notification?.showAsBanner ?? true;
    _showInTab = notification?.showInTab ?? true;
    _pin = notification?.pin ?? false;
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titlePlController.dispose();
    _messageEnController.dispose();
    _messagePlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.notification == null
              ? 'Dodaj powiadomienie' // PL
              : 'Edytuj powiadomienie', // PL
        ),
        actions: [
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Anuluj'), // PL
          ),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Zapisz'), // PL
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
              // Title fields
              TextFormField(
                controller: _titleEnController,
                decoration: const InputDecoration(
                  labelText: 'Tytuł (Angielski)', // PL
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Wymagane' : null,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _titlePlController,
                decoration: const InputDecoration(
                  labelText: 'Tytuł (Polski)', // PL
                  prefixIcon: Icon(Icons.title),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Message fields
              TextFormField(
                controller: _messageEnController,
                decoration: const InputDecoration(
                  labelText: 'Wiadomość (Angielski)', // PL
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Wymagane' : null,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _messagePlController,
                decoration: const InputDecoration(
                  labelText: 'Wiadomość (Polski)', // PL
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Priority
              TextFormField(
                initialValue: _priority.toString(),
                decoration: const InputDecoration(
                  labelText: 'Priorytet', // PL
                  prefixIcon: Icon(Icons.flag),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _priority = int.tryParse(value) ?? 0,
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Options
              SwitchListTile(
                title: const Text('Pokaż jako baner'), // PL
                value: _showAsBanner,
                onChanged: (value) => setState(() => _showAsBanner = value),
              ),
              SwitchListTile(
                title: const Text('Pokaż w zakładce'), // PL
                value: _showInTab,
                onChanged: (value) => setState(() => _showInTab = value),
              ),
              SwitchListTile(
                title: const Text('Przypnij powiadomienie'), // PL
                value: _pin,
                onChanged: (value) => setState(() => _pin = value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final notification = RestaurantNotification(
      id: widget.notification?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: {
        'en': _titleEnController.text,
        'pl': _titlePlController.text,
      },
      message: {
        'en': _messageEnController.text,
        'pl': _messagePlController.text,
      },
      startAt: _startAt,
      endAt: _endAt,
      priority: _priority,
      showAsBanner: _showAsBanner,
      showInTab: _showInTab,
      pin: _pin,
      webPush: true,
      inApp: true,
    );

    widget.onSave(notification);
  }
}