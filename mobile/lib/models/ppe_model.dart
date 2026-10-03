class PPE {
  final String? eventId;
  final String? helmetId;
  final String? hoodId;
  final String? faceMaskId;
  final String? scbaId;
  final String? gloveId;
  final String? bootId;
  final String? turnoutCoat;
  final String? turnoutPants;
  final DateTime lastUpdated;

  PPE({
    this.eventId,
    this.helmetId,
    this.hoodId,
    this.faceMaskId,
    this.scbaId,
    this.gloveId,
    this.bootId,
    this.turnoutCoat,
    this.turnoutPants,
    required this.lastUpdated,
  });

  Map<String, dynamic> toApiJson({bool isPpeUpdated = false}) {
    String s(String? v) => (v == null || v.trim().isEmpty) ? '' : v.trim();

    return {
      if (eventId != null && eventId!.trim().isNotEmpty)
        'event_id': eventId!.trim(),
      'helmet_id': s(helmetId),
      'hood_id': s(hoodId),
      'face_mask_id': s(faceMaskId),
      'scba_id': s(scbaId),
      'glove_id': s(gloveId),
      'boot_id': s(bootId),
      'bunker_coat_id': s(turnoutCoat),
      'bunker_pants_id': s(turnoutPants),
      'is_ppe_updated': isPpeUpdated,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'helmetId': helmetId,
      'hoodId': hoodId,
      'faceMaskId': faceMaskId,
      'scbaId': scbaId,
      'gloveId': gloveId,
      'bootId': bootId,
      'turnoutCoat': turnoutCoat,
      'turnoutPants': turnoutPants,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory PPE.fromJson(Map<String, dynamic> json) {
    return PPE(
      eventId: json['eventId'],
      helmetId: json['helmetId'],
      hoodId: json['hoodId'],
      faceMaskId: json['faceMaskId'],
      scbaId: json['scbaId'],
      gloveId: json['gloveId'],
      bootId: json['bootId'],
      turnoutCoat: json['turnoutCoat'],
      turnoutPants: json['turnoutPants'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}