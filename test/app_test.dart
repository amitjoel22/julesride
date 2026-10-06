import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/providers/auth_provider.dart';
import 'package:rider_app/providers/ride_provider.dart';
import 'package:rider_app/models/models.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
      ],
      child: const MyApp(),
    );
  }

  testWidgets('App smoke test, login, add group and rider, start ride, and add expense', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(createWidgetUnderTest());

    // 0. Verify Login screen is displayed and perform login
    expect(find.text('Login'), findsWidgets);
    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'testuser');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify home screen is displayed
    expect(find.text('Bike Rides'), findsOneWidget);
    expect(find.text('No rides yet. Start a new one!'), findsOneWidget);

    // 1. Add a group
    await tester.tap(find.byIcon(Icons.group));
    await tester.pumpAndSettle();

    expect(find.text('Manage Groups'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.group_add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Mountain Bikers');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Mountain Bikers'), findsOneWidget);

    // 2. Add a rider to the group
    await tester.tap(find.text('Mountain Bikers'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Rider'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);

    // Go back to home screen
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // 3. Start a new ride
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Weekend Trail');

    // Select group (we won't tap the dropdown for simplicity in widget test,
    // it will just create a ride with 'None' group if not selected,
    // but let's test if the text field works)
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Trail'), findsOneWidget);

    // 4. View Ride Details and Add Expense
    await tester.tap(find.text('Weekend Trail'));
    await tester.pumpAndSettle();

    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('Food Expenses'), findsOneWidget);

    // Add Expense
    await tester.tap(find.byIcon(Icons.attach_money));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Description (e.g., Lunch)'), 'Coffee');
    await tester.enterText(find.widgetWithText(TextField, 'Amount'), '5.50');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('\$5.50'), findsOneWidget);

    // Verify total expenses updated
    expect(find.text('Total Expenses: \$5.50'), findsOneWidget);
  });
}
