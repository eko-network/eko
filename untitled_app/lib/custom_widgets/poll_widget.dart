import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/types/post.dart';
import '../utilities/constants.dart' as c;

class PollWidget extends ConsumerWidget {
  final PostModel post;
  final bool isPreview;

  const PollWidget({
    required this.post,
    this.isPreview = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final currentUser = ref.watch(currentUserProvider);
    int totalVotes = 0;
    if (post.pollVoteCounts != null) {
      totalVotes =
          post.pollVoteCounts!.values.fold(0, (sum, count) => sum + count);
    }

    return SizedBox(
      width: width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...post.pollOptions!.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final voteCount = post.pollVoteCounts?[index.toString()] ?? 0;
            double percentage = totalVotes > 0 ? voteCount / totalVotes : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: isPreview
                    ? null
                    : () => ref
                        .read(postProvider(post.id).notifier)
                        .addPollVote(optionIndex: index),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // Background container
                        Container(
                          height: 48,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isPreview
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // Fill container for votes
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          height: 48,
                          width: MediaQuery.of(context).size.width *
                              0.7 *
                              percentage,
                          decoration: BoxDecoration(
                            color: currentUser.pollVotes.containsKey(post.id)
                                ? (currentUser.pollVotes[post.id] == index)
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (currentUser.pollVotes.containsKey(post.id))
                                Text(
                                  '${(percentage * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
          if (currentUser.pollVotes.containsKey(post.id) && !isPreview)
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
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
