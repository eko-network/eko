import 'package:flutter/material.dart';
import 'package:untitled_app/custom_widgets/controllers/pagination_controller.dart'
    show PaginationGetterReturn;
import '../models/search_model.dart';
import 'dart:async';
import '../utilities/constants.dart' as c;

class SearchPageController extends ChangeNotifier {
  final searchTextController = TextEditingController();
  final BuildContext context;
  SearchPageController({required this.context});
  bool isLoading = false;
  String query = '';
  Timer? _debounce;
  final searchModel = SearchModel();

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<PaginationGetterReturn> getter(dynamic page) async {
    if (isLoading) {
      //forces loading animation
      return PaginationGetterReturn(end: false, payload: []);
    } else {
      page = page ?? 0;
      return searchModel.getter(page, query, true);
    }
  }

  dynamic startAfterQuery(dynamic lastUser) {
    return searchModel.startAfterQuery(lastUser);
  }

  void onSearchTextChanged(String s) async {
    isLoading = true;
    notifyListeners();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(
      const Duration(milliseconds: c.searchPageDebounce),
      () async {
        query = s;
        isLoading = false;
        notifyListeners();
      },
    );
  }
}
