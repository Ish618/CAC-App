import 'package:flutter_test/flutter_test.dart';

import 'package:doc_helper/models/analysis.dart';

void main() {
  test('parses a full AI response with sources', () {
    final a = Analysis.fromJson({
      'readable': true,
      'document_type': 'Rental lease',
      'simple_summary': 'A 12-month lease.',
      'key_facts': [
        {'label': 'Rent', 'value': '\$1,450', 'source': 'pay \$1,450 per month'},
      ],
      'action_steps': [
        {'step': 'Do not sign yet', 'deadline': 'Oct 25', 'source': 'By signing below'},
        {'step': 'Keep a copy', 'deadline': null},
      ],
      'responsibilities': [
        {'text': 'Pay rent on time', 'source': 'due on the 1st'},
      ],
      'important_clauses': [
        {'text': 'Auto-renews', 'source': 'automatically renews'},
      ],
      'risk': {'level': 'medium', 'reasons': ['Auto-renewal'], 'safe_signs': ['Named landlord']},
      'before_you_sign': [
        {'text': 'You promise to pay for 12 months', 'source': '12 months'},
      ],
      'questions_to_ask': ['Can I pay in parts?'],
      'where_to_get_help': ['A trusted family member'],
    }, language: 'Hindi');

    expect(a.readable, isTrue);
    expect(a.documentType, 'Rental lease');
    expect(a.keyFacts.single.value, '\$1,450');
    expect(a.keyFacts.single.source, 'pay \$1,450 per month');
    expect(a.actionSteps[0].deadline, 'Oct 25');
    expect(a.actionSteps[0].source, 'By signing below');
    expect(a.actionSteps[1].deadline, isNull);
    expect(a.responsibilities.single.text, 'Pay rent on time');
    expect(a.importantClauses.single.source, 'automatically renews');
    expect(a.beforeYouSign.single.text, 'You promise to pay for 12 months');
    expect(a.safeSigns, ['Named landlord']);
    expect(a.riskLevel, RiskLevel.medium);
    expect(a.language, 'Hindi');
  });

  test('survives missing or malformed fields', () {
    final a = Analysis.fromJson({
      'risk': 'not an object',
      'key_facts': 'oops',
      'action_steps': [
        {'step': 'Do not sign yet', 'deadline': 'null'},
      ],
      // before_you_sign as plain strings (older/looser AI output)
      'before_you_sign': ['You give up your deposit'],
    }, language: 'English');

    expect(a.readable, isTrue);
    expect(a.keyFacts, isEmpty);
    expect(a.riskLevel, RiskLevel.low);
    expect(a.actionSteps.single.deadline, isNull);
    expect(a.beforeYouSign.single.text, 'You give up your deposit');
  });

  test('blurry photo is marked unreadable', () {
    final a = Analysis.fromJson({'readable': false}, language: 'English');
    expect(a.readable, isFalse);
  });

  test('history round-trip keeps language and risk', () {
    final original = Analysis.fromJson({
      'document_type': 'Scam letter',
      'risk': {'level': 'high', 'reasons': ['Asks for gift cards']},
      'key_facts': [
        {'label': 'Pay', 'value': 'gift cards', 'source': 'send gift cards'},
      ],
      'before_you_sign': [
        {'text': 'You lose your money', 'source': 'no refunds'},
      ],
    }, language: 'Punjabi');

    final restored = Analysis.fromJson(original.toJson(), language: 'English');
    expect(restored.language, 'Punjabi');
    expect(restored.riskLevel, RiskLevel.high);
    expect(restored.riskReasons, ['Asks for gift cards']);
    expect(restored.keyFacts.single.source, 'send gift cards');
    expect(restored.beforeYouSign.single.text, 'You lose your money');
    expect(restored.createdAt, original.createdAt);
  });
}
