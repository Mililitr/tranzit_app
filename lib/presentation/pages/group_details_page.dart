import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tranzit_app/domain/entities/group.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_bloc.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_event.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_state.dart';
import 'package:tranzit_app/presentation/widgets/error_message.dart';
import 'package:tranzit_app/presentation/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Страница с подробной информацией о группе
class GroupDetailsPage extends StatefulWidget {
  /// ID группы
  final String groupId;

  /// Создает экземпляр [GroupDetailsPage]
  const GroupDetailsPage({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  @override
  void initState() {
    super.initState();
    
    // Загружаем информацию о группе
    context.read<GroupsBloc>().add(SelectGroup(groupId: widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GroupsBloc, GroupsState>(
        builder: (context, state) {
          if (state is GroupsLoading) {
            return const LoadingIndicator(message: 'Загрузка информации о группе...');
          } else if (state is GroupsError) {
            return ErrorMessage(
              message: state.message,
              onRetry: () => context.read<GroupsBloc>().add(
                    SelectGroup(groupId: widget.groupId),
                  ),
            );
          } else if (state is GroupsLoaded && state.selectedGroup != null) {
            final group = state.selectedGroup!;
            return _buildGroupDetails(context, group);
          }
          
          return const LoadingIndicator();
        },
      ),
    );
  }

  /// Строит виджет с подробной информацией о группе
  Widget _buildGroupDetails(BuildContext context, Group group) {
    return CustomScrollView(
      slivers: [
        // AppBar с названием группы
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              group.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Фоновое изображение или градиент
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Затемнение для лучшей читаемости текста
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                // Иконка группы
                const Center(
                  child: Icon(
                    Icons.group,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Содержимое страницы
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Карточка с основной информацией
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок "О группе"
                        Row(
                          children: [
                            const Icon(Icons.info_outline),
                            const SizedBox(width: 8),
                            Text(
                              'О группе',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        // Описание группы
                        if (group.description != null && group.description!.isNotEmpty) ...[
                          Text(
                            group.description!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          const Text(
                            'Описание отсутствует',
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Количество участников
                        if (group.membersCount != null) ...[
                          _buildInfoRow(
                            context,
                            Icons.people,
                            'Участников',
                            '${group.membersCount}',
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        // Даты создания и обновления
                        if (group.createdAt != null) ...[
                          _buildInfoRow(
                            context,
                            Icons.calendar_today,
                            'Создана',
                            _formatDate(group.createdAt!),
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        if (group.updatedAt != null) ...[
                          _buildInfoRow(
                            context,
                            Icons.update,
                            'Обновлена',
                            _formatDate(group.updatedAt!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Карточка с дополнительной информацией
                if (group.additionalData.isNotEmpty) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Заголовок "Дополнительная информация"
                          Row(
                            children: [
                              const Icon(Icons.more_horiz),
                              const SizedBox(width: 8),
                              Text(
                                'Дополнительная информация',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          
                          // Список дополнительных данных
                          ...group.additionalData.entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildInfoRow(
                              context,
                              Icons.label_outline,
                              entry.key,
                              entry.value.toString(),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Кнопка перехода в Telegram
                if (group.telegramLink != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openTelegramLink(group.telegramLink!),
                      icon: const Icon(Icons.telegram),
                      label: const Text('Открыть в Telegram'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Строит строку с информацией
  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Форматирует дату
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Открывает ссылку на группу в Telegram
  Future<void> _openTelegramLink(String link) async {
    final uri = Uri.parse(link);
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
}