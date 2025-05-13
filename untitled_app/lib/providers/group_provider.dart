import 'package:riverpod_annotation/riverpod_annotation.dart';
// Necessary for code-generation to work
part '../generated/providers/group_provider.g.dart';

@riverpod
class Group extends _$Group {

@override
  Future<GroupModel> build(String id) async {
		return GroupModel.fromJson(json, ref.read(curr
  }}
