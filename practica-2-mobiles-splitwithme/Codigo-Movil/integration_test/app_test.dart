import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'package:splitwithfriends/main.dart';
import 'package:splitwithfriends/models.dart';
import 'package:splitwithfriends/services.dart';
import 'package:splitwithfriends/repositories.dart';
import 'package:splitwithfriends/expenses_viewmodel.dart';

// Generación de mocks con null-safety
@GenerateMocks(<Type>[SplitWithMeService])
import 'app_test.mocks.dart';

// Construye el árbol de providers igual que en main(), pero inyectando el mock
Widget _buildTestApp(SplitWithMeService mockService) {
  return MultiProvider(
    providers: [
      Provider<SplitWithMeService>.value(value: mockService),

      Provider<FriendRepository>(
        create: (context) =>
            FriendRepository(service: context.read<SplitWithMeService>()),
      ),
      Provider<ExpenseRepository>(
        create: (context) =>
            ExpenseRepository(service: context.read<SplitWithMeService>()),
      ),

      ChangeNotifierProvider<ExpensesViewModel>(
        create: (context) =>
            ExpensesViewModel(expenseRepository: context.read<ExpenseRepository>()),
      ),
    ],
    child: const MyApp(),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSplitWithMeService mockService;

  // Datos de prueba comunes
  final friends = <Friend>[
    Friend(id: 1, name: 'Mock 1', creditBalance: 0, debitBalance: 0),
    Friend(id: 2, name: 'Mock 2', creditBalance: 200, debitBalance: 150),
    Friend(id: 3, name: 'Mock 3', creditBalance: 300, debitBalance: 250),
    Friend(id: 4, name: 'Mock 4', creditBalance: 400, debitBalance: 350),
    Friend(id: 5, name: 'Mock 5', creditBalance: 500, debitBalance: 450),
  ];

  final expensesForFriend2 = <Expense>[
    Expense(
      id: 10,
      description: 'Dinner with Mock 2',
      date: '2024-01-01',
      amount: 50.0,
      numFriends: 2,
      participants: const [2],
    ),
    Expense(
      id: 11,
      description: 'Cinema',
      date: '2024-02-01',
      amount: 20.0,
      numFriends: 2,
      participants: const [2],
    ),
  ];

  setUp(() {
    mockService = MockSplitWithMeService();

    when(mockService.fetchFriends()).thenAnswer((_) async => friends);

    // ExpensesViewModel carga todos los gastos al arrancar
    when(mockService.listExpenses()).thenAnswer((_) async => expensesForFriend2);

    when(mockService.listFriendExpenses(2))
        .thenAnswer((_) async => expensesForFriend2);

    when(mockService.listExpenseFriends(any)).thenAnswer((invocation) async {
      final id = invocation.positionalArguments[0] as int;
      if (id == 10 || id == 11) {
        return <Friend>[friends[1]]; // solo Mock 2
      }
      return <Friend>[];
    });

    when(mockService.updateFriendCredit(any, any, any))
        .thenAnswer((_) async => {});
  });

  group('end-to-end Friends', () {
    testWidgets('carga la lista inicial de amigos', (tester) async {
      await tester.pumpWidget(_buildTestApp(mockService));
      await tester.pumpAndSettle();

      final friendsButton = find.widgetWithText(ElevatedButton, 'Friends');
      expect(friendsButton, findsOneWidget);
      await tester.tap(friendsButton);
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsNWidgets(friends.length));
      expect(find.text('Mock 1'), findsOneWidget);
      expect(find.text('Mock 5'), findsOneWidget);
    });

    testWidgets('carga el detalle de un amigo', (tester) async {
      await tester.pumpWidget(_buildTestApp(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Friends'));
      await tester.pumpAndSettle();

      final friendRow = find.byKey(const ValueKey('friend-2'));
      expect(friendRow, findsOneWidget);

      final inkWell = find.descendant(
        of: friendRow,
        matching: find.byType(InkWell),
      ).first;
      await tester.tap(inkWell);
      await tester.pumpAndSettle();

      expect(find.text('Credit: 200.00€'), findsOneWidget);
      expect(find.text('Debit: 150.00€'), findsOneWidget);
      expect(find.text('10 - Dinner with Mock 2'), findsOneWidget);
      expect(find.text('11 - Cinema'), findsOneWidget);
    });

    testWidgets('muestra mensaje de error si falla la carga de amigos',
            (tester) async {
          when(mockService.fetchFriends())
              .thenThrow(ServerException('Service is not available'));

          await tester.pumpWidget(_buildTestApp(mockService));
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithText(ElevatedButton, 'Friends'));
          await tester.pumpAndSettle();

          expect(find.text('Cannot retrieve the list of friends'), findsOneWidget);
        });

    testWidgets('flujo completo: Friends + Expenses con update credit',
            (tester) async {
          await tester.pumpWidget(_buildTestApp(mockService));
          await tester.pumpAndSettle();

          // Home: comprobamos que están los botones principales por texto
          expect(find.text('Friends'), findsOneWidget);
          expect(find.text('Expenses'), findsOneWidget);
          expect(find.text('+ Create an expense'), findsOneWidget);

          // --- Friends ---
          await tester.tap(find.text('Friends'));
          await tester.pumpAndSettle();

          expect(find.byType(CircleAvatar), findsNWidgets(friends.length));
          expect(find.text('Mock 2'), findsOneWidget);

          final friendRow = find.byKey(const ValueKey('friend-2'));
          final inkWell = find.descendant(
            of: friendRow,
            matching: find.byType(InkWell),
          ).first;
          await tester.tap(inkWell);
          await tester.pumpAndSettle();

          expect(find.text('Credit: 200.00€'), findsOneWidget);
          expect(find.text('Debit: 150.00€'), findsOneWidget);
          expect(find.text('10 - Dinner with Mock 2'), findsOneWidget);
          expect(find.text('11 - Cinema'), findsOneWidget);

          // Volver a Home usando el botón "Back" del AppBar de Friends
          await tester.tap(find.byTooltip('Back'));
          await tester.pumpAndSettle();

          // Ahora estamos de nuevo en Home
          expect(find.text('Expenses'), findsOneWidget);

          // --- Expenses ---
          await tester.tap(find.text('Expenses'));
          await tester.pumpAndSettle();

          expect(find.text('10 - Dinner with Mock 2'), findsOneWidget);
          expect(find.text('11 - Cinema'), findsOneWidget);

          final expenseTile =
          find.widgetWithText(ListTile, '10 - Dinner with Mock 2');
          await tester.tap(expenseTile);
          await tester.pumpAndSettle();

          expect(find.text('Dinner with Mock 2'), findsOneWidget);
          expect(
            find.text('2024-01-01  50.00€  •  2 friends'),
            findsOneWidget,
          );

          await tester.pumpAndSettle();
          expect(find.text('Participants:'), findsOneWidget);
          expect(find.text('2 - Mock 2'), findsOneWidget);

          final participantTile =
          find.widgetWithText(ListTile, '2 - Mock 2');
          final updateButton = find.descendant(
            of: participantTile,
            matching: find.byIcon(Icons.attach_money),
          );
          await tester.tap(updateButton);
          await tester.pumpAndSettle();

          final amountField = find.byType(TextFormField);
          await tester.enterText(amountField, '12.5');
          await tester.tap(find.widgetWithText(ElevatedButton, 'Update'));
          await tester.pumpAndSettle();

          expect(
            find.text('Updated Mock 2 credit by 12.50€'),
            findsOneWidget,
          );

          verify(mockService.updateFriendCredit(10, 2, 12.5)).called(1);
        });
  });
}
