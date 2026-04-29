// filter_manager.dart

class FilterManager {
  Map<String, dynamic> filters;

  FilterManager(this.filters);

  void updateFilter(String key, bool? value) {
    filters[key] = value;
  }
}
