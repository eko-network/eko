import 'package:flutter/material.dart';
import 'package:untitled_app/models/users.dart';
import 'package:untitled_app/widgets/profile_picture.dart';

class SelectedUser extends StatelessWidget {
  final AppUser user;
  final bool selected;
  final int index;
  final void Function(int) setter;
  const SelectedUser(
      {super.key,
      required this.user,
      required this.selected,
      required this.index,
      required this.setter});

  void onPressed() {
    setter(index);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onPressed(),
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                ProfilePicture(uid: user.uid, size: 22),
                const SizedBox(width: 5),
                Text((user.name != '') ? user.name : user.username)
              ],
            ),
          ),
        ));
  }
}
