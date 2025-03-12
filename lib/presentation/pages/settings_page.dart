import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tranzit_app/domain/entities/settings.dart';
import 'package:tranzit_app/injection_container.dart' as di;
import 'package:tranzit_app/data/datasources/local/group_local_data_source.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_bloc.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_event.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_bloc.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_event.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_state.dart';
import 'package:tranzit_app/presentation/widgets/error_message.dart';
import 'package:tranzit_app/presentation/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Страница настроек приложения
class SettingsPage extends StatefulWidget {
  /// Создает экземпляр [SettingsPage]
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// Информация о приложении
  PackageInfo? _packageInfo;
  
  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }
  
  /// Загружает информацию о приложении
  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = packageInfo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        elevation: 0,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const LoadingIndicator(message: 'Загрузка настроек...');
          } else if (state is SettingsError) {
            return ErrorMessage(
              message: state.message,
              onRetry: () => context.read<SettingsBloc>().add(const LoadSettings()),
            );
          } else if (state is SettingsLoaded) {
            final settings = state.settings;
            return _buildSettingsList(context, settings);
          }
          
          return const LoadingIndicator();
        },
      ),
    );
  }

  /// Строит список настроек
  Widget _buildSettingsList(BuildContext context, Settings settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Секция "Внешний вид"
        _buildSectionHeader(context, 'Внешний вид'),
        
        // Переключатель темы
        _buildSettingCard(
          context,
          title: 'Темная тема',
          subtitle: 'Изменить внешний вид приложения',
          leading: Icon(
            settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).primaryColor,
          ),
          trailing: Switch(
            value: settings.isDarkMode,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (_) {
              context.read<SettingsBloc>().add(const ToggleTheme());
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Секция "Данные"
        _buildSectionHeader(context, 'Данные'),
        
        // Информация о последней синхронизации
        _buildSettingCard(
          context,
          title: 'Последняя синхронизация',
          subtitle: settings.lastSyncTime != null
              ? _formatDate(settings.lastSyncTime!)
              : 'Нет данных о синхронизации',
          leading: Icon(
            Icons.sync,
            color: Theme.of(context).primaryColor,
          ),
        ),
        
        // Кнопка очистки кэша
        _buildSettingCard(
          context,
          title: 'Очистить кэш',
          subtitle: 'Удалить все локально сохраненные данные',
          leading: Icon(
            Icons.cleaning_services,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () => _showClearCacheDialog(context),
        ),
        
        const SizedBox(height: 24),
        
        // Секция "О приложении"
        _buildSectionHeader(context, 'О приложении'),
        
        // Версия приложения
        _buildSettingCard(
          context,
          title: 'Версия приложения',
          subtitle: _packageInfo != null
              ? '${_packageInfo!.version} (${_packageInfo!.buildNumber})'
              : 'Загрузка...',
          leading: Icon(
            Icons.info_outline,
            color: Theme.of(context).primaryColor,
          ),
        ),
        
        // Исходный код на GitHub
        _buildSettingCard(
          context,
          title: 'Исходный код',
          subtitle: 'Открыть репозиторий на GitHub',
          leading: Icon(
            Icons.code,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () => _openUrl('https://github.com/Mililitr/tranzit_app'),
        ),
        
        // Политика конфиденциальности
        _buildSettingCard(
          context,
          title: 'Политика конфиденциальности',
          subtitle: 'Информация о сборе и использовании данных',
          leading: Icon(
            Icons.privacy_tip_outlined,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () => _showPrivacyPolicyDialog(context),
        ),
        
        const SizedBox(height: 24),
        
        // Кнопка "О разработчике"
        Center(
          child: TextButton(
            onPressed: () => _showAboutDialog(context),
            child: const Text('О разработчике'),
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  /// Строит заголовок секции
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Строит карточку настройки
  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: leading),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Показывает диалог очистки кэша
  Future<void> _showClearCacheDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Очистить кэш?'),
          content: const Text(
            'Все локально сохраненные данные будут удалены. '
            'Вам потребуется подключение к интернету для загрузки данных снова.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                // Получаем экземпляр GroupLocalDataSource
                final localDataSource = di.sl<GroupLocalDataSource>();
                
                // Очищаем кэш
                await localDataSource.clearCache();
                
                // Закрываем диалог
                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  // Показываем уведомление
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Кэш очищен'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  
                  // Обновляем список групп
                  context.read<GroupsBloc>().add(const LoadGroups());
                }
              },
              child: const Text('Очистить'),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог с политикой конфиденциальности
  Future<void> _showPrivacyPolicyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Политика конфиденциальности'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Приложение Tranzit App не собирает персональные данные пользователей. '
                  'Все данные о группах хранятся локально на устройстве пользователя.',
                ),
                SizedBox(height: 16),
                Text(
                  'Приложение использует интернет-соединение только для получения '
                  'информации о группах с сервера.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог о разработчике
  Future<void> _showAboutDialog(BuildContext context) async {
    return showAboutDialog(
      context: context,
      applicationName: 'Tranzit App',
      applicationVersion: _packageInfo?.version ?? '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      applicationLegalese: '© 2023 Your Name',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Приложение для просмотра групп Tranzit с возможностью '
          'сохранения данных для офлайн-доступа.',
        ),
      ],
    );
  }

  /// Открывает URL
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть ссылку'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Форматирует дату
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}