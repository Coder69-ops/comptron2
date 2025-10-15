import 'package:flutter_test/flutter_test.dart';
import 'package:comptron/core/models/registration.dart';

void main() {
  group('Registration Email Validation', () {
    test('should validate correct @nwu.ac.bd email format', () {
      const validEmails = [
        'ID(20232002010)@nwu.ac.bd',
        'ID(20231234567)@nwu.ac.bd',
        'ID(20240001001)@nwu.ac.bd',
      ];

      for (final email in validEmails) {
        expect(
          Registration.isValidNwuEmail(email),
          true,
          reason: '$email should be valid',
        );
      }
    });

    test('should reject invalid @nwu.ac.bd email formats', () {
      const invalidEmails = [
        'invalid@nwu.ac.bd',
        'ID20232002010@nwu.ac.bd', // Missing parentheses
        'ID(2023-2002-010)@nwu.ac.bd', // Contains hyphens
        'ID(abc)@nwu.ac.bd', // Contains letters
        'ID(20232002010)@gmail.com', // Wrong domain
        'ID(20232002010)@nwu.edu.bd', // Wrong domain
      ];

      for (final email in invalidEmails) {
        expect(
          Registration.isValidNwuEmail(email),
          false,
          reason: '$email should be invalid',
        );
      }
    });

    test('should extract student ID correctly', () {
      const testCases = {
        'ID(20232002010)@nwu.ac.bd': '20232002010',
        'ID(20241234567)@nwu.ac.bd': '20241234567',
        'ID(20200001001)@nwu.ac.bd': '20200001001',
      };

      testCases.forEach((email, expectedId) {
        final extractedId = Registration.extractStudentId(email);
        expect(
          extractedId,
          expectedId,
          reason: 'Should extract $expectedId from $email',
        );
      });
    });

    test('should return empty string for invalid email formats', () {
      const invalidEmails = [
        'invalid@nwu.ac.bd',
        'notanemail',
        'ID20232002010@nwu.ac.bd',
        'test@gmail.com',
      ];

      for (final email in invalidEmails) {
        final extractedId = Registration.extractStudentId(email);
        expect(
          extractedId,
          '',
          reason: 'Should return empty string for $email',
        );
      }
    });
  });
}
