import 'package:flutter/material.dart';

import '../models/content.dart';
import '../models/gamification.dart';

/// The seeded curriculum.
abstract final class Curriculum {
  static const List<Module> modules = <Module>[
    _firstProgram,
    _variables,
    _decisions,
    _loops,
    _firstApp,
  ];

  static Module? moduleById(String id) {
    for (final Module m in modules) {
      if (m.id == id) return m;
    }
    return null;
  }

  static Lesson? lessonById(String id) {
    for (final Module m in modules) {
      for (final Lesson l in m.lessons) {
        if (l.id == id) return l;
      }
    }
    return null;
  }

  static Module moduleOf(Lesson lesson) => moduleById(lesson.moduleId)!;

  static List<Lesson> get allLessons =>
      <Lesson>[for (final Module m in modules) ...m.lessons];

  // ---------------------------------------------------------------------
  // Module 1 — Your First Program
  // ---------------------------------------------------------------------

  static const Module _firstProgram = Module(
    id: 'm1',
    title: 'Your First Program',
    titleKm: 'កម្មវិធីដំបូងរបស់អ្នក',
    description:
        'Write and run real code on your phone. By the end of this module '
        'you will have a working program you can show a friend.',
    descriptionKm: 'សរសេរ និងដំណើរការកូដពិតប្រាកដនៅលើទូរសព្ទរបស់អ្នក។ នៅចុងបញ្ចប់នៃម៉ូឌុលនេះ អ្នកនឹងមានកម្មវិធីដំណើរការមួយដែលអាចបង្ហាញមិត្តភក្តិបាន។',
    icon: Icons.rocket_launch_rounded,
    lessons: <Lesson>[
      Lesson(
        id: 'm1l1',
        moduleId: 'm1',
        title: 'What Is Code?',
        titleKm: 'តើកូដជាអ្វី?',
        summary: 'Why a computer needs instructions, and what a program is.',
        summaryKm: 'ហេតុអ្វីបានជាកុំព្យូទ័រត្រូវការការណែនាំ និងអ្វីទៅជាកម្មវិធី។',
        minutes: 8,
        steps: <LessonStep>[
          LessonStep(
            kind: StepKind.text,
            title: 'A computer follows instructions',
            titleKm: 'កុំព្យូទ័រធ្វើតាមការណែនាំ',
            body:
                'A computer cannot guess what you want. It does exactly what '
                'it is told, in the exact order it is told, every single time.\n\n'
                'Code is how you write those instructions down. A program is '
                'just a list of them.',
            bodyKm:
                'កុំព្យូទ័រមិនអាចទាយបានថាអ្នកចង់បានអ្វីទេ។ វាធ្វើតាមអ្វីដែលអ្នកប្រាប់ '
                'ជាលំដាប់ត្រឹមត្រូវ រាល់ពេលវេលា។\n\n'
                'កូដគឺជាវិធីដែលអ្នកសរសេរការណែនាំទាំងនោះ។ កម្មវិធីគ្រាន់តែជាបញ្ជីនៃពួកវាប៉ុណ្ណោះ។',
          ),
          LessonStep(
            kind: StepKind.text,
            title: 'Recipes and programs',
            titleKm: 'រូបមន្ត និងកម្មវិធី',
            body:
                'Think of a recipe. "Boil water. Add rice. Wait 15 minutes."\n\n'
                'Swap the order and you get something else entirely. Code works '
                'the same way — order matters, and every step has to be spelled out.',
            bodyKm: 'គិតអំពីរបៀបធ្វើម្ហូប "ដាំទឹក។ ដាក់អង្ករ។ ចាំ ១៥ នាទី។"\n\nផ្លាស់ប្តូរលំដាប់ ហើយអ្នកនឹងទទួលបានអ្វីផ្សេងទាំងស្រុង។ កូដដំណើរការតាមរបៀបដូចគ្នា - លំដាប់មានសារៈសំខាន់ ហើយរាល់ជំហានត្រូវតែបញ្ជាក់ឱ្យច្បាស់។',
          ),
          LessonStep(
            kind: StepKind.code,
            title: 'This is a program',
            titleKm: 'នេះគឺជាកម្មវិធី',
            body: 'print("Hello, world!")',
            bodyKm: 'print("សួស្តីពិភពលោក!")',
          ),
        ],
        challenge: Challenge(
          kind: ChallengeKind.multipleChoice,
          prompt: 'What is a program?',
          promptKm: 'តើកម្មវិធីគឺជាអ្វី?',
          options: <String>[
            'A list of instructions a computer follows in order',
            'A picture stored on a phone',
          ],
          optionsKm: <String>[
            'បញ្ជីនៃការណែនាំដែលកុំព្យូទ័រធ្វើតាមជាលំដាប់',
            'រូបភាពដែលបានរក្សាទុកក្នុងទូរសព្ទ',
          ],
          answer: 'A list of instructions a computer follows in order',
          hint: 'Think about the recipe.',
          hintKm: 'គិតអំពីរបៀបធ្វើម្ហូប។',
        ),
      ),
      Lesson(
        id: 'm1l2',
        moduleId: 'm1',
        title: 'Your First Output',
        titleKm: 'លទ្ធផលដំបូងរបស់អ្នក',
        summary: 'Use print() to make the computer say something back.',
        summaryKm: 'ប្រើ print() ដើម្បីធ្វើឱ្យកុំព្យូទ័រនិយាយអ្វីមកវិញ។',
        minutes: 10,
        steps: <LessonStep>[
          LessonStep(
            kind: StepKind.text,
            title: 'Making the computer talk',
            titleKm: 'ធ្វើឱ្យកុំព្យូទ័រនិយាយ',
            body: 'print() is how your program shows something to a person.',
            bodyKm: 'print() គឺជាវិធីដែលកម្មវិធីរបស់អ្នកបង្ហាញអ្វីមួយដល់មនុស្ស។',
          ),
          LessonStep(
            kind: StepKind.code,
            title: 'Text goes in quotes',
            titleKm: 'អត្ថបទត្រូវនៅក្នុងសញ្ញាសម្រង់',
            body: 'print("Good morning")',
            bodyKm: 'print("អរុណសួស្តី")',
          ),
        ],
        challenge: Challenge(
          kind: ChallengeKind.fillBlank,
          prompt: 'Complete the line so the program displays Cambodia.',
          promptKm: 'បំពេញបន្ទាត់ដើម្បីឱ្យកម្មវិធីបង្ហាញពាក្យ Cambodia។',
          code: '_____("Cambodia")',
          answer: 'print',
          hint: 'It is the instruction that shows text.',
          hintKm: 'វាគឺជាការណែនាំដែលបង្ហាញអត្ថបទ។',
        ),
      ),
      Lesson(
        id: 'm1l3',
        moduleId: 'm1',
        title: 'When Code Breaks',
        titleKm: 'ពេលកូដមានបញ្ហា',
        summary: 'Read an error message instead of panicking at it.',
        summaryKm: 'អានសារកំហុសជំនួសឱ្យការភ័យស្លន់ស្លោ។',
        minutes: 9,
        steps: [
          LessonStep(
            kind: StepKind.text,
            title: 'Errors are normal',
            titleKm: 'កំហុសជារឿងធម្មតា',
            body: 'Every programmer writes broken code. An error is not a failure.',
            bodyKm: 'អ្នកសរសេរកម្មវិធីគ្រប់រូបសរសេរកូដដែលមានកំហុស។ កំហុសមិនមែនជាការបរាជ័យទេ។',
          )
        ],
        challenge: Challenge(
          kind: ChallengeKind.multipleChoice,
          prompt: 'What is a SyntaxError?',
          promptKm: 'តើ SyntaxError គឺជាអ្វី?',
          options: ['A typo in the code', 'A broken phone screen'],
          optionsKm: ['ការវាយខុសក្នុងកូដ', 'អេក្រង់ទូរសព្ទខូច'],
          answer: 'A typo in the code',
          hint: 'Think about spelling.',
          hintKm: 'គិតអំពីការប្រកប។',
        )
      ),
      Lesson(
        id: 'm1l4',
        moduleId: 'm1',
        title: 'Build: Greeting Card',
        titleKm: 'សាងសង់៖ កាតជូនពរ',
        summary: 'Put it together into a program.',
        summaryKm: 'ដាក់វាបញ្ចូលគ្នាទៅក្នុងកម្មវិធីមួយ។',
        minutes: 12,
        xp: 50,
        steps: [
          LessonStep(
            kind: StepKind.code,
            title: 'The card',
            titleKm: 'កាត',
            body: 'print("Happy Birthday")',
            bodyKm: 'print("រីករាយថ្ងៃកំណើត")',
          )
        ],
        challenge: Challenge(
          kind: ChallengeKind.predictOutput,
          prompt: 'How many lines?',
          promptKm: 'តើមានប៉ុន្មានបន្ទាត់?',
          code: 'print("A")\nprint("B")',
          answer: '2',
          hint: 'Count the prints.',
          hintKm: 'រាប់ចំនួន print។',
        )
      )
    ],
  );

  static const Module _variables = Module(
    id: 'm2',
    title: 'Variables & Data',
    titleKm: 'អថេរ និងទិន្នន័យ',
    description: 'Store information and reuse it.',
    descriptionKm: 'រក្សាទុកព័ត៌មាន និងប្រើប្រាស់វាឡើងវិញ។',
    icon: Icons.inventory_2_rounded,
    requiresModuleId: 'm1',
    lessons: [],
  );
  
  static const Module _decisions = Module(
    id: 'm3',
    title: 'Making Decisions',
    titleKm: 'ការសម្រេចចិត្ត',
    description: 'Choose between different paths.',
    descriptionKm: 'ជ្រើសរើសរវាងផ្លូវផ្សេងៗគ្នា។',
    icon: Icons.alt_route_rounded,
    requiresModuleId: 'm2',
    lessons: [],
  );

  static const Module _loops = Module(
    id: 'm4',
    title: 'Loops',
    titleKm: 'រង្វិលជុំ',
    description: 'Repeat actions efficiently.',
    descriptionKm: 'ធ្វើសកម្មភាពម្តងទៀតឱ្យមានប្រសិទ្ធភាព។',
    icon: Icons.repeat_rounded,
    requiresModuleId: 'm3',
    lessons: [],
  );

  static const Module _firstApp = Module(
    id: 'm5',
    title: 'First App',
    titleKm: 'កម្មវិធីដំបូង',
    description: 'Build your first real app.',
    descriptionKm: 'បង្កើតកម្មវិធីពិតប្រាកដដំបូងរបស់អ្នក។',
    icon: Icons.phone_iphone_rounded,
    requiresModuleId: 'm4',
    lessons: [],
  );
}

abstract final class Badges {
  static const List<BadgeDef> all = <BadgeDef>[
    BadgeDef(id: 'first-steps', name: 'First Steps', description: 'Finished first lesson.', icon: Icons.directions_walk_rounded, requirement: '1 lesson'),
  ];
  static BadgeDef byId(String id) => all.firstWhere((b) => b.id == id);
}

abstract final class Interests {
  static const List<(String, IconData)> all = <(String, IconData)>[
    ('Mobile apps', Icons.phone_iphone_rounded),
    ('Games', Icons.sports_esports_rounded),
  ];
}

abstract final class Grades {
  static const List<String> all = <String>['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12', 'University'];
}
