import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/utilities/constants.dart' as c;
import 'package:untitled_app/utilities/supabase_ref.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import '../widgets/user_card.dart';

class ViewLikesPage extends ConsumerWidget {
  final int postId;
  final bool dislikes;
  const ViewLikesPage({super.key, required this.postId, this.dislikes = false});

  Future<(List<(String, Never?)>, bool)> getter(
      List<(String, Never?)> list, WidgetRef ref) async {
    final last = list.isNotEmpty ? list.last : null;
    final List<dynamic> response =
        await supabase.rpc('paginated_post_likes', params: {
      'p_limit': c.usersOnSearch,
      'p_id': postId,
      'p_last_uid': last?.$1,
      'p_dislikes': dislikes,
    });
    final List<(String, Never?)> retList = [];
    for (final map in response) {
      final user = UserModel.fromJson(map);
      ref.read(userPoolProvider).put(user);
      retList.add((user.uid, null));
    }
    return (retList, retList.length < c.usersOnSearch);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: dislikes
            ? Text(AppLocalizations.of(context)!.viewDislikes)
            : Text(AppLocalizations.of(context)!.viewLikes),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: InfiniteScrolly<String, Never?>(
        getter: (data) async {
          return await getter(data, ref);
        },
        widget: userCardBuilder,
        initialLoadingWidget: UserLoader(
          length: 12,
        ),
      ),
    );
  }
}
