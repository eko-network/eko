import 'package:eko_app/messenger/widgets/emoji_picker.dart';
import 'package:eko_app/messenger/widgets/gif_picker.dart';
import 'package:eko_app/utilities/api_constants.dart' as ac;
import 'package:flutter/material.dart';
import 'package:klipy_dart/klipy_dart.dart';

class MediaPicker extends StatefulWidget {
  final TextEditingController textController;
  final void Function(KlipyResultObject) onGifSelected;

  const MediaPicker({
    super.key,
    required this.textController,
    required this.onGifSelected,
  });

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final KlipyClient? klipyClient;

  _MediaPickerState() : klipyClient = _createKlipyClient();

  static KlipyClient? _createKlipyClient() {
    return KlipyClient(apiKey: ac.klipyKey);
  }

  @override
  void initState() {
    super.initState();
    _tabController = klipyClient == null
        ? TabController(length: 1, vsync: this, initialIndex: 0)
        : TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            dividerColor: colorScheme.outlineVariant,
            tabs: [
              const Tab(text: 'Emoji'),
              if (klipyClient != null) const Tab(text: 'GIFs'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                StyledEmojiPicker(textController: widget.textController),
                if (klipyClient != null)
                  GifPicker(
                    onGifSelected: widget.onGifSelected,
                    client: klipyClient!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
