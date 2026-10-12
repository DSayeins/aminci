import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/features/active_sessions/presentation/active_session_filter.dart';

/// Puces de filtre des sessions actives par profil de voucher.
class ActiveSessionFilterBar extends StatelessWidget {
  final List<ProfileFilter> options;
  final ProfileFilter selected;
  final ValueChanged<ProfileFilter> onChanged;

  const ActiveSessionFilterBar({super.key, required this.options, required this.selected, required this.onChanged});

  static String _label(ProfileFilter filter) => switch (filter) {
    AllProfiles() => 'Tous',
    UnknownProfile() => 'Inconnu',
    NamedProfile(:final name) => name,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.paddingLg, AppSpacing.paddingMd, AppSpacing.paddingLg, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: AppSpacing.gapSm,
          runSpacing: AppSpacing.gapSm,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(_label(option)),
                selected: option == selected,
                onSelected: (_) => onChanged(option),
              ),
          ],
        ),
      ),
    );
  }
}
