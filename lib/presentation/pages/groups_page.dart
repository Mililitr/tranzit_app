import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tranzit_app/domain/entities/group.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_bloc.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_state.dart' as connection;
import 'package:tranzit_app/presentation/bloc/groups/groups_bloc.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_event.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_state.dart';
import 'package:tranzit_app/presentation/widgets/group_card.dart';
import 'package:tranzit_app/presentation/widgets/error_message.dart';
import 'package:tranzit_app/presentation/widgets/loading_indicator.dart';

/// Страница со списком групп
class GroupsPage extends StatefulWidget {
  /// Создает экземпляр [GroupsPage]
  const GroupsPage({Key? key}) : super(key: key);

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  /// Контроллер для поиска
  final TextEditingController _searchController = TextEditingController();
  
  /// Список отфильтрованных групп
  List<Group> _filteredGroups = [];
  
  /// Флаг, указывающий, что поиск активен
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Фильтрует группы по поисковому запросу
  void _filterGroups(List<Group> groups, String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredGroups = groups;
        _isSearching = false;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredGroups = groups.where((group) {
        final name = group.name.toLowerCase();
        final description = group.description?.toLowerCase() ?? '';
        return name.contains(lowercaseQuery) || description.contains(lowercaseQuery);
      }).toList();
      _isSearching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Группы Tranzit'),
        actions: [
          // Кнопка поиска
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _GroupSearchDelegate(
                  groups: _getGroupsFromState(context),
                  onGroupSelected: (group) => _navigateToGroupDetails(context, group),
                ),
              );
            },
          ),
          // Кнопка настроек
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
        elevation: 0,
      ),
      body: BlocBuilder<GroupsBloc, GroupsState>(
        builder: (context, state) {
          if (state is GroupsInitial) {
            // Загружаем группы при первом открытии
            context.read<GroupsBloc>().add(const LoadGroups());
            return const LoadingIndicator();
          } else if (state is GroupsLoading) {
            return const LoadingIndicator();
          } else if (state is GroupsError) {
            return ErrorMessage(
              message: state.message,
              onRetry: () => context.read<GroupsBloc>().add(const LoadGroups()),
            );
          } else if (state is GroupsLoaded) {
            final groups = state.groups;
            
            if (groups.isEmpty) {
              return _buildEmptyState();
            }
            
            // Если это первая загрузка или сброс поиска, обновляем отфильтрованный список
            if (_filteredGroups.isEmpty && !_isSearching) {
              _filteredGroups = groups;
            }
            
            return _buildGroupsList(context, groups);
          }
          
          return const LoadingIndicator();
        },
      ),
      // Кнопка обновления данных
      floatingActionButton: BlocBuilder<ConnectionBloc, connection.ConnectionState>(
        builder: (context, state) {
          final hasInternet = state is connection.ConnectionInfo && state.status.hasInternet;
          
          return FloatingActionButton(
            onPressed: hasInternet
                ? () => context.read<GroupsBloc>().add(const RefreshGroups())
                : () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Нет подключения к интернету. Невозможно обновить данные.'),
                        duration: Duration(seconds: 2),
                      ),
                    ),
            tooltip: hasInternet ? 'Обновить данные' : 'Нет подключения',
            backgroundColor: hasInternet ? Theme.of(context).primaryColor : Colors.grey,
            child: const Icon(Icons.refresh),
          );
        },
      ),
    );
  }
  /// Строит виджет для пустого списка групп
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.group_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Список групп пуст',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Нет доступных групп для отображения',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<GroupsBloc>().add(const RefreshGroups()),
            icon: const Icon(Icons.refresh),
            label: const Text('Обновить'),
          ),
        ],
      ),
    );
  }

  /// Строит список групп
  Widget _buildGroupsList(BuildContext context, List<Group> groups) {
    final displayGroups = _isSearching ? _filteredGroups : groups;
    
    return Column(
      children: [
        // Поле поиска
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск групп...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterGroups(groups, '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            onChanged: (value) => _filterGroups(groups, value),
          ),
        ),
        
        // Информация о количестве групп
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Всего групп: ${groups.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_isSearching)
                Text(
                  'Найдено: ${_filteredGroups.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Список групп
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<GroupsBloc>().add(const RefreshGroups());
              return Future.delayed(const Duration(seconds: 1));
            },
            child: displayGroups.isEmpty && _isSearching
                ? _buildNoSearchResults()
                : ListView.builder(
                    itemCount: displayGroups.length,
                    padding: const EdgeInsets.only(bottom: 80), // Отступ для FAB
                    itemBuilder: (context, index) {
                      final group = displayGroups[index];
                      return GroupCard(
                        group: group,
                        onTap: () => _navigateToGroupDetails(context, group),
                      );
                    },
                  ),
          ),
        ),
        // Информация о количестве групп и источнике данных
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Всего групп: ${groups.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_isSearching)
                Text(
                  'Найдено: ${_filteredGroups.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else if (context.read<GroupsBloc>().state is GroupsLoaded && 
                      (context.read<GroupsBloc>().state as GroupsLoaded).fromCache)
                Row(
                  children: [
                    const Icon(
                      Icons.storage,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Из кэша',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Строит виджет для отсутствия результатов поиска
  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Ничего не найдено',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'По запросу "${_searchController.text}" ничего не найдено',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _filterGroups(_getGroupsFromState(context), '');
            },
            icon: const Icon(Icons.clear),
            label: const Text('Сбросить поиск'),
          ),
        ],
      ),
    );
  }

  /// Получает список групп из текущего состояния
  List<Group> _getGroupsFromState(BuildContext context) {
    final state = context.read<GroupsBloc>().state;
    if (state is GroupsLoaded) {
      return state.groups;
    }
    return [];
  }

  /// Переход на страницу с подробной информацией о группе
  void _navigateToGroupDetails(BuildContext context, Group group) {
    context.go('/groups/${group.id}');
  }
}

/// Делегат для поиска групп
class _GroupSearchDelegate extends SearchDelegate<Group?> {
  final List<Group> groups;
  final Function(Group) onGroupSelected;

  _GroupSearchDelegate({
    required this.groups,
    required this.onGroupSelected,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Введите запрос для поиска'),
      );
    }

    final lowercaseQuery = query.toLowerCase();
    final results = groups.where((group) {
      final name = group.name.toLowerCase();
      final description = group.description?.toLowerCase() ?? '';
      return name.contains(lowercaseQuery) || description.contains(lowercaseQuery);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ничего не найдено',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'По запросу "$query" ничего не найдено',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final group = results[index];
        return ListTile(
          title: Text(group.name),
          subtitle: group.description != null ? Text(group.description!) : null,
          leading: const Icon(Icons.group),
          onTap: () {
            onGroupSelected(group);
            close(context, group);
          },
        );
      },
    );
  }
}