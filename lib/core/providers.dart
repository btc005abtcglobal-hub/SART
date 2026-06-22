import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/notifications/domain/notification_model.dart';
import '../features/search/domain/search_result_model.dart';
import '../features/search/data/search_service.dart';
import '../features/notifications/data/notification_service.dart';

// 1. Theme Mode Provider
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// 2. Navigation Index Provider
final navigationProvider = StateProvider<int>((ref) => 0);

// 3. Search State and Notifier
class SearchState {
  final String query;
  final List<String> history;
  final List<String> suggestions;
  final List<SearchResultModel> results;
  final bool isLoading;

  SearchState({
    this.query = '',
    this.history = const ['Rides to airport', 'Downtown parking', 'Nexon EV upgrades'],
    this.suggestions = const [],
    this.results = const [],
    this.isLoading = false,
  });

  SearchState copyWith({
    String? query,
    List<String>? history,
    List<String>? suggestions,
    List<SearchResultModel>? results,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      history: history ?? this.history,
      suggestions: suggestions ?? this.suggestions,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _searchService;

  SearchNotifier(this._searchService) : super(SearchState());

  void setQuery(String query) {
    if (query.isEmpty) {
      state = state.copyWith(query: query, suggestions: [], results: []);
      return;
    }

    state = state.copyWith(query: query, isLoading: true);
    
    // Simulate query suggestion matching
    final allSuggestions = _searchService.getSuggestions(query);
    
    state = state.copyWith(
      suggestions: allSuggestions,
      isLoading: false,
    );
  }

  void executeSearch(String query) {
    if (query.isEmpty) return;

    state = state.copyWith(isLoading: true, query: query);

    final results = _searchService.search(query);
    final updatedHistory = List<String>.from(state.history);
    if (!updatedHistory.contains(query)) {
      updatedHistory.insert(0, query);
      if (updatedHistory.length > 5) {
        updatedHistory.removeLast();
      }
    }

    state = state.copyWith(
      results: results,
      history: updatedHistory,
      isLoading: false,
    );
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }

  void deleteHistoryItem(String item) {
    final updatedHistory = List<String>.from(state.history)..remove(item);
    state = state.copyWith(history: updatedHistory);
  }
}

final searchServiceProvider = Provider<SearchService>((ref) => SearchService());

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final searchService = ref.watch(searchServiceProvider);
  return SearchNotifier(searchService);
});

// 4. Notification State and Notifier
class NotificationState {
  final List<NotificationModel> notifications;
  final String activeCategoryFilter;

  NotificationState({
    this.notifications = const [],
    this.activeCategoryFilter = 'All',
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    String? activeCategoryFilter,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      activeCategoryFilter: activeCategoryFilter ?? this.activeCategoryFilter,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;

  NotificationNotifier(this._notificationService) : super(NotificationState()) {
    // Load initial mock notifications
    loadNotifications();
  }

  void loadNotifications() {
    final list = _notificationService.getDummyNotifications();
    state = state.copyWith(notifications: list);
  }

  void markAsRead(String id) {
    final updatedList = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updatedList);
  }

  void markAllAsRead() {
    final updatedList = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updatedList);
  }

  void setFilter(String category) {
    state = state.copyWith(activeCategoryFilter: category);
  }

  void deleteNotification(String id) {
    final updatedList = state.notifications.where((n) => n.id != id).toList();
    state = state.copyWith(notifications: updatedList);
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationNotifier(service);
});
