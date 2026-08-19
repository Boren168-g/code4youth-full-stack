import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../data/curriculum.dart';
import '../../models/user.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/text_field.dart';

/// Edit the account.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const List<String> _avatars = <String>[
    '🦊', '🐼', '🦉', '🐯', '🐸', '🐧', '狮', '🐨', '🦄', '🐙', '🐝', '🦖',
  ];

  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late String _grade;
  late String _avatar;
  late Set<String> _interests;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final UserProfile user = context.read<AppState>().user!;
    _name = TextEditingController(text: user.displayName);
    _grade = user.grade;
    _avatar = user.avatar;
    _interests = user.interests.toSet();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    context.read<AppState>().updateProfile(
      displayName: _name.text.trim(),
      grade: _grade,
      avatar: _avatar,
      interests: _interests.toList(),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.profileUpdated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        leading: C4YIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: l10n.goBack,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.editProfile),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, Space.xl),
              children: <Widget>[
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: context.primarySubtle,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.primary, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(_avatar, style: const TextStyle(fontSize: 46)),
                  ),
                ),
                const SizedBox(height: Space.lg),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _avatars.length,
                    separatorBuilder: (_, _) => const SizedBox(width: Space.sm),
                    itemBuilder: (BuildContext context, int i) {
                      final String avatar = _avatars[i];
                      final bool selected = avatar == _avatar;
                      return Semantics(
                        button: true,
                        selected: selected,
                        label: 'Avatar ${i + 1}',
                        child: Material(
                          color: selected ? context.primarySubtle : context.surface,
                          shape: CircleBorder(
                            side: BorderSide(color: selected ? context.primary : context.divider, width: selected ? 2 : 1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => setState(() => _avatar = avatar),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: Center(child: Text(avatar, style: const TextStyle(fontSize: 26))),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: Space.xl),

                Form(
                  key: _form,
                  child: C4YTextField(
                    label: l10n.displayName,
                    controller: _name,
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    validator: Validators.displayName,
                  ),
                ),
                const SizedBox(height: Space.xl),

                Text(l10n.grade, style: AppType.captionStrong.copyWith(color: context.textPrimary)),
                const SizedBox(height: Space.md),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: <Widget>[
                    for (final String grade in Grades.all)
                      SelectableChip(
                        label: grade,
                        selected: _grade == grade,
                        onTap: () => setState(() => _grade = grade),
                      ),
                  ],
                ),
                const SizedBox(height: Space.xl),

                Text(l10n.interestsTitle, style: AppType.captionStrong.copyWith(color: context.textPrimary)),
                const SizedBox(height: Space.md),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: <Widget>[
                    for (final (String label, IconData icon) in Interests.all)
                      SelectableChip(
                        label: label,
                        icon: icon,
                        selected: _interests.contains(label),
                        onTap: () => setState(() {
                          if (!_interests.remove(label)) _interests.add(label);
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, Space.lg + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(color: context.surface, border: Border(top: BorderSide(color: context.divider))),
            child: C4YButton.primary(
              label: l10n.saveChanges,
              loading: _saving,
              onPressed: () => _save(l10n),
            ),
          ),
        ],
      ),
    );
  }
}
