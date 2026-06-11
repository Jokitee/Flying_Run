import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flying_run/main.dart';
import 'package:flying_run/models/app_state.dart';

void main() {
  testWidgets('App loads dashboard test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>(
        create: (context) {
          final state = AppState();
          state.login(); // bypass login screen for test
          return state;
        },
        child: const FlyingRunApp(),
      ),
    );

    // Verify that the welcome subtitle exists.
    expect(find.text('健康与陪伴，与你同行'), findsOneWidget);
  });
}
