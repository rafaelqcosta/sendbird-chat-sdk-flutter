import '../channel/group_channel.dart';
import '../constant/enums.dart';
import '../features/delivery/delivery_status.dart';
import '../features/read/read_status.dart';
import '../features/typing/typing_status.dart';
import '../message/base_message.dart';
import '../message/base_message_internal.dart';
import '../models/channel_event.dart';
import '../models/member.dart';
import '../models/user.dart';
import '../models/sender.dart';
import '../sdk/sendbird_sdk_api.dart';
import '../services/db/cache_service.dart';

extension GroupChannelInternal on GroupChannel {
  bool shouldUpdateLastMessage(BaseMessage message, Sender sender) {
    if (sender == null) {
      return false;
    }

    if (!message.isSilent ||
        sender.isCurrentUser ||
        message.forceUpdateLastMessage) {
      if (lastMessage == null) {
        return true;
      } else if (lastMessage.createdAt < message.createdAt) {
        return true;
      } else if (lastMessage.createdAt == message.createdAt &&
          lastMessage.messageId == message.messageId &&
          lastMessage.updatedAt < message.updatedAt) {
        return true;
      }
    }
    return false;
  }

  bool updateUnreadCount(BaseMessage message) {
    final currentUser = User(); //SendbirdSDK().getCurrentUser();

    if (!message.isSilent) {
      if (!message.sender.isCurrentUser) {
        increaseUnreadMessageCount();
        return true;
      }

      if (message.mentioned(user: currentUser, byOtherUser: message.sender)) {
        increaseUnreadMentionCount();
        return true;
      }
    }

    return false;
  }

  void setBlockedByMe({String targetId, bool blocked}) {
    members.forEach((member) {
      if (member.userId == targetId) {
        member.isBlockedByMe = blocked;
      }
    });
  }

  int myReadReceipt() {
    final sdk = SendbirdSdk().getInternal();
    final status = sdk.cache.find<ReadStatus>(
      channelKey: channelUrl,
      key: sdk.state.userId,
    );
    return status?.timestamp ?? 0;
  }

  bool get canChangeUnreadMessageCount =>
      myCountPreference == CountPreference.all ||
      myCountPreference == CountPreference.messageOnly;

  bool get canChangeUnreadMentionCount =>
      myCountPreference == CountPreference.all ||
      myCountPreference == CountPreference.mentionOnly;

  void increaseUnreadMessageCount() {
    if (canChangeUnreadMessageCount) {
      unreadMessageCount++;
    } else {}
  }

  void increaseUnreadMentionCount() {
    if (canChangeUnreadMentionCount) {
      unreadMentionCount++;
    } else {}
  }

  void decreaseUnreadMentionCount() {
    if (canChangeUnreadMentionCount && unreadMentionCount > 0) {
      unreadMentionCount--;
    } else {}
  }

  void clearUnreadCount() {
    unreadMentionCount = 0;
    unreadMessageCount = 0;
  }

  void addMember(Member newMember) {
    removeMember(newMember.userId);
    newMember.state = MemberState.joined;
    members.add(newMember);
    members.sort((a, b) => a.nickname.compareTo(b.nickname));

    final ts = DateTime.now().millisecondsSinceEpoch;
    DeliveryStatus delivery = DeliveryStatus(
      channelUrl: channelUrl,
      updatedDeliveryReceipt: {newMember.userId: ts},
    );
    ReadStatus read = ReadStatus(
      channelType: channelType,
      channelUrl: channelUrl,
      timestamp: ts,
      userId: newMember.userId,
    );

    delivery.saveToCache();
    read.saveToCache();

    _refreshMemberCounts();
  }

  void removeMember(String userId) {
    members.removeWhere((element) => element.userId == userId);
    _refreshMemberCounts();
  }

  void updateMember(User user) {
    final index = members.indexWhere((e) => e.userId == user.userId);
    if (index != -1) {
      final member = members[index];
      member.copyWith(user);
    }
  }

  void _refreshMemberCounts() {
    memberCount = members.length;
    joinedMemberCount = members
        .where((element) => element.state == MemberState.joined)
        .toList()
        .length;
  }

  void updateTypingStatus(Member member, {bool typing}) {
    final typingStatus = TypingStatus(
      channelType: channelType,
      channelUrl: channelUrl,
      user: member,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    if (typing) {
      typingStatus.saveToCache();
    } else {
      typingStatus.removeFromCache();
    }
  }

  void updateMemberCounts(ChannelEvent event) {
    memberCount = event.memberCount;
    joinedMemberCount = event.joinedMemberCount;
  }
}
