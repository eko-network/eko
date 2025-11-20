import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/utilities/constants.dart' as c;
import 'package:untitled_app/widgets/icons.dart';
import 'package:url_launcher/url_launcher.dart';

class VerificationBadge extends ConsumerWidget {
  final String uid;
  const VerificationBadge({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(uid));
    final verificationUrl = userAsync.valueOrNull?.verificationUrl ?? '';
    final displayUrl = verificationUrl.replaceFirst(RegExp(r'^https?://'), '');

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: verificationUrl.isNotEmpty
            ? () {
                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;
                final RenderBox button =
                    context.findRenderObject() as RenderBox;
                final position =
                    button.localToGlobal(Offset.zero, ancestor: overlay);

                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    position.dx,
                    position.dy + button.size.height,
                    position.dx + button.size.width,
                    position.dy,
                  ),
                  items: [
                    PopupMenuItem(
                      onTap: () async {
                        final uri = Uri.parse(verificationUrl);
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Link(
                            color: Theme.of(context).colorScheme.surfaceTint,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            displayUrl,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surfaceTint,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  Theme.of(context).colorScheme.surfaceTint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            : null,
        child: Icon(
          Icons.verified_rounded,
          size: c.verifiedIconSize,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
