import 'package:flutter/material.dart';
import 'package:tranzit_app/domain/entities/group.dart';

/// Виджет элемента списка групп
class GroupListItem extends StatelessWidget {
  /// Группа для отображения
  final Group group;
  
  /// Callback при нажатии на элемент
  final VoidCallback onTap;

  /// Создает экземпляр [GroupListItem]
  const GroupListItem({
    Key? key,
    required this.group,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название группы
              Text(
                group.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              if (group.description != null && group.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                // Описание группы (ограниченное)
                Text(
                  _truncateText(group.description!, 100),
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Нижняя часть с дополнительной информацией
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Количество участников
                  if (group.membersCount != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group.membersCount}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  
                  // Дата обновления
                  if (group.updatedAt != null)
                    Text(
                      _formatDate(group.updatedAt!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
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

  /// Обрезает текст до указанной длины
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  /// Форматирует дату
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}