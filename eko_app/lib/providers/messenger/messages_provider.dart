// import 'dart:async';
// import 'dart:io';
//
// import 'package:drift/drift.dart';
// import 'package:ecp/ecp.dart';
// import 'package:eko_app/database/database.dart';
// import 'package:eko_app/providers/auth_provider.dart';
// import 'package:eko_app/providers/ecp_client_holder.dart';
// import 'package:eko_app/services/messenger_notification_service.dart';
// import 'package:eko_app/utilities/platform.dart' as platform;
// import 'package:flutter/widgets.dart' hide Image;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// part '../generated/providers/messages_provider.g.dart';
//
// @Riverpod(keepAlive: true)
// class MessagePolling extends _$MessagePolling with WidgetsBindingObserver {
//   StreamSubscription? _messageStreamSubscription;
//   bool _isStreamActive = false;
//   bool isDesktopNotifiyEligiable = true;
//
//   final _notificationService = MessengerNotificationService();
//
//   @override
//   void build() {
//     WidgetsBinding.instance.addObserver(this);
//
//     ref.listen(authProvider, (previous, next) {
//       if (next.uid != null && next.uid!.isNotEmpty) {
//         _tryStartStreaming();
//       } else {
//         _stopStreaming();
//       }
//     });
//
//     ref.listen(ecpClientHolderProvider, (previous, next) {
//       if (next.valueOrNull != null) {
//         _tryStartStreaming();
//       } else {
//         _stopStreaming();
//       }
//     });
//
//     _tryStartStreaming();
//
//     ref.onDispose(() {
//       WidgetsBinding.instance.removeObserver(this);
//       _stopStreaming();
//     });
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!platform.isMobile) return;
//
//     switch (state) {
//       case AppLifecycleState.resumed:
//         _resumeStream();
//         isDesktopNotifiyEligiable = true;
//         break;
//       case AppLifecycleState.paused:
//         _pauseStream();
//         break;
//       case AppLifecycleState.inactive:
//       case AppLifecycleState.detached:
//       case AppLifecycleState.hidden:
//         isDesktopNotifiyEligiable = false;
//         break;
//     }
//   }
//
//   void _tryStartStreaming() {
//     if (ref.read(ecpClientHolderProvider).valueOrNull == null) return;
//     if (ref.read(ecpClientHolderProvider.notifier).client == null) return;
//     _startStreaming();
//   }
//
//   EcpClient? _activeClient() =>
//       ref.read(ecpClientHolderProvider.notifier).client;
//
//   void _pauseStream() {
//     if (!_isStreamActive) return;
//     try {
//       _activeClient()?.messageStreamController.pause();
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }
//
//   void _resumeStream() {
//     if (!_isStreamActive) return;
//     try {
//       _activeClient()?.messageStreamController.resume();
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }
//
//   void _startStreaming() {
//     if (_messageStreamSubscription != null) return;
//
//     final ecpClient = _activeClient();
//     if (ecpClient == null) return;
//     if (ecpClient.capabilities.socket?.endpoint == null) return;
//
//     _isStreamActive = true;
//     _messageStreamSubscription =
//         ecpClient.messageStreamController.getMessageStream().listen(
//       processMessage,
//       onError: (error) {
//         debugPrint(error.toString());
//       },
//       cancelOnError: false,
//     );
//   }
//
//   void _stopStreaming() {
//     _messageStreamSubscription?.cancel();
//     _messageStreamSubscription = null;
//     _isStreamActive = false;
//   }
//
//   Future<void> processMessage(
//     ActivityWithMetaData activity, {
//     bool notifiableOverride = false,
//   }) async {
//     final ecpClient = _activeClient();
//     if (ecpClient == null) return;
//     final me = ecpClient.me;
//
//     final notifiable =
//         (platform.isDesktop && isDesktopNotifiyEligiable) || notifiableOverride;
//
//     switch (activity.activity) {
//       case Create create:
//         final Uri otherParty;
//         if (me.id == activity.actor) {
//           otherParty = create.base.to;
//         } else {
//           otherParty = activity.actor;
//         }
//
//         var contact = await db.contactsDao.getContactById(otherParty);
//         if (contact == null) {
//           try {
//             final person = await ecpClient.getActor(otherParty);
//             await db.contactsDao.insertNewContact(person);
//             contact = person;
//           } catch (e) {
//             debugPrint(e.toString());
//             return;
//           }
//         }
//
//         final conversation =
//             await db.conversationsDao.getConversationByParticipant(otherParty);
//         if (conversation == null) {
//           await db.conversationsDao.insertNewConversation(
//             ConversationsCompanion(participant: Value(otherParty)),
//           );
//         }
//
//         if (notifiable && me.id != activity.actor) {
//           final String notification;
//           switch (create.object) {
//             case Note note:
//               if (note.content != null) {
//                 notification = note.content!;
//               } else if (note.attachments?.isNotEmpty ?? false) {
//                 notification = '📷 Image';
//               } else {
//                 notification = 'New Message';
//               }
//               break;
//             case Image _:
//               notification = '📷 Image';
//             default:
//               notification = 'New Message';
//           }
//           await _notificationService.showNewMessageNotification(
//             from: contact?.preferredUsername ?? 'Unknown',
//             message: notification,
//           );
//         }
//
//         await db.messagesDao.insertNewMessage(
//           create.object,
//           MessageStatus.delivered,
//           from: activity.actor,
//           to: create.base.to,
//         );
//         break;
//       case Delivered delivered:
//         await db.messagesDao.updateMessageStatusFromEnvelope(
//           delivered.object,
//           MessageStatus.delivered,
//         );
//       default:
//         debugPrint('Skipping Unknown activity: ${activity.activity.type}');
//     }
//   }
// }
//
// @riverpod
// Stream<List<MessageWithAttachments>> messageStream(
//   Ref ref,
//   Uri contactId,
//   Uri actorId,
// ) {
//   final uid = ref.watch(authProvider).uid;
//   if (uid == null || uid.isEmpty) {
//     return Stream.value([]);
//   }
//
//   return db.messagesDao.watchMessagesWithAttachmentForConversation(
//     contactId,
//     actorId,
//   );
// }
