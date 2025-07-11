import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/utilities/constants.dart' as c;
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import '../widgets/user_card.dart';

class ViewLikesPage extends ConsumerWidget {
  final String postId;
  final bool dislikes;
  const ViewLikesPage({super.key, required this.postId, this.dislikes = false});

  Future<(List<(String, Never?)>, bool)> getter(
      List<(String, Never?)> list, WidgetRef ref) async {
    final baseQuery = FirebaseFirestore.instance
        .collection('users')
        .where('profileData.${dislikes ? 'dislikedPosts' : 'likedPosts'}',
            arrayContains: postId)
        .limit(c.usersOnSearch);
    final query = list.isEmpty ? baseQuery : baseQuery.startAfter([list.last]);
    final snapshot = await query.get();

    final userList = snapshot.docs.map((doc) => UserModel.fromJson(doc.data()));
    ref.read(userPoolProvider).putAll(userList);
    return ((
      userList.map((item) => (item.uid, null)).toList(),
      userList.length < c.usersOnSearch
    ));
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
