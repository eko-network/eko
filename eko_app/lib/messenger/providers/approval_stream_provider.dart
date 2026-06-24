import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../generated/messenger/providers/approval_stream_provider.g.dart';

@riverpod
Stream<(StoredApprovalRequest, DateTime)?> rawApprovalStream(Ref ref) {
  return (db.select(db.approvalRequest)
        ..orderBy([(u) => OrderingTerm.asc(u.createdAt)])
        ..limit(1))
      .watchSingleOrNull()
      .map((u) {
        if (u == null) {
          return null;
        }
        return (
          StoredApprovalRequest(did: u.did, publicKey: u.publicKey),
          u.createdAt,
        );
      });
}

@riverpod
class ValidatedApproval extends _$ValidatedApproval {
  String? _currentlyValidatingDid;

  @override
  StoredApprovalRequest? build() {
    ref.listen(rawApprovalStreamProvider, (previous, next) {
      final request = next.value;
      if (request == null) {
        state = null;
        return;
      }
      _processRequest(request.$1, request.$2);
    });

    return null;
  }

  Future<void> _processRequest(
    StoredApprovalRequest request,
    DateTime createdAt,
  ) async {
    debugPrint('[ValidatedApproval] Proccessing Message');
    final age = DateTime.now().difference(createdAt);
    if (age.inMinutes > c.maxAgeInMinutesOfApproval) {
      debugPrint('[ValidatedApproval] Too Old');
      await _deleteOldRequests();
      return;
    }

    if (_currentlyValidatingDid == request.did || state?.did == request.did) {
      return;
    }
    _currentlyValidatingDid = request.did;

    try {
      final isValid = await _ensurePendingApproval(request.did);

      if (isValid) {
        state = request;
      } else {
        debugPrint('[ValidatedApproval] Not Pending');
        state = null;
        await deleteRequest(request.did);
      }
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
      state = null;
      await deleteRequest(request.did);
    } finally {
      _currentlyValidatingDid = null;
    }
  }

  Future<void> _deleteOldRequests() async {
    final cutoff = DateTime.now().subtract(
      const Duration(minutes: c.maxAgeInMinutesOfApproval),
    );

    await (db.delete(
      db.approvalRequest,
    )..where((u) => u.createdAt.isSmallerThanValue(cutoff))).go();
  }

  Future<void> deleteRequest(String did) async {
    await (db.delete(db.approvalRequest)..where((u) => u.did.equals(did))).go();
  }

  Future<bool> _ensurePendingApproval(String did) {
    return supabase.rpc('ensure_pending_approval', params: {'did': did});
  }
}
