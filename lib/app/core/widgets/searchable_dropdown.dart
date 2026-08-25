import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';

// ignore: must_be_immutable
class SearchableDropDown<T> extends StatelessWidget {
  final List<T> list;
  final String bottomSheetLabel;
  final String searchHint;
  final String fieldLabel;
  final String fieldHint;
  final bool isRequired;
  final bool showOnlyLetters;
  final dynamic prefixIcon;
  final Function(T?) onItemSelected;
  final String Function(T)? itemAsString;
  final bool Function(T, T)? compareFunction;
  final bool Function(T, String)? filterFunction;
  final Future<List<T>> Function(String)? asyncItems;
  final SearchableDropdownDecoration dropdownDecoration;
  final SearchableDropdownDecoration dropdownSearchDecoration;
  final Widget Function(BuildContext context, T item, bool isSelected)?
      itemBuilder;
  final String Function(T) getName;
  final String Function(T)? getImage;
  final String Function(T)? getSubTitle;
  final bool isEnable;
  T? selectedItem;
  SearchableDropDown({
    super.key,
    required this.list,
    required this.bottomSheetLabel,
    required this.searchHint,
    required this.fieldLabel,
    required this.fieldHint,
    required this.isRequired,
    this.showOnlyLetters = false,
    this.prefixIcon,
    required this.onItemSelected,
    required this.dropdownDecoration,
    required this.dropdownSearchDecoration,
    required this.getName,
    this.getImage,
    this.getSubTitle,
    this.itemAsString,
    this.selectedItem,
    this.compareFunction,
    this.filterFunction,
    this.asyncItems,
    this.itemBuilder,
    this.isEnable = true,
  });

  @override
  Widget build(BuildContext context) {
    //
    //
    // theme
    final ThemeData theme = Theme.of(context);

    //
    //
    return IgnorePointer(
      ignoring: !isEnable,
      child: Opacity(
        opacity: isEnable ? 1 : 0.5,
        child: DropdownSearch<T>(
          popupProps: PopupProps.modalBottomSheet(
            showSelectedItems: true,
            showSearchBox: true,
            searchDelay: Duration.zero,
            modalBottomSheetProps: ModalBottomSheetProps(
              backgroundColor:
                  Get.isDarkMode ? AppColorsDark.mainColorDark : Colors.white,
            ),
            containerBuilder: (context, popupWidget) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //
                    // bottom sheet header
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColorsLight.mainColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            bottomSheetLabel,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ],
                      ).marginSymmetric(horizontal: 14, vertical: 10),
                    ),

                    //
                    // body
                    Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: popupWidget,
                    ),
                  ],
                ),
              );
            },
            itemBuilder: (context, item, isDisabled, isSelected) {
              return itemBuilderWidget(
                context,
                item,
                isSelected,
                getName,
                getImage,
                getSubTitle,
              );
            },
            constraints: const BoxConstraints(),
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                counterText: "",
                hintText: searchHint,
                focusedBorder: _getBorderStyle(dropdownSearchDecoration, true),
                border: _getBorderStyle(dropdownSearchDecoration, false),
              ),
            ),
          ),
          // items: list,
          items: (filter, infiniteScrollProps) => list,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              counterText: "",
              hintText: fieldHint,
              label: RichText(
                text: TextSpan(
                  text: fieldLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                  children: [
                    if (isRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
              ),
              focusedBorder: _getBorderStyle(dropdownDecoration, true),
              border: _getBorderStyle(dropdownDecoration, false),
            ),
          ),
          onChanged: onItemSelected,
          selectedItem: selectedItem,
          itemAsString: itemAsString,
          compareFn: compareFunction,
          filterFn: filterFunction,
        ),
      ),
    );
  }

  Widget itemBuilderWidget(
    BuildContext context,
    T item,
    bool isSelected,
    String Function(T)? getName,
    String Function(T)? getImage,
    String Function(T)? getSubTitle,
  ) {
    return Column(
      children: [
        //
        //
        // user details
        Row(
          children: [
            const SizedBox(width: 16),
            if (showOnlyLetters && getName != null)
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColorsLight.mainColor.applyOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    getName(item).isNotEmpty ? getName(item)[0] : '',
                    style: Get.theme.textTheme.titleLarge?.copyWith(
                      color: AppColorsLight.mainColor,
                    ),
                  ),
                ),
              ),
            // user image
            if (getImage != null && getName != null && showOnlyLetters == false)
              ProfileImage.network(
                url: getImage(item),
                width: 40,
                height: 40,
                showLetterOnError: true,
                letter: getName(item).isNotEmpty ? getName(item)[0] : '',
              ).marginOnly(right: 8),

            //
            // user name adn desigination
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //
                  // user name
                  if (getName != null)
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        getName(item),
                        style: Get.textTheme.titleSmall?.copyWith(
                          color: isSelected
                              ? AppColorsLight.mainColor
                              : Get.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  //
                  // user desigination
                  if (getSubTitle != null)
                    Text(
                      getSubTitle(item),
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppColorsLight.mainColor
                            : Get.isDarkMode
                                ? Colors.white
                                : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                ],
              ),
            ),

            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColorsLight.mainColor,
                size: 25,
              ).marginOnly(left: 16),

            const SizedBox(
              width: 16,
            ),
          ],
        ),

        //
        //
        // divider
        Divider(
          color: Get.isDarkMode ? Colors.white24 : Colors.grey.shade300,
          thickness: 0.5,
          indent: getImage == null ? 10 : 65,
          height: 16,
        ),
      ],
    );
  }

  InputBorder _getBorderStyle(
      SearchableDropdownDecoration searchableDropdownDecoration,
      bool isFocused) {
    switch (searchableDropdownDecoration) {
      case SearchableDropdownDecoration.bordered:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: isFocused
              ? const BorderSide(
                  color: AppColorsLight.mainColor,
                )
              : const BorderSide(),
        );

      case SearchableDropdownDecoration.line:
        return UnderlineInputBorder(
          borderSide: isFocused
              ? const BorderSide(
                  color: AppColorsLight.mainColor,
                )
              : const BorderSide(),
        );

      case SearchableDropdownDecoration.none:
        return InputBorder.none;
    }
  }
}

enum SearchableDropdownDecoration { bordered, line, none }
