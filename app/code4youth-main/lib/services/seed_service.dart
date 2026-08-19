import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/curriculum.dart';

class SeedService {
  FirebaseFirestore? _db;

  SeedService() {
    try {
      _db = FirebaseFirestore.instance;
    } catch (e) {
      print('Firestore not initialized yet');
    }
  }

  Future<void> seedDatabase() async {
    if (_db == null) {
      throw Exception('Firebase not initialized. Run flutterfire configure first.');
    }
    final WriteBatch batch = _db!.batch();

    // 1. Seed Curriculum (Modules and Lessons)
    for (final module in Curriculum.modules) {
      final DocumentReference moduleRef = _db!.collection('curriculum').doc(module.id);
      batch.set(moduleRef, {
        'id': module.id,
        'title': module.title,
        'titleKm': module.titleKm,
        'description': module.description,
        'requiresModuleId': module.requiresModuleId,
        'order': Curriculum.modules.indexOf(module),
      });

      // Seed Lessons for this module
      for (final lesson in module.lessons) {
        final DocumentReference lessonRef = moduleRef.collection('lessons').doc(lesson.id);
        batch.set(lessonRef, {
          'id': lesson.id,
          'moduleId': lesson.moduleId,
          'title': lesson.title,
          'titleKm': lesson.titleKm,
          'summary': lesson.summary,
          'minutes': lesson.minutes,
          'xp': lesson.xp,
        });
      }
    }

    // 2. Seed Badges
    for (final badge in Badges.all) {
      final DocumentReference badgeRef = _db!.collection('badges').doc(badge.id);
      batch.set(badgeRef, {
        'id': badge.id,
        'name': badge.name,
        'description': badge.description,
        'requirement': badge.requirement,
      });
    }

    await batch.commit();
    print('✅ Database successfully seeded!');
  }
}
