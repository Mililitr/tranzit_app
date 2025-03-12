import 'package:flutter/material.dart';

/// Виджет индикатора загрузки
class LoadingIndicator extends StatelessWidget {
  /// Сообщение для отображения
  final String message;

  /// Создает экземпляр [LoadingIndicator]
  const LoadingIndicator({
    Key? key,
    this.message = 'Загрузка...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}