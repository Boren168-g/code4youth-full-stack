import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:code4youth/firebase_options.dart';
import 'package:code4youth/services/seed_service.dart';

void main() {
  test('Seed Database', () async {
    // This requires the emulator to be running and have internet
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final seedService = SeedService();
    await seedService.seedDatabase();
    print('✅ Database seeded from test!');
  });
}
