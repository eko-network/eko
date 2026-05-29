import 'dart:async';

import 'package:flutter/material.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class _UserNameCheckLoading extends StatelessWidget {
  const _UserNameCheckLoading();

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: width * 0.05,
          height: width * 0.05,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

void showUserNameReqs(BuildContext context, {FocusNode? focus}) {
  showSnackBar(
    text: AppLocalizations.of(context)!.usernameReqs,
    context: context,
  );
  focus?.requestFocus();
}

class UsernameCheckDisplay extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focus;
  final void Function(bool)? onValidate;
  //useful for not showing when username is current user;
  final String skipVal;
  const UsernameCheckDisplay({
    super.key,
    required this.controller,
    this.skipVal = '',
    this.focus,
    this.onValidate,
  });

  @override
  State<UsernameCheckDisplay> createState() => _UsernameCheckDisplayState();
}

class _UsernameCheckDisplayState extends State<UsernameCheckDisplay> {
  Future<bool>? isUsernameAvailableAsync;
  Timer? _debounce;
  void usernameListener() {
    final username = widget.controller.text.trim();
    if (!isUsernameValid(username)) return;
    if (isUsernameAvailableAsync != null) {
      setState(() {
        isUsernameAvailableAsync = null;
      });
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(
      const Duration(milliseconds: c.searchPageDebounce),
      () async {
        setState(() {
          isUsernameAvailableAsync = isUsernameAvailable(username);
        });
      },
    );
  }

  @override
  void initState() {
    widget.controller.addListener(usernameListener);
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(usernameListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (BuildContext context, TextEditingValue value, _) {
        final potentialUsername = value.text.trim();
        if (widget.skipVal == potentialUsername || potentialUsername.isEmpty) {
          return SizedBox.shrink();
        }
        if (!isUsernameValid(value.text.trim())) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.invalidUserName,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              IconButton(
                onPressed: () {
                  showUserNameReqs(context, focus: widget.focus);
                },
                icon: const Icon(Icons.help_outline_outlined),
              ),
            ],
          );
        }
        if (isUsernameAvailableAsync == null) {
          return _UserNameCheckLoading();
        }
        return FutureBuilder(
          future: isUsernameAvailableAsync,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              if (widget.onValidate != null) widget.onValidate!(snapshot.data!);
              if (snapshot.data!) {
                return Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    AppLocalizations.of(context)!.available,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    AppLocalizations.of(context)!.usernameInUse,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }
            return _UserNameCheckLoading();
          },
        );
      },
    );
  }
}
