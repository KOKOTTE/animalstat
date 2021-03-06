import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'extensions/extensions.dart';
import 'models/models.dart';
import 'animal_repository.dart';

class FirestoreAnimalRepository implements AnimalRepository {
  final CollectionReference _animalCollection;

  FirestoreAnimalRepository(User user)
      : assert(user != null),
        _animalCollection = Firestore.instance
            .collection('companies/${user.companyId}/animals');

  @override
  Stream<List<Animal>> findAnimals(int animalNumber) {
    if (animalNumber == null) {
      return Stream.empty();
    }

    int amountOfDigits = animalNumber.toString().length;
    int factor = pow(10, 5 - amountOfDigits);
    int start = animalNumber * factor;
    int end = (animalNumber + 1) * factor;

    return _animalCollection
        .where('animal_number', isGreaterThanOrEqualTo: start)
        .where('animal_number', isLessThan: end)
        .snapshots()
        .map((snap) => snap.documents.map((doc) => doc.toAnimal()).toList());
  }

  @override
  Stream<List<AnimalHistoryRecord>> findAnimalHistory(int animalNumber) {
    if (animalNumber == null) {
      return Stream.empty();
    }

    return _animalCollection
        .document(animalNumber.toString())
        .collection('history')
        .orderBy('seen_on', descending: true)
        .snapshots()
        .map((snap) =>
            snap.documents.map((doc) => doc.toAnimalHistoryRecord()).toList());
  }

  @override
  Stream<Animal> findAnimalByNumber(int animalNumber) {
    if (animalNumber == null) {
      throw ArgumentError.notNull('animalNumber');
    }

    return _animalCollection
        .document(animalNumber.toString())
        .snapshots()
        .map((snap) => snap.toAnimal());
  }

  @override
  Future insertHistoryRecord(
    int animalNumber,
    AnimalHistoryRecord animalHistoryRecord,
  ) {
    if (animalNumber == null) {
      throw ArgumentError.notNull('animalNumber');
    }

    if (animalHistoryRecord == null) {
      throw ArgumentError.notNull('animalHistoryRecord');
    }

    final timestamp = Timestamp.fromDate(animalHistoryRecord.seenOn);
    final historyRecordJson = animalHistoryRecord.toJson();

    return _animalCollection
        .document(animalNumber.toString())
        .collection('history')
        .document(timestamp.millisecondsSinceEpoch.toString())
        .setData(historyRecordJson);
  }
}
