import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/types/follow_info.dart';
import 'package:untitled_app/utilities/supabase_ref.dart';
// Necessary for code-generation to work
part '../generated/providers/follow_info_provider.g.dart';

@riverpod
class FollowInfo extends _$FollowInfo {
  @override
  Future<FollowInfoModel> build(String uid) async {
    final List<Map<String, dynamic>> res =
        await supabase.rpc('get_follow_info', params: {'p_uid': uid});
    print(res);
    return FollowInfoModel.fromJson(res.first);
  }
}
