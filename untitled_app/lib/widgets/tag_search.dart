import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/interfaces/search.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/widgets/user_card.dart';

bool _isSeparator(String char) {
  return char == ' ' ||
      char == '\n' ||
      char == '\t' ||
      char == '.' ||
      char == ',' ||
      char == ';';
}

(int, int) _getStartEnd(String text, int cursorPos) {
  int start = cursorPos;
  while (start > 0 && !_isSeparator(text[start - 1])) {
    start--;
  }

  // Find end of the current word
  int end = cursorPos;
  while (end < text.length && !_isSeparator(text[end])) {
    end++;
  }

  return (start, end);
}

void onCardTap(String username, TextEditingController controller) {
  final cursorPos = controller.selection.baseOffset;
  final text = controller.text;

  if (cursorPos < 0 || cursorPos > text.length) {
    return;
  }
  final (start, end) = _getStartEnd(text, cursorPos);
  final needsSpace = (end >= text.length);
  final maybeSpace = needsSpace ? ' ' : '';
  final newText = text.replaceRange(start, end, '@$username$maybeSpace');
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: start + username.length + 2),
  );
}

String? searchText(TextEditingController controller) {
  final cursorPos = controller.selection.baseOffset;
  final text = controller.text;

  if (cursorPos < 0 || cursorPos > text.length) return null;

  final (start, end) = _getStartEnd(text, cursorPos);

  final currentWord = text.substring(start, end);
  if (currentWord.startsWith('@')) {
    return currentWord.substring(1);
  }
  return null;
}

class TagSearch extends ConsumerStatefulWidget {
  final String searchText;
  final Future<List<String>> Function(String)? getter;
  final void Function()? onLoad;
  final double? height;
  final void Function(String) onCardTap;
  const TagSearch(
      {super.key,
      required this.searchText,
      this.getter,
      this.onLoad,
      this.height,
      required this.onCardTap});

  @override
  ConsumerState<TagSearch> createState() => _TagSearchState();
}

class _TagSearchState extends ConsumerState<TagSearch> {
  Future<List<String>> userSearch(String s) async {
    final hits =
        await SearchInterface.hitsQuery(s, similarity: null, uid: null);
    final List<String> retList = [];
    for (final hit in hits) {
      ref.read(userPoolProvider).put(hit.$1);
      retList.add(hit.$1.uid);
    }
    return retList;
  }

  Future<List<String>> future() async {
    final data = widget.getter == null
        ? await userSearch(widget.searchText)
        : await widget.getter!(widget.searchText);
    if (widget.onLoad != null) widget.onLoad!();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: SizedBox(
        height: widget.height,
        child: FutureBuilder(
          future: future(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data!;
              return NotificationListener<ScrollNotification>(
                onNotification: (_) => true,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) => UserCard(
                    uid: data[index],
                    actionWidget: (_) => SizedBox(),
                    onCardPressed: (user) => widget.onCardTap(user.username),
                  ),
                ),
              );
            }
            return Align(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
