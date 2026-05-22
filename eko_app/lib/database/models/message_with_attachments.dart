import 'package:eko_app/database/database.dart';

class MessageWithAttachments {
  final Message message;
  final List<MediaData> attachments;
  MessageWithAttachments({required this.message, this.attachments = const []});
}
