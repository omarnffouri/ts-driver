// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

class SendFilesMessageParams {
  String conversationId;
  String message;
  String tempId;
  List<File>? files;
  int? replyOnMessageId;
  Function(int)? progressListener;
  String type;
  int? duration;
  SendFilesMessageParams({
    required this.conversationId,
    required this.message,
    required this.tempId,
    this.files,
    this.replyOnMessageId,
    this.progressListener,
    required this.type,
    this.duration,
  });
}

// abstract class FileUploadProgressListener {
//   onProgressUpdate(int sent,int total);
// }
