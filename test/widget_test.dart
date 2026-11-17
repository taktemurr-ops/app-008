import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogun_360/main.dart';
import 'package:ogun_360/meal_repository.dart';

class TestStorage implements MealStorage {
  String? value;
  @override Future<String?> read() async => value;
  @override Future<void> write(String data) async { value = data; }
  @override Future<void> clear() async { value = null; }
}

void main() {
  testWidgets('five primary sections render and can be selected', (tester) async {
    await tester.pumpWidget(Ogun360App(storage: TestStorage()));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    await tester.tap(find.byIcon(Icons.restaurant).first);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings).last);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.file_download), findsOneWidget);
  });
}
