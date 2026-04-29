class FilterManager {
  String? selectedSpecialty;
  String? selectedDegree;
  String? selectedAddress;
// Default constructor
  FilterManager();
  // A generic filter function to apply across any list of data.
  List<Map<String, dynamic>> filterData(
    List<Map<String, dynamic>> dataList,
    String searchQuery, {
    String? specialtyField = 'specialty',
    String? degreeField = 'degree',
    String? addressField = 'address',
    String? nameField = 'name',
  }) {
    return dataList.where((data) {
      // Check if the search query matches any field (name, specialty, degree, address)
      bool matchesSearch =
          data[nameField]?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false ||
                  data[specialtyField]
                      ?.toLowerCase()
                      .contains(searchQuery.toLowerCase()) ??
              false ||
                  data[addressField]
                      ?.toLowerCase()
                      .contains(searchQuery.toLowerCase()) ??
              false;

      // Check if the selected specialty, degree, and address match the filter
      bool matchesSpecialty = selectedSpecialty == null ||
          data[specialtyField] == selectedSpecialty;
      bool matchesDegree =
          selectedDegree == null || data[degreeField] == selectedDegree;
      bool matchesAddress =
          selectedAddress == null || data[addressField] == selectedAddress;

      // Return true if all filters and search match
      return matchesSearch &&
          matchesSpecialty &&
          matchesDegree &&
          matchesAddress;
    }).toList();
  }

  // Sort the data based on a specific field
  void sortData(
    List<Map<String, dynamic>> dataList,
    String criterion, {
    String? nameField = 'name',
    String? specialtyField = 'specialty',
    String? degreeField = 'degree',
    String? addressField = 'address',
  }) {
    switch (criterion) {
      case 'name_asc':
        dataList.sort((a, b) => a[nameField]?.compareTo(b[nameField]) ?? 0);
        break;
      case 'name_desc':
        dataList.sort((a, b) => b[nameField]?.compareTo(a[nameField]) ?? 0);
        break;
      case 'specialty':
        dataList.sort(
            (a, b) => a[specialtyField]?.compareTo(b[specialtyField]) ?? 0);
        break;
      case 'degree':
        dataList.sort((a, b) => a[degreeField]?.compareTo(b[degreeField]) ?? 0);
        break;
      case 'address':
        dataList
            .sort((a, b) => a[addressField]?.compareTo(b[addressField]) ?? 0);
        break;
    }
  }
}
