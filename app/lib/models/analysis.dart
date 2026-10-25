// The "data contract" between the backend and the app.
// Mirrors the JSON schema in api/analyze.js.

enum RiskLevel { low, medium, high }

class KeyFact {
  final String label;
  final String value;
  final String source; // exact quote from the document ('' if none)
  const KeyFact(this.label, this.value, {this.source = ''});

  factory KeyFact.fromJson(Map<String, dynamic> j) =>
      KeyFact(_str(j['label']), _str(j['value']), source: _str(j['source']));

  Map<String, dynamic> toJson() => {'label': label, 'value': value, 'source': source};
}

class ActionStep {
  final String step;
  final String? deadline;
  final String source;
  const ActionStep(this.step, this.deadline, {this.source = ''});

  factory ActionStep.fromJson(Map<String, dynamic> j) {
    final d = j['deadline'];
    final deadline = (d is String && d.trim().isNotEmpty && d.toLowerCase() != 'null')
        ? d.trim()
        : null;
    return ActionStep(_str(j['step']), deadline, source: _str(j['source']));
  }

  Map<String, dynamic> toJson() => {'step': step, 'deadline': deadline, 'source': source};
}

/// A plain-language item plus the exact words from the document it came from.
class Sourced {
  final String text;
  final String source;
  const Sourced(this.text, {this.source = ''});

  factory Sourced.fromJson(Map<String, dynamic> j) =>
      Sourced(_str(j['text']), source: _str(j['source']));

  Map<String, dynamic> toJson() => {'text': text, 'source': source};
}

/// One question + answer for the "Explain Like I'm 70" screen.
class QA {
  final String question;
  final String answer;
  const QA(this.question, this.answer);

  factory QA.fromJson(Map<String, dynamic> j) => QA(_str(j['question']), _str(j['answer']));

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
}

class Analysis {
  final bool readable;
  final String documentType;
  final String simpleSummary;
  final List<KeyFact> keyFacts;
  final List<ActionStep> actionSteps;
  final List<Sourced> responsibilities;
  final List<Sourced> importantClauses;
  final RiskLevel riskLevel;
  final List<String> riskReasons;
  final List<String> safeSigns;
  final List<Sourced> beforeYouSign;
  final List<String> questionsToAsk;
  final List<String> whereToGetHelp;
  final List<String> yourRights;
  final List<QA> simpleQa;
  final String originalText;
  final String fullTranslation;

  // Added by the app (not from the AI)
  final String language;
  final DateTime createdAt;

  const Analysis({
    required this.readable,
    required this.documentType,
    required this.simpleSummary,
    required this.keyFacts,
    required this.actionSteps,
    this.responsibilities = const [],
    this.importantClauses = const [],
    required this.riskLevel,
    required this.riskReasons,
    this.safeSigns = const [],
    required this.beforeYouSign,
    required this.questionsToAsk,
    required this.whereToGetHelp,
    this.yourRights = const [],
    this.simpleQa = const [],
    this.originalText = '',
    this.fullTranslation = '',
    required this.language,
    required this.createdAt,
  });

  factory Analysis.fromJson(
    Map<String, dynamic> j, {
    required String language,
    DateTime? createdAt,
  }) {
    final risk = (j['risk'] is Map) ? Map<String, dynamic>.from(j['risk']) : <String, dynamic>{};
    return Analysis(
      readable: j['readable'] != false,
      documentType: _str(j['document_type']),
      simpleSummary: _str(j['simple_summary']),
      keyFacts: _list(j['key_facts']).map(KeyFact.fromJson).toList(),
      actionSteps: _list(j['action_steps']).map(ActionStep.fromJson).toList(),
      responsibilities: _sourcedList(j['responsibilities']),
      importantClauses: _sourcedList(j['important_clauses']),
      riskLevel: _risk(risk['level']),
      riskReasons: _strList(risk['reasons']),
      safeSigns: _strList(risk['safe_signs']),
      beforeYouSign: _sourcedList(j['before_you_sign']),
      questionsToAsk: _strList(j['questions_to_ask']),
      whereToGetHelp: _strList(j['where_to_get_help']),
      yourRights: _strList(j['your_rights']),
      simpleQa: _list(j['simple_qa'])
          .map(QA.fromJson)
          .where((q) => q.question.isNotEmpty && q.answer.isNotEmpty)
          .toList(),
      originalText: _str(j['original_text']),
      fullTranslation: _str(j['full_translation']),
      language: (j['_language'] as String?) ?? language,
      createdAt: DateTime.tryParse(_str(j['_created_at'])) ?? createdAt ?? DateTime.now(),
    );
  }

  /// Used for saving to history (same shape as the API, plus app fields).
  Map<String, dynamic> toJson() => {
        'readable': readable,
        'document_type': documentType,
        'simple_summary': simpleSummary,
        'key_facts': keyFacts.map((e) => e.toJson()).toList(),
        'action_steps': actionSteps.map((e) => e.toJson()).toList(),
        'responsibilities': responsibilities.map((e) => e.toJson()).toList(),
        'important_clauses': importantClauses.map((e) => e.toJson()).toList(),
        'risk': {'level': riskLevel.name, 'reasons': riskReasons, 'safe_signs': safeSigns},
        'before_you_sign': beforeYouSign.map((e) => e.toJson()).toList(),
        'questions_to_ask': questionsToAsk,
        'where_to_get_help': whereToGetHelp,
        'your_rights': yourRights,
        'simple_qa': simpleQa.map((e) => e.toJson()).toList(),
        'original_text': originalText,
        'full_translation': fullTranslation,
        '_language': language,
        '_created_at': createdAt.toIso8601String(),
      };

  /// Main action step with a deadline, shown in the orange "Action Needed" box.
  ActionStep? get mainAction {
    for (final s in actionSteps) {
      if (s.deadline != null) return s;
    }
    return actionSteps.isEmpty ? null : actionSteps.first;
  }

  /// Text spoken by "Listen to Explanation".
  String get explanationForSpeech {
    if (simpleQa.isNotEmpty) {
      return simpleQa.map((q) => '${q.question} ${q.answer}').join('\n');
    }
    return toPlainText();
  }

  /// Plain text version, used for Read Aloud and Share.
  String toPlainText({bool forSharing = false}) {
    final b = StringBuffer();
    if (documentType.isNotEmpty) b.writeln(documentType);
    if (simpleSummary.isNotEmpty) b.writeln(simpleSummary);
    if (riskReasons.isNotEmpty) {
      b.writeln();
      for (final r in riskReasons) {
        b.writeln('⚠ $r');
      }
    }
    if (keyFacts.isNotEmpty) {
      b.writeln();
      for (final f in keyFacts) {
        b.writeln('${f.label}: ${f.value}');
      }
    }
    if (actionSteps.isNotEmpty) {
      b.writeln();
      for (var i = 0; i < actionSteps.length; i++) {
        final s = actionSteps[i];
        b.writeln('${i + 1}. ${s.step}${s.deadline != null ? ' (${s.deadline})' : ''}');
      }
    }
    if (beforeYouSign.isNotEmpty) {
      b.writeln();
      for (final s in beforeYouSign) {
        b.writeln('✋ ${s.text}');
      }
    }
    if (forSharing && questionsToAsk.isNotEmpty) {
      b.writeln();
      for (final q in questionsToAsk) {
        b.writeln('? $q');
      }
    }
    return b.toString().trim();
  }
}

// ---- tolerant parsing helpers ----

String _str(dynamic v) => v == null ? '' : v.toString().trim();

List<Map<String, dynamic>> _list(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

List<String> _strList(dynamic v) => v is List
    ? v.map(_str).where((s) => s.isNotEmpty).toList()
    : <String>[];

/// Accepts either a list of {text, source} objects or a plain list of strings.
List<Sourced> _sourcedList(dynamic v) {
  if (v is! List) return const [];
  final out = <Sourced>[];
  for (final e in v) {
    if (e is Map) {
      final s = Sourced.fromJson(Map<String, dynamic>.from(e));
      if (s.text.isNotEmpty) out.add(s);
    } else {
      final t = _str(e);
      if (t.isNotEmpty) out.add(Sourced(t));
    }
  }
  return out;
}

RiskLevel _risk(dynamic v) {
  switch (_str(v).toLowerCase()) {
    case 'high':
      return RiskLevel.high;
    case 'medium':
      return RiskLevel.medium;
    default:
      return RiskLevel.low;
  }
}
