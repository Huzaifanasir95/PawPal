// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatImpl _$$ChatImplFromJson(Map<String, dynamic> json) => _$ChatImpl(
  id: json['id'] as String,
  petOwnerId: json['petOwnerId'] as String,
  vetId: json['vetId'] as String,
  petId: json['petId'] as String?,
  petName: json['petName'] as String?,
  lastMessage: json['lastMessage'] as String?,
  lastMessageAt:
      json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
  unreadCountOwner: (json['unreadCountOwner'] as num?)?.toInt() ?? 0,
  unreadCountVet: (json['unreadCountVet'] as num?)?.toInt() ?? 0,
  otherUserName: json['otherUserName'] as String?,
  otherUserPhoto: json['otherUserPhoto'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ChatImplToJson(_$ChatImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'petOwnerId': instance.petOwnerId,
      'vetId': instance.vetId,
      'petId': instance.petId,
      'petName': instance.petName,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'unreadCountOwner': instance.unreadCountOwner,
      'unreadCountVet': instance.unreadCountVet,
      'otherUserName': instance.otherUserName,
      'otherUserPhoto': instance.otherUserPhoto,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String?,
      senderPhoto: json['senderPhoto'] as String?,
      content: json['content'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderPhoto': instance.senderPhoto,
      'content': instance.content,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$StartChatRequestImpl _$$StartChatRequestImplFromJson(
  Map<String, dynamic> json,
) => _$StartChatRequestImpl(
  vetId: json['vetId'] as String,
  petId: json['petId'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$$StartChatRequestImplToJson(
  _$StartChatRequestImpl instance,
) => <String, dynamic>{
  'vetId': instance.vetId,
  'petId': instance.petId,
  'message': instance.message,
};

_$SendMessageRequestImpl _$$SendMessageRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SendMessageRequestImpl(
  chatId: json['chatId'] as String,
  content: json['content'] as String,
);

Map<String, dynamic> _$$SendMessageRequestImplToJson(
  _$SendMessageRequestImpl instance,
) => <String, dynamic>{'chatId': instance.chatId, 'content': instance.content};
