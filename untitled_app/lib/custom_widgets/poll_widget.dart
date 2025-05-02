import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../utilities/constants.dart' as c;

class PollWidget extends StatefulWidget {
  final String postId;
  final List<String> options;
  final Map<String, int> pollVoteCounts;
  final bool isPreview;

  const PollWidget({
    super.key,
    required this.postId,
    required this.options,
    required this.pollVoteCounts,
    this.isPreview = false,
  });

  @override
  State<PollWidget> createState() => PollWidgetState();
}

class PollWidgetState extends State<PollWidget> {
  int? selectedOption;
  Map<int, int> voteCounts = {};
  int totalVotes = 0;
  bool hasVoted = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPollData();
  }

  void loadPollData() {
    int total = 0;
    for (int i = 0; i < widget.options.length; i++) {
      final count = widget.pollVoteCounts[i.toString()] ?? 0;
      voteCounts[i] = count;
      total += count;
    }
    totalVotes = total;

    // Check if user has already voted
    final userVote = locator<CurrentUser>().checkPollVote(widget.postId);

    if (userVote != null) {
      selectedOption = userVote;
      hasVoted = true;
    }

    isLoading = false;
  }

  Future<void> vote(int optionIndex) async {
    if (hasVoted || widget.isPreview) return;

    final success =
        await locator<CurrentUser>().addPollVote(widget.postId, optionIndex);

    if (success) {
      setState(() {
        selectedOption = optionIndex;
        hasVoted = true;
        voteCounts[optionIndex] = (voteCounts[optionIndex] ?? 0) + 1;
        totalVotes++;
      });
    }
  }

  Future<void> removeVote() async {
    if (!hasVoted || widget.isPreview) return;

    final success = await locator<CurrentUser>().removePollVote(widget.postId);

    if (success) {
      setState(() {
        final oldSelected = selectedOption!;
        voteCounts[oldSelected] = (voteCounts[oldSelected] ?? 1) - 1;
        totalVotes--;
        selectedOption = null;
        hasVoted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return SizedBox(
      width: width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final voteCount = voteCounts[index] ?? 0;
            double percentage = totalVotes > 0 ? voteCount / totalVotes : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: hasVoted || widget.isPreview ? null : () => vote(index),
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
                            color: widget.isPreview
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
                            color: hasVoted
                                ? Theme.of(context).colorScheme.primaryContainer
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
                              if (hasVoted)
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
          if (hasVoted && !widget.isPreview)
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
                    onPressed: removeVote,
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
