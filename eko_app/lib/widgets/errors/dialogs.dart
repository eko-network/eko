import 'package:flutter/material.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Theme.of(context).colorScheme.surface,
    builder: (context) =>
        const PopScope(canPop: false, child: Center(child: LoadingSpinner())),
  );
}

Future<void> showMyDialog(
  String title,
  String message,
  List<String> buttons,
  List<VoidCallback> actions,
  BuildContext context, {
  bool dismissable = false,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: dismissable, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.outlineVariant,
        title: (title != '') ? Text(title) : null,
        content: (message != '')
            ? SingleChildScrollView(child: Text(message))
            : null,
        actions: <Widget>[
          for (int i = 0; i < buttons.length; i++)
            TextButton(onPressed: actions[i], child: Text(buttons[i])),
        ],
      );
    },
  );
}
