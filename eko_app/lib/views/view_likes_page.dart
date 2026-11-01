import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/widgets/common/infinite_scrolly.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';
import 'package:eko_app/widgets/users/user_card.dart';
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';

class ViewPostLikesPage extends ConsumerWidget {
  final int postId;
  final bool dislikes;
  const ViewPostLikesPage({
    super.key,
    required this.postId,
    this.dislikes = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return AppScaffold(
      appBar: EkoAppBar(
        title: dislikes
            ? Text(AppLocalizations.of(context)!.viewDislikes)
            : Text(AppLocalizations.of(context)!.viewLikes),
      ),
      body: _LikesList(
        rpcName: 'paginated_post_likes',
        targetId: postId,
        dislikes: dislikes,
      ),
    );
  }
}

class ViewCommentLikesPage extends ConsumerWidget {
  final int commentId;
  final bool dislikes;
  const ViewCommentLikesPage({
    super.key,
    required this.commentId,
    this.dislikes = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return AppScaffold(
      appBar: EkoAppBar(
        title: dislikes
            ? Text(AppLocalizations.of(context)!.viewDislikes)
            : Text(AppLocalizations.of(context)!.viewLikes),
      ),
      body: _LikesList(
        rpcName: 'paginated_comment_likes',
        targetId: commentId,
        dislikes: dislikes,
      ),
    );
  }
}

class _LikesList extends ConsumerWidget {
  final String rpcName;
  final int targetId;
  final bool dislikes;

  const _LikesList({
    required this.rpcName,
    required this.targetId,
    required this.dislikes,
  });

  Future<(List<MapEntry<String, Never?>>, bool)> getter(
    List<MapEntry<String, Never?>> list,
    WidgetRef ref,
  ) async {
    final lastUid = list.isEmpty ? null : list.last.key;
    final rows = await supabase.rpc(
      rpcName,
      params: {
        'p_limit': c.usersOnSearch,
        'p_id': targetId,
        'p_last_uid': lastUid,
        'p_dislikes': dislikes,
      },
    );

    final rowList = rows as List<dynamic>? ?? [];
    final userList = rowList
        .map((row) => UserModel.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();

    ref.read(userPoolProvider).putAll(userList);
    return (
      userList.map((item) => MapEntry(item.uid, null)).toList(),
      userList.length < c.usersOnSearch,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InfiniteScrolly<String, Never?>(
      getter: (data) async {
        return await getter(data, ref);
      },
      widget: userCardBuilder,
      initialLoadingWidget: UserLoader(),
    );
  }
}
