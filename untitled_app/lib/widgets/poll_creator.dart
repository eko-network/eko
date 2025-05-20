import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

class PollCreator extends StatefulWidget {
  final double height;
  final double width;
  final List<String> pollOptions;
  const PollCreator(
      {required this.width,
      required this.height,
      required this.pollOptions,
      super.key});

  @override
  State<PollCreator> createState() => _PollCreatorState();
}

class _PollCreatorState extends State<PollCreator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            widget.pollOptions.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: widget.pollOptions[index],
                      decoration: InputDecoration(
                        hintText:
                            '${AppLocalizations.of(context)!.option} ${index + 1}',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        errorText: widget.pollOptions[index].length > 50
                            ? AppLocalizations.of(context)!.tooManyChar
                            : null,
                      ),
                      maxLength: 50, // Set maximum lengths
                      buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null, // Hide default counter
                      onChanged: (value) {
                        if (value.length <= 50) {
                          setState(() {
                            widget.pollOptions[index] = value;
                          });
                        }
                      },
                    ),
                  ),
                  if (widget.pollOptions.length > 2 &&
                      index == widget.pollOptions.length - 1)
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          widget.pollOptions.removeAt(index);
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
          if (widget.pollOptions.length < 4)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  widget.pollOptions.add('');
                });
              },
              icon: Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.addOption),
            ),
        ],
      ),
    );
  }
}
