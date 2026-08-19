import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../data/curriculum.dart';
import '../models/content.dart';
import '../models/gamification.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/seed_service.dart';
import '../services/backend_service.dart';

@immutable
class LessonOutcome {
  const LessonOutcome({
    required this.lesson,
    required this.xpEarned,
    required this.attempts,
    required this.newBadges,
    required this.leveledUp,
    required this.newLevel,
    required this.queuedOffline,
  });
  final Lesson lesson;
  final int xpEarned;
  final int attempts;
  final List<BadgeDef> newBadges;
  final bool leveledUp;
  final int newLevel;
  final bool queuedOffline;
  bool get firstTry => attempts == 1;
}

class AppState extends ChangeNotifier {
  AppState() {
    _authService.user.listen(_onAuthStateChanged);
  }

  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final SeedService _seedService = SeedService();
  final BackendService _backendService = BackendService();

  String _backendStatus = 'Not Checked';
  String get backendStatus => _backendStatus;

  UserProfile? _user = const UserProfile(
    displayName: 'Guest Learner',
    email: 'guest@example.com',
    grade: 'None',
    interests: [],
    avatar: '🦊',
  );
  
  UserProfile? get user => _user;
  bool get isSignedIn => firebase_auth.FirebaseAuth.instance.currentUser != null;
  bool get isActivated => _user?.isActivated ?? true;

  Future<void> checkBackendConnection() async {
    _backendStatus = 'Checking...';
    notifyListeners();

    final status = await _backendService.getStatus();
    if (status['status'] == 'Backend is running!') {
      _backendStatus = 'Connected';
      await _syncProgress();
    } else {
      _backendStatus = 'Error: ${status['message'] ?? 'Unknown error'}';
    }
    notifyListeners();
  }

  void _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = const UserProfile(displayName: 'Guest Learner', email: 'guest@example.com', grade: 'None', interests: [], avatar: '🦊');
      _clearLocalData();
    } else {
      // 1. Try to load from Firestore first
      var profile = await _dbService.getProfile(firebaseUser.uid);
      var progress = await _dbService.getProgress(firebaseUser.uid);

      // 2. If Firestore is empty, try to load from Docker
      if (profile == null) {
        final dockerData = await _backendService.getProfile(firebaseUser.uid);
        if (dockerData != null) {
          profile = UserProfile(
            displayName: dockerData['name'] ?? 'Learner',
            email: dockerData['email'] ?? 'learner@example.com',
            grade: dockerData['grade'] ?? 'Grade 10',
            interests: List<String>.from(dockerData['interests'] ?? []),
            avatar: dockerData['avatar'] ?? '🦊',
            languageCode: dockerData['language_code'] ?? 'en',
          );
          
          // Map progress fields from Docker
          _xp = dockerData['xp'] ?? 0;
          _streakDays = dockerData['streak_days'] ?? 0;
          _completedLessons.clear();
          _completedLessons.addAll(List<String>.from(dockerData['completed_lessons'] ?? []));
        }
      }

      if (profile != null) {
        _user = profile;
      } else {
        // Final fallback to Firebase basic info
        _user = UserProfile(
          displayName: firebaseUser.displayName ?? 'New Learner',
          email: firebaseUser.email ?? 'learner@example.com',
          grade: 'Grade 10',
          interests: [],
          avatar: '🦊',
        );
      }
      
      if (progress != null) _loadProgressFromMap(progress);
      
      // Auto-sync after login to keep both in sync
      _syncProgress();
    }
    notifyListeners();
  }

  void _clearLocalData() {
    _xp = 0;
    _streakDays = 0;
    _completedLessons.clear();
    _positions.clear();
    _badges.clear();
    _history.clear();
    _firstTryCorrect = 0;
  }

  void _loadProgressFromMap(Map<String, dynamic> data) {
    _xp = data['xp'] as int? ?? 0;
    _streakDays = data['streakDays'] as int? ?? 0;
    _completedLessons.addAll(List<String>.from(data['completedLessons'] as List? ?? []));
    _badges.addAll(List<String>.from(data['badges'] as List? ?? []));
    _firstTryCorrect = data['firstTryCorrect'] as int? ?? 0;
  }

  Map<String, dynamic> _progressToMap() => {
    'xp': _xp,
    'streakDays': _streakDays,
    'completedLessons': _completedLessons.toList(),
    'badges': _badges.toList(),
    'firstTryCorrect': _firstTryCorrect,
  };

  Future<void> _syncProgress() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final uid = firebaseUser?.uid ?? 'guest-id';
    if (_user == null) return;

    // Sync to Firebase
    if (uid != 'guest-id') {
      await _dbService.saveProgress(uid, _progressToMap());
    }

    // Sync to Docker
    final success = await _backendService.syncUser(
      uid: uid,
      name: _user!.displayName,
      email: firebaseUser?.email ?? _user!.email,
      grade: _user!.grade,
      interests: _user!.interests,
      avatar: _user!.avatar,
      xp: _xp,
      streakDays: _streakDays,
      completedLessons: _completedLessons.toList(),
      languageCode: _locale.languageCode,
      consentStatus: _user!.consent.name,
    );

    if (success) {
       _backendStatus = 'Connected\nSync Successful!';
    }
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  bool get isKhmer => _locale.languageCode == 'km';
  bool _online = true;
  bool get online => _online;
  bool _reduceMotion = false;
  bool get reduceMotion => _reduceMotion;
  bool _dailyReminder = true;
  bool get dailyReminder => _dailyReminder;

  int _xp = 0;
  int get xp => _xp;
  int _streakDays = 0;
  int get streakDays => _streakDays;

  final Set<String> _completedLessons = <String>{};
  Set<String> get completedLessons => Set<String>.unmodifiable(_completedLessons);
  final Map<String, int> _positions = <String, int>{};
  final Set<String> _badges = <String>{};
  Set<String> get earnedBadges => Set<String>.unmodifiable(_badges);
  final List<HistoryEntry> _history = <HistoryEntry>[];
  List<HistoryEntry> get history => List<HistoryEntry>.unmodifiable(_history);
  int _firstTryCorrect = 0;
  int get firstTryCorrect => _firstTryCorrect;
  int _queuedEvents = 0;
  int get queuedEvents => _queuedEvents;

  int get level => Levels.levelFor(_xp);
  String get levelTitle => Levels.titleFor(level);
  double get levelProgress => Levels.progressFor(_xp);
  int? get xpToNextLevel => Levels.remainingFor(_xp);
  int get totalLessons => Curriculum.allLessons.length;
  int get lessonsCompleted => _completedLessons.length;
  double get courseProgress => totalLessons == 0 ? 0 : _completedLessons.length / totalLessons;

  Future<void> register({required String displayName, required String email, required String password}) async {
    final cred = await _authService.register(email, password);
    if (cred?.user != null) {
      _user = UserProfile(displayName: displayName, email: email, grade: 'Grade 10', interests: const <String>[]);
      await _dbService.saveProfile(cred!.user!.uid, _user!);
      await _syncProgress();
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
  }

  void completeOnboarding({required String grade, required List<String> interests, required String avatar}) async {
    _user = _user?.copyWith(grade: grade, interests: interests, avatar: avatar);
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) await _dbService.saveProfile(uid, _user!);
    await _syncProgress();
    notifyListeners();
  }

  void updateProfile({String? displayName, String? grade, String? avatar, List<String>? interests}) async {
    _user = _user?.copyWith(displayName: displayName, grade: grade, avatar: avatar, interests: interests);
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) await _dbService.saveProfile(uid, _user!);
    await _syncProgress();
    notifyListeners();
  }

  void signOut() async {
    await _authService.signOut();
    _clearLocalData();
    _user = const UserProfile(displayName: 'Guest Learner', email: 'guest@example.com', grade: 'None', interests: [], avatar: '🦊');
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _authService.signOut();
    _clearLocalData();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) { _themeMode = mode; notifyListeners(); }
  void setLocale(Locale locale) { _locale = locale; notifyListeners(); }
  void setReduceMotion(bool value) { _reduceMotion = value; notifyListeners(); }
  void setDailyReminder(bool value) { _dailyReminder = value; notifyListeners(); }
  void setOnline(bool value) { _online = value; if (value) _queuedEvents = 0; notifyListeners(); }

  Future<void> seedDatabase() async { await _seedService.seedDatabase(); }
  bool isLessonComplete(String lessonId) => _completedLessons.contains(lessonId);
  int savedPosition(String lessonId) => _positions[lessonId] ?? 0;
  bool hasSavedPosition(String lessonId) => _positions.containsKey(lessonId) && !_completedLessons.contains(lessonId);
  void savePosition(String lessonId, int stepIndex) { _positions[lessonId] = stepIndex; if (!_online) _queuedEvents++; }
  void clearPosition(String lessonId) { _positions.remove(lessonId); }
  int completedInModule(String moduleId) {
    final m = Curriculum.moduleById(moduleId);
    return m?.lessons.where((l) => _completedLessons.contains(l.id)).length ?? 0;
  }
  bool isModuleComplete(String moduleId) {
    final m = Curriculum.moduleById(moduleId);
    return m != null && m.lessons.isNotEmpty && completedInModule(moduleId) == m.lessons.length;
  }
  double moduleProgress(String moduleId) {
    final m = Curriculum.moduleById(moduleId);
    return (m == null || m.lessons.isEmpty) ? 0 : completedInModule(moduleId) / m.lessons.length;
  }
  bool isModuleLocked(Module module) => module.requiresModuleId != null && !isModuleComplete(module.requiresModuleId!);
  String? unlockRequirement(Module module) {
    if (module.requiresModuleId == null) return null;
    final req = Curriculum.moduleById(module.requiresModuleId!);
    final done = completedInModule(module.requiresModuleId!);
    final total = req?.lessons.length ?? 0;
    return (done >= total) ? null : 'Finish ${total - done} more lessons in ${req?.title}';
  }
  Module? get currentModule {
    try { return Curriculum.modules.firstWhere((m) => !isModuleLocked(m) && !isModuleComplete(m.id)); } 
    catch (_) { return Curriculum.modules.first; }
  }
  Lesson? get nextLesson {
    try { return Curriculum.allLessons.firstWhere((l) => !_completedLessons.contains(l.id)); } 
    catch (_) { return null; }
  }
  Lesson? get resumableLesson {
    try {
      final id = _positions.keys.firstWhere((id) => !_completedLessons.contains(id));
      return Curriculum.lessonById(id);
    } catch (_) { return null; }
  }
  bool hasBadge(String id) => _badges.contains(id);
  void grantConsent() async {
    _user = _user?.copyWith(consent: ConsentStatus.granted);
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) await _dbService.saveProfile(uid, _user!);
    await _syncProgress();
    notifyListeners();
  }
  void submitGuardianEmail(String email) async {
    _user = _user?.copyWith(guardianEmail: email, consent: ConsentStatus.pending);
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) await _dbService.saveProfile(uid, _user!);
    await _syncProgress();
    notifyListeners();
  }
  LessonOutcome completeLesson(Lesson lesson, {required int attempts}) {
    final earned = _completedLessons.contains(lesson.id) ? lesson.challenge.xp : lesson.xp + lesson.challenge.xp;
    _xp += earned; _completedLessons.add(lesson.id); _positions.remove(lesson.id);
    if (attempts == 1) _firstTryCorrect++;
    _history.insert(0, HistoryEntry(lessonId: lesson.id, lessonTitle: lesson.title, moduleTitle: Curriculum.moduleOf(lesson).title, completedAt: DateTime.now(), xpEarned: earned, attempts: attempts, passed: true));
    _syncProgress();
    notifyListeners();
    return LessonOutcome(lesson: lesson, xpEarned: earned, attempts: attempts, newBadges: [], leveledUp: false, newLevel: level, queuedOffline: !_online);
  }
}
