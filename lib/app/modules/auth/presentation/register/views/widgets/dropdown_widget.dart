import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:ts_driver/app/core/widgets/dropdown_loading.dart';
import 'package:ts_driver/app/core/widgets/searchable_dropdown.dart';

class GenericDropdownWidget<T> extends StatelessWidget {
  final List<T> list;
  final String bottomSheetLabel;
  final String searchHint;
  final String fieldLabel;
  final String fieldHint;
  final bool isRequired;
  final bool showOnlyLetters;
  final String Function(T) getName;
  final String Function(T)? getImage;
  final T? selectedItem;
  final Function(T?) onItemSelected;
  final bool isLoading;
  final GlobalKey<DropdownSearchState>? dropdownKey;

  const GenericDropdownWidget({
    super.key,
    required this.list,
    required this.bottomSheetLabel,
    required this.searchHint,
    required this.fieldLabel,
    required this.fieldHint,
    required this.isRequired,
    required this.showOnlyLetters,
    required this.getName,
    this.getImage,
    this.selectedItem,
    required this.onItemSelected,
    this.isLoading = false,
    this.dropdownKey,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const DropdownLoadingWidget();

    return SearchableDropDown<T>(
      list: list,
      key: dropdownKey,
      bottomSheetLabel: bottomSheetLabel,
      searchHint: searchHint,
      fieldLabel: fieldLabel,
      fieldHint: fieldHint,
      isRequired: isRequired,
      showOnlyLetters: showOnlyLetters,
      getName: getName,
      getImage: getImage,
      selectedItem: selectedItem,
      dropdownSearchDecoration: SearchableDropdownDecoration.bordered,
      dropdownDecoration: SearchableDropdownDecoration.bordered,
      onItemSelected: onItemSelected,
      itemAsString: getName,
      compareFunction: (a, b) => a == b,
    );
  }
}
