import 'package:flutter/material.dart';
import 'package:untitled_app/controllers/feed_controller.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

import 'package:provider/provider.dart' as prov;
import '../utilities/constants.dart' as c;

// TODO: I changed it to this does it look fine
class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return SizedBox(
      width: width,
      //height: 50, // Adjust the height as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Button(text: AppLocalizations.of(context)!.followingTab, index: 0),
          _Button(text: AppLocalizations.of(context)!.newTab, index: 1),
          _Button(text: AppLocalizations.of(context)!.popularTab, index: 2),

          //_Button(text: AppLocalizations.of(context)!.oldTab, index: 3),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String text;
  final int index;

  const _Button({required this.text, required this.index});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final isActive =
        prov.Provider.of<FeedController>(context, listen: true).index == index;

    return InkWell(
      onTap: () => prov.Provider.of<FeedController>(context, listen: false)
          .onTabPressed(index),
      child: SizedBox(
          width: width * 0.3,
          child: Center(
              child: Container(
            width: width * 0.24,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              // color: isActive
              //     ? Theme.of(context).colorScheme.secondary
              //     : Colors.transparent,
              // borderRadius: BorderRadius.circular(10),
              border: isActive
                  ? Border(
                      bottom: BorderSide(
                          width: 2.0,
                          color: Theme.of(context).colorScheme.secondary))
                  : Border(),
            ),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ))),
    );
  }
}
