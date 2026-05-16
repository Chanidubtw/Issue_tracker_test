import 'package:flutter_test/flutter_test.dart';
import 'package:issue_tracker/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns error for empty input', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('returns error for invalid email formats', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('missing@'), isNotNull);
      expect(Validators.email('@nodomain.com'), isNotNull);
      expect(Validators.email('spaces in@email.com'), isNotNull);
    });

    test('returns null for valid emails', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('user.name+tag@sub.domain.org'), isNull);
      expect(Validators.email('admin@test.io'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error for empty or null', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password(null), isNotNull);
    });

    test('returns error when shorter than 6 characters', () {
      expect(Validators.password('abc'), isNotNull);
      expect(Validators.password('12345'), isNotNull);
    });

    test('returns null for 6+ character passwords', () {
      expect(Validators.password('password'), isNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.title', () {
    test('returns error for empty title', () {
      expect(Validators.title(''), isNotNull);
      expect(Validators.title(null), isNotNull);
    });

    test('returns error when shorter than 5 characters', () {
      expect(Validators.title('bug'), isNotNull);
    });

    test('returns error when longer than 100 characters', () {
      expect(Validators.title('a' * 101), isNotNull);
    });

    test('returns null for valid title', () {
      expect(Validators.title('App crashes on startup'), isNull);
    });
  });

  group('Validators.description', () {
    test('returns error for empty description', () {
      expect(Validators.description(''), isNotNull);
      expect(Validators.description(null), isNotNull);
    });

    test('returns error when shorter than 10 characters', () {
      expect(Validators.description('short'), isNotNull);
    });

    test('returns null for valid description', () {
      expect(Validators.description('This is a valid description.'), isNull);
    });
  });
}
