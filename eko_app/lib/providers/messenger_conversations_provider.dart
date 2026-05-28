import 'package:eko_app/database/daos/conversations_dao.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/ecp_runtime_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final conversationsProvider =
    StreamProvider.autoDispose<List<ConversationWithContact>>((ref) {
  final uid = ref.watch(authProvider).uid;
  if (uid == null || uid.isEmpty) {
    return Stream.value([]);
  }
  if (!ref.watch(ecpRuntimeReadyProvider)) {
    return Stream.value([]);
  }
  return db.conversationsDao.watchConversationsWithContact();
});
