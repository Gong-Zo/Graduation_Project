/// 마이페이지 별칭·설정·콘텐츠 저장·관심 항목.
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/auth_controller.dart';
import 'package:flutter_application_1/auth/auth_models.dart';
import 'package:flutter_application_1/auth/auth_scope.dart';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:flutter_application_1/auth/auth_store.dart';
import 'package:flutter_application_1/data/rescued_dog.dart';
import 'package:flutter_application_1/mypage/member_library_store.dart';
import 'package:flutter_application_1/ui/adoption/shelter_detail_page.dart';
import 'package:flutter_application_1/ui/adoption_detail_page.dart';
import 'package:flutter_application_1/ui/mypage/favorites_page.dart';
import 'package:flutter_application_1/ui/mypage/library_scope.dart';
import 'package:flutter_application_1/ui/mypage/profile_page.dart';
import 'package:flutter_application_1/ui/mypage/saved_content_page.dart';
import 'package:flutter_application_1/ui/mypage/settings_page.dart';
import 'package:flutter_application_1/ui/preparation/education_page.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AuthController> signedIn() async {
  final auth = AuthController(
    AuthService(MemoryAuthStore(const AuthSnapshot(onboardingDone: true))),
    autoLoginTestAccount: true,
  );
  await auth.bootstrap();
  return auth;
}

Widget wrap({
  required AuthController auth,
  required MemberLibraryStore store,
  required Widget home,
}) {
  return LibraryScope(
    store: store,
    child: AuthScope(
      controller: auth,
      child: MaterialApp(home: home),
    ),
  );
}

void main() {
  testWidgets('별칭을 저장하면 다시 열어도 남아 있다', (tester) async {
    final auth = await signedIn();
    final store = MemoryMemberLibraryStore();
    await tester.pumpWidget(
      wrap(auth: auth, store: store, home: const ProfilePage()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('profileNameField')), '하민');
    await tester.tap(find.byKey(const Key('profileSaveButton')));
    await tester.pumpAndSettle();
    expect(find.text('별칭을 저장했습니다.'), findsOneWidget);

    await tester.pumpWidget(
      wrap(auth: auth, store: store, home: const ProfilePage()),
    );
    await tester.pumpAndSettle();
    expect(find.text('하민'), findsOneWidget);
    expect(find.textContaining('test@petbefore.kr'), findsOneWidget);
  });

  testWidgets('알림 스위치가 계정에 남는다', (tester) async {
    final auth = await signedIn();
    final store = MemoryMemberLibraryStore();
    await tester.pumpWidget(
      wrap(auth: auth, store: store, home: const SettingsPage()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settingsReminderSwitch')));
    await tester.pumpAndSettle();

    final saved = await store.load(auth.session!.user!.id);
    expect(saved.remindersEnabled, isTrue);
  });

  testWidgets('교육 콘텐츠를 저장하면 목록에 보인다', (tester) async {
    final auth = await signedIn();
    final store = MemoryMemberLibraryStore();
    await tester.pumpWidget(
      wrap(auth: auth, store: store, home: const EducationPage()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveContent_education')));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      wrap(auth: auth, store: store, home: const SavedContentPage()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('savedContent_education')), findsOneWidget);
  });

  testWidgets('보호동물을 관심에 넣으면 목록에 보인다', (tester) async {
    final auth = await signedIn();
    final store = MemoryMemberLibraryStore();
    const dog = RescuedDog(
      noticeNo: 'N-1',
      breedName: '믹스견',
      age: '2024',
      sex: 'M',
      processState: '보호중',
      shelterName: '서울 동물보호소',
      shelterAddress: '서울',
      imageUrl: '',
      foundDate: '20261101',
    );
    await tester.pumpWidget(
      wrap(auth: auth, store: store, home: const AdoptionDetailPage(dog: dog)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('favoriteDogButton_N-1')));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      wrap(auth: auth, store: store, home: const FavoritesPage()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('favoriteDog_N-1')), findsOneWidget);
  });

  testWidgets('보호소를 관심에 넣으면 목록에 보인다', (tester) async {
    final auth = await signedIn();
    final store = MemoryMemberLibraryStore();
    await tester.pumpWidget(
      wrap(
        auth: auth,
        store: store,
        home: const ShelterDetailPage(
          shelterName: '서울 동물보호소',
          address: '서울특별시 강남구',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('favoriteShelterButton_서울 동물보호소')));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      wrap(auth: auth, store: store, home: const FavoritesPage()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('favoriteShelter_서울 동물보호소')), findsOneWidget);
  });
}
