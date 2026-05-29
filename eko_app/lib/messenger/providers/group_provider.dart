import 'dart:convert';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/mappers.dart';
import 'package:eko_app/messenger/types/group.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
part '../../generated/messenger/providers/group_provider.g.dart';

@riverpod
Stream<List<GroupWithUsers>> group(Ref ref) {
  final ecp = ref.watch(ecpClientProvider);
  final query = db.select(db.mlsGroups)..where((t) => t.isActive.equals(true));
  return query.watch().asyncMap((list) async {
    final l = list.map((gr) => gr.toRecord());
    return await Future.wait(
      l.map((gr) async {
        final gm = await ecp.groups.getMembers(gr);
        return (
          group: gm.group,
          users: gm.members.map((m) {
            final bytes = m.credential;
            if (bytes.length == 16) {
              return Uuid.unparse(bytes);
            } else if (bytes.length == 19) {
              // MLS BasicCredential: 2 bytes type (0x00 0x01) + 1 byte length (0x10) + 16 bytes identity
              final identity = bytes.sublist(3);
              return Uuid.unparse(identity);
            } else {
              final hex = bytes
                  .map((b) => b.toRadixString(16).padLeft(2, '0'))
                  .join();
              debugPrint(
                'ECP member credential has unexpected length: ${bytes.length} bytes. Hex: $hex',
              );
              try {
                return utf8.decode(bytes);
              } catch (_) {
                return hex;
              }
            }
          }).toSet(),
        );
      }),
    );
  });
}
