import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Theme.of(context).colorScheme.outlineVariant,
      barrierDismissible: false,
      barrierLabel: 'Dialog',
      transitionDuration: const Duration(milliseconds: 0),
      pageBuilder: (context, __, ___) {
        return const PopScope(canPop:false, child: Center(child: CircularProgressIndicator()));
      },
    );
  }

Future<void> showMyDialog(String title, String message, List<String> buttons,
    List<VoidCallback> actions, BuildContext context, {bool dismissable = false}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: dismissable, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: (title != "")?Text(title):null,
        content: (message != "") ? SingleChildScrollView(
          child: Text(message),
        ):null,
        actions: <Widget>[
          for (int i = 0; i < buttons.length; i++)
            TextButton(
              onPressed: actions[i],
              child: Text(buttons[i]),
            ),
        ],
      );
    },
  );
}
