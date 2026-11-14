import 'package:supabase_flutter/supabase_flutter.dart';

class LegalAcceptanceService {
  static const String termsVersion = '1.0';
  static const String privacyVersion = '1.0';

  static Future<bool> hasCurrentAcceptance() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) return false;

    final existing = await client
        .from('legal_acceptances')
        .select('id')
        .eq('user_id', user.id)
        .eq('terms_version', termsVersion)
        .eq('privacy_version', privacyVersion)
        .maybeSingle();

    if (existing != null) return true;

    final metadata = user.userMetadata ?? {};

    final acceptedTerms = metadata['terms_version']?.toString();
    final acceptedPrivacy = metadata['privacy_version']?.toString();
    final acceptedAt = metadata['legal_accepted_at']?.toString();

    if (acceptedTerms != termsVersion ||
        acceptedPrivacy != privacyVersion ||
        acceptedAt == null) {
      return false;
    }

    final parsedDate = DateTime.tryParse(acceptedAt);

    if (parsedDate == null) return false;

    await client.from('legal_acceptances').insert({
      'user_id': user.id,
      'terms_version': termsVersion,
      'privacy_version': privacyVersion,
      'accepted_at': parsedDate.toUtc().toIso8601String(),
    });

    return true;
  }

  static Future<void> registerCurrentAcceptance() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      throw StateError('Usuário não autenticado.');
    }

    final acceptedAt = DateTime.now().toUtc();

    await client.auth.updateUser(
      UserAttributes(
        data: {
          'terms_version': termsVersion,
          'privacy_version': privacyVersion,
          'legal_accepted_at': acceptedAt.toIso8601String(),
        },
      ),
    );

    await client.from('legal_acceptances').insert({
      'user_id': user.id,
      'terms_version': termsVersion,
      'privacy_version': privacyVersion,
      'accepted_at': acceptedAt.toIso8601String(),
    });
  }
}
