class MessageMediaDownloadProgress {
  String messageId;
  String downloadTaskId;
  double downloadProgress = 0;
  bool downloadCompleted = false;
  bool isDownloading = false;
  bool downloadFailed = false;
  MessageMediaDownloadProgress({
    required this.messageId,
    required this.downloadTaskId,
    required this.downloadProgress,
    required this.downloadCompleted,
    required this.isDownloading,
    required this.downloadFailed,
  });
}
