import 'package:flutter_test/flutter_test.dart';
import 'package:fithabit/main.dart';

void main() {
  testWidgets('FitHabit Nhóm 12 renders main title and 5 commercial UX tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FitHabitApp());
    expect(find.text('FitHabit'), findsOneWidget);
    expect(find.text('Tổng quan'), findsOneWidget);
    expect(find.text('Sức khỏe'), findsOneWidget);
    expect(find.text('Quét AI'), findsOneWidget);
    expect(find.text('Thống kê'), findsOneWidget);
    expect(find.text('Cá nhân'), findsOneWidget);
  });
}
