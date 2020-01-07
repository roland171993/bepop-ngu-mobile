class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
    required this.attachments,
  });

  final int id;
  final int chatId;
  final int senderId;
  final String? message;
  final String? readAt;
  final String createdAt;
  final String updatedAt;
  final List<ChatMessageAttachment> attachments;

  ChatMessage.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        chatId = json['chat_id'] as int,
        senderId = json['sender_id'] as int,
        message = json['message'] as String?,
        readAt = json['read_at'] as String?,
        createdAt = json['created_at'] as String,
        updatedAt = json['updated_at'] as String,
        attachments = (json['attachment'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(ChatMessageAttachment.fromJson)
            .toList();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'chat_id': chatId,
        'sender_id': senderId,
        'message': message,
        'read_at': readAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'attachment': attachments,
      };

  ChatMessage copyWith({
    int? id,
    int? chatId,
    int? senderId,
    String? message,
    String? readAt,
    String? createdAt,
    String? updatedAt,
    List<ChatMessageAttachment>? attachments,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
    );
  }
}

class ChatMessageAttachment {
  const ChatMessageAttachment({
    required this.id,
    required this.messageId,
    required this.file,
    required this.fileType,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int messageId;
  final String file;
  final String fileType;
  final String createdAt;
  final String updatedAt;

  ChatMessageAttachment.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        messageId = json['message_id'] as int,
        file = json['file'] as String,
        fileType = json['file_type'] as String,
        createdAt = json['created_at'] as String,
        updatedAt = json['updated_at'] as String;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'message_id': messageId,
        'file': file,
        'file_type': fileType,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
