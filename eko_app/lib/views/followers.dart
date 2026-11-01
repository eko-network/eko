import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/providers/follow_info_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/widgets/common/infinite_scrolly.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';
import 'package:eko_app/widgets/users/user_card.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class Followers extends ConsumerStatefulWidget {
  final String username;
  final String? uid;
  const Followers({required this.username, this.uid, super.key});
  @override
  ConsumerState<Followers> createState() => _FollowersState();
}

class _FollowersState extends ConsumerState<Followers> {
  String? _resolvedUid;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _resolveUid();
  }

  Future<void> _resolveUid() async {
    if (widget.uid != null && widget.uid!.isNotEmpty) {
      setState(() {
        _resolvedUid = widget.uid;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = await getUidFromUsername(widget.username);
      if (!mounted) return;
      setState(() {
        _resolvedUid = uid;
        _isLoading = false;
        if (uid == null) {
          _error = AppLocalizations.of(context)!.userNotFound;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = AppLocalizations.of(context)!.profileResolveFailed;
      });
    }
  }

  Future<(List<MapEntry<String, Never?>>, bool)> getter(
    List<MapEntry<String, Never?>> data,
  ) async {
    const chunkSize = c.usersOnSearch;
    final uid = _resolvedUid;
    if (uid == null) {
      return (<MapEntry<String, Never?>>[], true);
    }

    final lastUid = data.isEmpty ? null : data.last.key;

    final rows = await supabase.rpc(
      'paginated_user_followers',
      params: {'p_limit': chunkSize, 'p_uid': uid, 'p_last_uid': lastUid},
    );

    final List<Future<dynamic>> futures = [];
    final List<MapEntry<String, Never?>> returnData = [];
    for (final row in rows) {
      final sourceUid = (row['id'] ?? row['source_uid']) as String?;
      if (sourceUid == null || sourceUid.isEmpty) continue;
      returnData.add(MapEntry(sourceUid, null));
      futures.add(ref.read(userProvider(sourceUid).future));
    }

    await Future.wait(futures);
    return (returnData, returnData.length < chunkSize);
  }

  Future<void> onRefresh() async {
    await _resolveUid();
    final uid = _resolvedUid;
    if (uid != null) {
      ref.invalidate(followInfoProvider(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: EkoAppBar(title: Text(AppLocalizations.of(context)!.followers)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : InfiniteScrolly<String, Never?>(
              getter: getter,
              widget: (uid) => UserCard(uid: uid),
              onRefresh: onRefresh,
              initialLoadingWidget: UserLoader(),
            ),
    );
  }
}
