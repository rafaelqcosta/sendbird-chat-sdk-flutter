// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_change_logs_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageChangeLogParams _$MessageChangeLogParamsFromJson(
    Map<String, dynamic> json) {
  return MessageChangeLogParams()
    ..includeMetaArray = json['with_sorted_meta_array'] as bool
    ..includeReactions = json['include_reactions'] as bool
    ..includeParentMessageText = json['include_parent_message_text'] as bool
    ..includeReplies = json['include_replies'] as bool
    ..includeThreadInfo = json['include_thread_info'] as bool;
}

Map<String, dynamic> _$MessageChangeLogParamsToJson(
        MessageChangeLogParams instance) =>
    <String, dynamic>{
      'with_sorted_meta_array': instance.includeMetaArray,
      'include_reactions': instance.includeReactions,
      'include_parent_message_text': instance.includeParentMessageText,
      'include_replies': instance.includeReplies,
      'include_thread_info': instance.includeThreadInfo,
    };
