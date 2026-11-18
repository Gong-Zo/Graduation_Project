import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/adoption/adoption_education_page.dart';
import 'package:flutter_application_1/ui/adoption/adoption_info_page.dart';
import 'package:flutter_application_1/ui/adoption/adoption_process_page.dart';
import 'package:flutter_application_1/ui/adoption/shelter_detail_page.dart';
import 'package:flutter_application_1/ui/adoption/shelter_list_page.dart';
import 'package:flutter_application_1/ui/diagnosis/diagnosis_detail_page.dart';
import 'package:flutter_application_1/ui/diagnosis/survey_intro_page.dart';
import 'package:flutter_application_1/ui/mypage/diagnosis_history_page.dart';
import 'package:flutter_application_1/ui/mypage/favorites_page.dart';
import 'package:flutter_application_1/ui/mypage/mypage.dart';
import 'package:flutter_application_1/ui/mypage/profile_page.dart';
import 'package:flutter_application_1/ui/mypage/saved_content_page.dart';
import 'package:flutter_application_1/ui/mypage/settings_page.dart';
import 'package:flutter_application_1/ui/preparation/breed_info_page.dart';
import 'package:flutter_application_1/ui/preparation/care_checklist_page.dart';
import 'package:flutter_application_1/ui/preparation/education_page.dart';
import 'package:flutter_application_1/ui/preparation/preparation_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('신규 페이지 17개가 기본 상태에서 렌더링된다', (tester) async {
    final pages = <Widget>[
      const SurveyIntroPage(),
      const DiagnosisDetailPage(),
      const PreparationPage(),
      const EducationPage(),
      const CareChecklistPage(),
      const BreedInfoPage(),
      const AdoptionInfoPage(),
      const AdoptionEducationPage(),
      const ShelterListPage(),
      const ShelterDetailPage(),
      const AdoptionProcessPage(),
      const MyPage(),
      const ProfilePage(),
      const DiagnosisHistoryPage(),
      const SavedContentPage(),
      const FavoritesPage(),
      const SettingsPage(),
    ];

    for (final page in pages) {
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
