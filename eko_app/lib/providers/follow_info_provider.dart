import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/types/follow_info.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
part '../generated/providers/follow_info_provider.g.dart';

@riverpod
class FollowInfo extends _$FollowInfo {
  @override
  Future<FollowInfoModel> build(String uid) async {
    final List<Map<String, dynamic>> res = await supabase.rpc(
      'get_follow_info',
      params: {'p_uid': uid},
    );
    return FollowInfoModel.fromJson(res.first);
  }
}
