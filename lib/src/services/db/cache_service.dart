import 'package:flutter/foundation.dart';

import '../../channel/base_channel.dart';
import '../../sdk/sendbird_sdk_api.dart';

abstract class CacheStorage {
  void insert({@required Cacheable data, @required String channelKey});
  void delete<T extends Cacheable>({@required String channelKey, String key});
  void deleteAll();
  T find<T extends Cacheable>({
    @required String channelKey,
    String key,
  });
  List<T> findAll<T extends Cacheable>({String channelKey});
  void markAsDirtyAll();
}

abstract class CacheUnit {
  Cacheable find<T extends Cacheable>({String key});
  void delete<T extends Cacheable>({String key});
  void insert(Cacheable data);
  void markAsDirty();
}

abstract class Cacheable<T> {
  String get key;
  String get primaryKey;
  bool dirty;
  void copyWith(T others);
}

extension Operation on Cacheable {
  void removeFromCache() {
    final sdk = SendbirdSdk().getInternal();
    final cacheKey = this is BaseChannel ? null : key;
    sdk.cache.delete(channelKey: primaryKey, key: cacheKey);
  }

  void saveToCache() {
    final sdk = SendbirdSdk().getInternal();
    sdk.cache.insert(data: this, channelKey: primaryKey);
  }
}
