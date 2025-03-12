import 'package:flutter/material.dart';
import 'package:tranzit_app/domain/entities/group.dart';

/// Виджет карточки группы
class GroupCard extends StatelessWidget {
  /// Группа для отображения
  final Group group;
  
  /// Callback при нажатии на карточку
  final VoidCallback onTap;

  /// Создает экземпляр [GroupCard]
  const GroupCard({
    Key? key,
    required this.group,
    required this.onTap,
  }) : super(key: key);

  @override
@override
Widget build(BuildContext context) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название группы
            Text(
              group.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Описание группы
            if (group.description != null && group.description!.isNotEmpty) ...[
              Text(
                group.description!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            
            // Нижняя часть карточки с дополнительной информацией
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
}  /// Форматирует дату

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}