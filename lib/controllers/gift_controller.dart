import 'package:hedieaty_app/models/gifts_model.dart';

class GiftController {
  Future<List<Gift>> fetchGiftsForEvent(String? eventId) async {
    return await Gift.fetchGiftsForEvent(eventId);
  }

  Future<int> addGift(Gift gift, {int?published}) async {
    return await Gift.insertGift(gift.toMap(), published: published);
  }

  Future<int> updateGift(Gift gift) async {
    return await Gift.updateGift(gift.id!, gift.toMap());
  }

  Future<int> deleteGift(int id, {String? firestoreId}) async {
    return await Gift.deleteGift(id, firestoreId: firestoreId);
  }

  Future<void> publishGiftToFirestore(Gift gift) async {
    return await Gift.publishGiftToFirestore(gift);
  }

  Future<void> unpublishGift(Gift gift) async {
    return await Gift.unpublishGift(gift);
  }

}
