import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakwave/core/support/support_contact.dart';
import 'package:breakwave/core/support/support_contact_masking.dart';
import 'package:breakwave/core/support/support_contact_store.dart';
import 'package:breakwave/features/support/presentation/widgets/support_contact_card.dart';
import 'package:breakwave/features/support/presentation/widgets/trusted_accountability_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'phone masking preserves formatting and reveals only last four digits',
    () {
      expect(
        SupportContactMasking.phone('(864) 555-1212'),
        '(•••) •••-1212',
      );
      expect(
        SupportContactMasking.phone('+1 864 555 1212'),
        '+• ••• ••• 1212',
      );
    },
  );

  test(
    'email masking hides the local part and preserves the domain',
    () {
      expect(
        SupportContactMasking.email('alex@example.com'),
        'a•••@example.com',
      );
      expect(
        SupportContactMasking.email('a@example.com'),
        '•@example.com',
      );
    },
  );

  testWidgets(
    'trusted contact details are masked until deliberately revealed',
    (WidgetTester tester) async {
      await SupportContactStore.saveContact(
        const SupportContact(
          name: 'Alex',
          phoneNumber: '(864) 555-1212',
          emailAddress: 'alex@example.com',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TrustedAccountabilityCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Phone: (•••) •••-1212'), findsOneWidget);
      expect(find.text('Email: a•••@example.com'), findsOneWidget);
      expect(find.text('Phone: (864) 555-1212'), findsNothing);
      expect(find.text('Email: alex@example.com'), findsNothing);
      expect(find.text('Show details'), findsOneWidget);
      expect(find.text('Text trusted contact'), findsOneWidget);
      expect(find.text('Email trusted contact'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('trusted-contact-detail-toggle')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Phone: (864) 555-1212'), findsOneWidget);
      expect(find.text('Email: alex@example.com'), findsOneWidget);
      expect(find.text('Hide details'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('trusted-contact-detail-toggle')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Phone: (•••) •••-1212'), findsOneWidget);
      expect(find.text('Email: a•••@example.com'), findsOneWidget);
    },
  );

  testWidgets(
    'saved contact editor stays masked until edit is deliberately opened',
    (WidgetTester tester) async {
      await SupportContactStore.saveContact(
        const SupportContact(
          name: 'Alex',
          phoneNumber: '8005551212',
          emailAddress: 'alex@email.me',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SupportContactCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('trusted-contact-masked-summary')),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Phone: ••••••1212'), findsOneWidget);
      expect(find.text('Email: a•••@email.me'), findsOneWidget);
      expect(find.text('8005551212'), findsNothing);
      expect(find.text('alex@email.me'), findsNothing);

      await tester.tap(
        find.byKey(const Key('trusted-contact-edit-details')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(3));
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('trusted-contact-phone-field')),
            )
            .controller!
            .text,
        '8005551212',
      );
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('trusted-contact-email-field')),
            )
            .controller!
            .text,
        'alex@email.me',
      );
      expect(
        find.textContaining('visible while you edit'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('trusted-contact-cancel-editing')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Phone: ••••••1212'), findsOneWidget);
      expect(find.text('Email: a•••@email.me'), findsOneWidget);
    },
  );
}
