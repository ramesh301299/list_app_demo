// providers/api_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define the possible types
enum InfoType { Insurance, Speciality, ConsultationReason }
// Model for your list items
class ListItem {
    final int id;
    final String name;
    final String status;
    final DateTime date;

    ListItem({
        required this.id,
        required this.name,
        required this.status,
        required this.date,
    });

    factory ListItem.fromJson(Map<String, dynamic> json) => ListItem(
        id: json["ID"],
        name: json["NAME"],
        status: json["STATUS"],
        date: DateTime.parse(json["DATE"]),
    );
  }

// State class
class ListItemState {
  final InfoType? selectedType;
  final List<ListItem> data; 
  final List<ListItem> filteredData;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  ListItemState({
    this.selectedType,
    required this.filteredData,
    this.data = const [],
    this.isLoading = false,
    this.error,
     this.searchQuery = '',
  });

  // List<ListItem> get filteredData {
  //   if (searchQuery.isEmpty) return data;
  //   return data.where((item) => 
  //     item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
  //     item.id.toString().contains(searchQuery.toLowerCase())||
  //     item.status.toLowerCase().contains(searchQuery.toLowerCase())||
  //     item.date.toString().contains(searchQuery.toLowerCase())
  //   ).toList();
  // }
  ListItemState copyWith({
    InfoType? selectedType,
    List<ListItem>? data,
    List<ListItem>? filteredData,
    bool? isLoading,
    String? error,
     String? searchQuery,
  }) {
    return ListItemState(
      selectedType: selectedType ?? this.selectedType,
      filteredData: filteredData ?? this.filteredData,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}


final basicInfoProvider = StateNotifierProvider<BasicInfoNotifier, ListItemState>((ref) {
  return BasicInfoNotifier();
});

class BasicInfoNotifier extends StateNotifier<ListItemState> {
  BasicInfoNotifier() : super(ListItemState(data: [], filteredData: []));

  void clearAll() {
    state = ListItemState(data: [], filteredData: []);
  }
Future<void> setTypeAndFetch(InfoType type) async {
  state = state.copyWith(
    selectedType: type,
    isLoading: true,
    error: null,
    searchQuery: '',
  );

  try {
    final response = await http.get(
      Uri.parse('https://basic-info-api.dev1.docstime.com/basic-info-api/${type.name}/'),
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      List<ListItem> data = [];

      if (responseData is List) {
        data = responseData.map((item) => ListItem.fromJson(item)).toList();
      } 
      else if (responseData is Map) {
        // Check common response formats
        if (responseData.containsKey('data') && responseData['data'] is List) {
          data = (responseData['data'] as List).map((item) => ListItem.fromJson(item)).toList();
        } 
        else if (responseData.containsKey('items')) {
          data = (responseData['items'] as List).map((item) => ListItem.fromJson(item)).toList();
        }
        else {
          // Try to parse as single item
          try {
            // data = [ListItem.fromJson(responseData)];
          } catch (e) {
            throw FormatException('Unexpected API response format');
          }
        }
      }
      
      if (data.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No data available for selected type',
        );
      } else {
        state = state.copyWith(
          data: data,
          isLoading: false,
        );
      }
    } else {
      state = state.copyWith(
        error: 'Failed to load data: ${response.statusCode}',
        isLoading: false,
      );
    }
  } catch (e) {
    state = state.copyWith(
      error: 'Error: ${e.toString()}',
      isLoading: false,
    );
  }
}

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}