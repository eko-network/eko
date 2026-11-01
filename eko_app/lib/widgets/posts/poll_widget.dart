import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/post_provider.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class PollWidget extends ConsumerWidget {
  final PostModel post;
  final bool isPreview;

  const PollWidget({required this.post, this.isPreview = false, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poll = post.poll;
    if (poll == null) {
      return const SizedBox.shrink();
    }
    final selectedVote = post.vote;
    final totalVotes = poll.fold(0, (sum, item) => sum + item.voteCount);

    final pollWidth = c.widthGetter(context) * 0.7;

    return SizedBox(
      width: pollWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...poll.map((entry) {
            final optionId = entry.optionId;
            final option = entry.value;
            final voteCount = entry.voteCount;
            double percentage = totalVotes > 0 ? voteCount / totalVotes : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: isPreview
                    ? null
                    : () => ref
                          .read(postProvider(post.id).notifier)
                          .addPollVote(optionId: optionId),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 48,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isPreview
                                ? Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          height: 48,
                          width: pollWidth * percentage,
                          decoration: BoxDecoration(
                            color: selectedVote != null
                                ? (selectedVote == optionId)
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer
                                      : Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          height: 48,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (selectedVote != null)
                                Text(
                                  '${(percentage * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          if (selectedVote != null && !isPreview)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$totalVotes ${AppLocalizations.of(context)!.votes}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(postProvider(post.id).notifier)
                        .removePollVote(),
                    child: Text(
                      AppLocalizations.of(context)!.removeVote,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
