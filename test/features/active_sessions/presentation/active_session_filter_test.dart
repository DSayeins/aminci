import 'package:flutter_test/flutter_test.dart';

import 'package:aminci/core/models/active_session.dart';
import 'package:aminci/features/active_sessions/presentation/active_session_filter.dart';

const _a = ActiveSession(mikrotikId: '*1', code: 'A', profileName: '1h-500');
const _b = ActiveSession(mikrotikId: '*2', code: 'B', profileName: '1j-2000');
const _c = ActiveSession(mikrotikId: '*3', code: 'C', profileName: '1h-500');
const _unknown = ActiveSession(mikrotikId: '*4', code: 'WINBOX');

void main() {
  group('filterSessions', () {
    test('Tous garde toutes les sessions', () {
      expect(filterSessions([_a, _b, _unknown], const AllProfiles()), [_a, _b, _unknown]);
    });

    test('un profil ne garde que ses sessions', () {
      expect(filterSessions([_a, _b, _c, _unknown], const NamedProfile('1h-500')), [_a, _c]);
    });

    test('Inconnu ne garde que les sessions sans profil', () {
      expect(filterSessions([_a, _unknown, _b], const UnknownProfile()), [_unknown]);
    });
  });

  group('profileFilterOptions', () {
    test('Tous, puis les profils distincts triés, puis Inconnu', () {
      expect(profileFilterOptions([_b, _unknown, _a, _c], const AllProfiles()), const [
        AllProfiles(),
        NamedProfile('1h-500'),
        NamedProfile('1j-2000'),
        UnknownProfile(),
      ]);
    });

    test("pas d'Inconnu si tous les profils sont connus", () {
      expect(profileFilterOptions([_a, _b], const AllProfiles()), const [
        AllProfiles(),
        NamedProfile('1h-500'),
        NamedProfile('1j-2000'),
      ]);
    });

    test('garde le profil sélectionné même sans session', () {
      expect(profileFilterOptions([_b], const NamedProfile('1h-500')), const [
        AllProfiles(),
        NamedProfile('1h-500'),
        NamedProfile('1j-2000'),
      ]);
    });
  });
}
