// (no imports)
enum UserRole { researcher, firefighter, chiefSupervisor }

enum Status {
  careerFirefighter,
  volunteerFirefighter,
  bothVolunteerAndCareerFirefighter,
  traineeFirefighter,
  retiredFirefighter,
  other,
}

enum FirefighterType {
  structure,
  wildlandFirefighter,
  wui,
  other,
}

enum FFState {
  alabama,
  alaska,
  arizona,
  arkansas,
  california,
  colorado,
  connecticut,
  delaware,
  florida,
  georgia,
  hawaii,
  idaho,
  illinois,
  indiana,
  iowa,
  kansas,
  kentucky,
  louisiana,
  maine,
  maryland,
  massachusetts,
  michigan,
  minnesota,
  mississippi,
  missouri,
  montana,
  nebraska,
  nevada,
  newHampshire,
  newJersey,
  newMexico,
  newYork,
  northCarolina,
  northDakota,
  ohio,
  oklahoma,
  oregon,
  pennsylvania,
  rhodeIsland,
  southCarolina,
  southDakota,
  tennessee,
  texas,
  utah,
  vermont,
  virginia,
  washingtonState,
  westVirginia,
  wisconsin,
  wyoming,
}

String stateToDisplayString(FFState state) {
  switch (state) {
    case FFState.alabama:
      return 'Alabama';
    case FFState.alaska:
      return 'Alaska';
    case FFState.arizona:
      return 'Arizona';
    case FFState.arkansas:
      return 'Arkansas';
    case FFState.california:
      return 'California';
    case FFState.colorado:
      return 'Colorado';
    case FFState.connecticut:
      return 'Connecticut';
    case FFState.delaware:
      return 'Delaware';
    case FFState.florida:
      return 'Florida';
    case FFState.georgia:
      return 'Georgia';
    case FFState.hawaii:
      return 'Hawaii';
    case FFState.idaho:
      return 'Idaho';
    case FFState.illinois:
      return 'Illinois';
    case FFState.indiana:
      return 'Indiana';
    case FFState.iowa:
      return 'Iowa';
    case FFState.kansas:
      return 'Kansas';
    case FFState.kentucky:
      return 'Kentucky';
    case FFState.louisiana:
      return 'Louisiana';
    case FFState.maine:
      return 'Maine';
    case FFState.maryland:
      return 'Maryland';
    case FFState.massachusetts:
      return 'Massachusetts';
    case FFState.michigan:
      return 'Michigan';
    case FFState.minnesota:
      return 'Minnesota';
    case FFState.mississippi:
      return 'Mississippi';
    case FFState.missouri:
      return 'Missouri';
    case FFState.montana:
      return 'Montana';
    case FFState.nebraska:
      return 'Nebraska';
    case FFState.nevada:
      return 'Nevada';
    case FFState.newHampshire:
      return 'New Hampshire';
    case FFState.newJersey:
      return 'New Jersey';
    case FFState.newMexico:
      return 'New Mexico';
    case FFState.newYork:
      return 'New York';
    case FFState.northCarolina:
      return 'North Carolina';
    case FFState.northDakota:
      return 'North Dakota';
    case FFState.ohio:
      return 'Ohio';
    case FFState.oklahoma:
      return 'Oklahoma';
    case FFState.oregon:
      return 'Oregon';
    case FFState.pennsylvania:
      return 'Pennsylvania';
    case FFState.rhodeIsland:
      return 'Rhode Island';
    case FFState.southCarolina:
      return 'South Carolina';
    case FFState.southDakota:
      return 'South Dakota';
    case FFState.tennessee:
      return 'Tennessee';
    case FFState.texas:
      return 'Texas';
    case FFState.utah:
      return 'Utah';
    case FFState.vermont:
      return 'Vermont';
    case FFState.virginia:
      return 'Virginia';
    case FFState.washingtonState:
      return 'Washington';
    case FFState.westVirginia:
      return 'West Virginia';
    case FFState.wisconsin:
      return 'Wisconsin';
    case FFState.wyoming:
      return 'Wyoming';
  }
}

FFState stateFromDisplayString(String value) {
  return FFState.values.firstWhere(
    (s) => stateToDisplayString(s) == value,
    orElse: () => FFState.alabama,
  );
}

String userRoleToStorageString(UserRole role) {
  switch (role) {
    case UserRole.researcher:
      return 'researcher';
    case UserRole.firefighter:
      return 'firefighter';
    case UserRole.chiefSupervisor:
      return 'chiefSupervisor';
  }
}

UserRole userRoleFromStorageString(String? value) {
  switch (value) {
    case 'researcher':
      return UserRole.researcher;
    case 'chiefSupervisor':
      return UserRole.chiefSupervisor;
    case 'firefighter':
    default:
      return UserRole.firefighter;
  }
}

/// Maps API/DB role strings (`chief`, `researcher`, `firefighter`) to [UserRole].
UserRole userRoleFromApiString(String? value) {
  switch (value) {
    case 'researcher':
      return UserRole.researcher;
    case 'chief':
    case 'chiefSupervisor':
      return UserRole.chiefSupervisor;
    case 'firefighter':
    default:
      return UserRole.firefighter;
  }
}

/// Maps [UserRole] to FastAPI register payload `role` values.
String userRoleToApiString(UserRole role) {
  switch (role) {
    case UserRole.researcher:
      return 'researcher';
    case UserRole.chiefSupervisor:
      return 'chief';
    case UserRole.firefighter:
      return 'firefighter';
  }
}

/// Builds `type_of_firefighter` for the register API (comma-separated labels).
String typeOfFirefighterForApi(
  List<FirefighterType> types,
  String otherDetail,
) {
  if (types.isEmpty) {
    return 'Other';
  }
  return types.map((t) {
    if (t == FirefighterType.other && otherDetail.trim().isNotEmpty) {
      return otherDetail.trim();
    }
    return firefighterTypeToDisplayString(t);
  }).join(', ');
}

String StatusToDisplayString(Status status) {
  switch (status) {
    case Status.careerFirefighter:
      return 'Career firefighter';
    case Status.volunteerFirefighter:
      return 'Volunteer firefighter';
    case Status.bothVolunteerAndCareerFirefighter:
      return 'Both career and volunteer firefighter';
    case Status.traineeFirefighter:
      return 'Trainee';
    case Status.retiredFirefighter:
      return 'Retired Firefighter';
    case Status.other:
      return 'Other';
  }
}

Status StatusFromDisplayString(String value) {
  final v = value.trim().toLowerCase();
  switch (v) {
    case 'career firefighter':
      return Status.careerFirefighter;
    case 'volunteer firefighter':
      return Status.volunteerFirefighter;
    case 'both career and volunteer firefighter':
    case 'both volunteer and career firefighter':
      return Status.bothVolunteerAndCareerFirefighter;
    case 'trainee':
      return Status.traineeFirefighter;
    case 'retired firefighter':
      return Status.retiredFirefighter;
    default:
      return Status.other;
  }
}

String firefighterTypeToDisplayString(FirefighterType type) {
  switch (type) {
    case FirefighterType.structure:
      return 'Structure';
    case FirefighterType.wildlandFirefighter:
      return 'Wildland';
    case FirefighterType.wui:
      return 'WUI';
    case FirefighterType.other:
      return 'Other';
  }
}

FirefighterType firefighterTypeFromDisplayString(String value) {
  final v = value.trim().toLowerCase();
  switch (v) {
    case 'structure':
      return FirefighterType.structure;
    case 'wildland':
    case 'wildland firefighter':
    case 'wildlandfirefighter':
    case 'wildland_firefighter':
      return FirefighterType.wildlandFirefighter;
    case 'wui':
      return FirefighterType.wui;
    default:
      return FirefighterType.other;
  }
}

List<String> firefighterTypesToStorage(List<FirefighterType> types) {
  return types.map((t) => t.toString().split('.').last).toList();
}

List<FirefighterType> firefighterTypesFromStorage(List<dynamic> rawList) {
  return rawList
      .map((e) => e.toString())
      .map(
        (name) => FirefighterType.values.firstWhere(
          (t) => t.toString().split('.').last == name,
          orElse: () => FirefighterType.other,
        ),
      )
      .toList();
}

String userRoleToDisplayString(UserRole role) {
  switch (role) {
    case UserRole.researcher:
      return 'Researcher';
    case UserRole.firefighter:
      return 'Firefighter';
    case UserRole.chiefSupervisor:
      return 'Chief/Supervisor';
  }
}

class User {
  final String name;
  final int age;
  final String email;
  final String phoneNumber;
  final String password;
  final UserRole role;

  // Additional attributes for firefighters
  final String gender;
  final String race;
  final String ethnicity;
  final int birthYear;
  final String height;
  final String weight;
  /// Three-way dominant hand label as returned by backend / chosen at signup.
  /// Expected values: 'Right', 'Left', 'Ambidextrous' (or '—' when unknown).
  final String dominantHandLabel;

  /// Legacy boolean representation: true = right/ambidextrous, false = left.
  /// Kept for backward compatibility in local storage.
  final bool dominantHand;
  final String
  yearsOfExperience; //Y[number of years]M[number of months] eg : Y5M2 -> 5 years and 2 months of experience
  final Status status;
  final List<FirefighterType> firefighterTypes;
  final String firefighterStationName;
  final String city;
  final FFState state;

  User({
    required this.name,
    required this.age,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.role = UserRole.firefighter,
    required this.gender,
    required this.race,
    required this.ethnicity,
    required this.birthYear,
    required this.height,
    required this.weight,
    required this.dominantHandLabel,
    required this.dominantHand,
    required this.yearsOfExperience,
    required this.status,
    required this.firefighterTypes,
    this.firefighterStationName = '—',
    required this.city,
    required this.state,
  });

  /// Minimal profile when the session comes from API login (`/me` omits demographics).
  factory User.fromAuthSession({
    required String email,
    required UserRole role,
    String? displayName,
  }) {
    final local = email.split('@').first;
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (local.isNotEmpty ? local : 'User');
    return User(
      name: name,
      age: 0,
      email: email,
      phoneNumber: '',
      password: '',
      role: role,
      gender: '—',
      race: '—',
      ethnicity: '—',
      birthYear: 0,
      height: '—',
      weight: '—',
      dominantHandLabel: '—',
      dominantHand: true,
      yearsOfExperience: 'Y0M0',
      status: Status.other,
      firefighterTypes: const [FirefighterType.other],
      firefighterStationName: '—',
      city: '—',
      state: FFState.alabama,
    );
  }

  /// Profile from `GET /api/v1/auth/me` after the backend returns full user fields.
  factory User.fromAuthMeJson(Map<String, dynamic> json) {
    final email = json['email'] as String? ?? '';
    final local = email.split('@').first;
    final nameRaw = json['full_name'] ?? json['name'];
    final name = (nameRaw != null && nameRaw.toString().trim().isNotEmpty)
        ? nameRaw.toString().trim()
        : (local.isNotEmpty ? local : 'User');

    // Use 0 as "unknown" instead of epoch-year defaults like 1970.
    int birthYear = 0;
    final yb = json['year_of_birth'];
    if (yb != null) {
      if (yb is int) {
        birthYear = yb;
      } else {
        birthYear = int.tryParse(yb.toString()) ?? 0;
      }
    }
    final nowYear = DateTime.now().year;
    final age = birthYear > 0 ? (nowYear - birthYear).clamp(0, 200) : 0;

    String dashOr(dynamic v) {
      if (v == null) return '—';
      final t = v.toString().trim();
      return t.isEmpty ? '—' : t;
    }

    String heightStr = '—';
    final hcm = json['height_cm'];
    if (hcm != null) {
      final n = hcm is num ? hcm.toDouble() : double.tryParse(hcm.toString());
      if (n != null) {
        heightStr = n == n.roundToDouble()
            ? '${n.toInt()} cm'
            : '${n.toStringAsFixed(1)} cm';
      }
    }

    String weightStr = '—';
    final wkg = json['weight_kg'];
    if (wkg != null) {
      final n = wkg is num ? wkg.toDouble() : double.tryParse(wkg.toString());
      if (n != null) {
        weightStr = n == n.roundToDouble()
            ? '${n.toInt()} kg'
            : '${n.toStringAsFixed(1)} kg';
      }
    }

    String dominantHandLabel = '—';
    final dhRaw = json['dominant_hand'];
    if (dhRaw != null) {
      final t = dhRaw.toString().trim();
      if (t.isNotEmpty) dominantHandLabel = t;
    }
    final dominantHand =
        dominantHandLabel.toLowerCase() == 'left' ? false : true;

    final yearsExp = json['Years_of_experience'] as String?;
    final yearsOfExperience =
        (yearsExp != null && yearsExp.trim().isNotEmpty) ? yearsExp.trim() : 'Y0M0';

    final fs = json['firefighter_status'] as String?;
    final status = (fs != null && fs.trim().isNotEmpty)
        ? StatusFromDisplayString(fs.trim())
        : Status.other;

    final tf = json['type_of_firefighter'] as String?;
    List<FirefighterType> types;
    if (tf == null || tf.trim().isEmpty) {
      types = const [FirefighterType.other];
    } else {
      types = tf
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map(firefighterTypeFromDisplayString)
          .toList();
      if (types.isEmpty) {
        types = const [FirefighterType.other];
      }
    }

    final stateStr = json['state'] as String?;
    final state = (stateStr != null && stateStr.trim().isNotEmpty)
        ? stateFromDisplayString(stateStr.trim())
        : FFState.alabama;

    final phoneRaw = json['phoneNumber'];
    final phoneFromMe = (phoneRaw != null && phoneRaw.toString().trim().isNotEmpty)
        ? phoneRaw.toString().trim()
        : '';

    return User(
      name: name,
      age: age,
      email: email,
      phoneNumber: phoneFromMe,
      password: '',
      role: userRoleFromApiString(json['role'] as String?),
      gender: dashOr(json['gender']),
      race: dashOr(json['race']),
      ethnicity: dashOr(json['ethnicity']),
      birthYear: birthYear,
      height: heightStr,
      weight: weightStr,
      dominantHandLabel: dominantHandLabel,
      dominantHand: dominantHand,
      yearsOfExperience: yearsOfExperience,
      status: status,
      firefighterTypes: types,
      firefighterStationName: dashOr(json['firefighter_station_name']),
      city: dashOr(json['city']),
      state: state,
    );
  }

  User copyWith({String? password}) {
    return User(
      name: name,
      age: age,
      email: email,
      phoneNumber: phoneNumber,
      password: password ?? this.password,
      role: role,
      gender: gender,
      race: race,
      ethnicity: ethnicity,
      birthYear: birthYear,
      height: height,
      weight: weight,
      dominantHandLabel: dominantHandLabel,
      dominantHand: dominantHand,
      yearsOfExperience: yearsOfExperience,
      status: status,
      firefighterTypes: firefighterTypes,
      firefighterStationName: firefighterStationName,
      city: city,
      state: state,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': userRoleToStorageString(role),
      'gender': gender,
      'race': race,
      'ethnicity': ethnicity,
      'birthYear': birthYear,
      'height': height,
      'weight': weight,
      'dominantHandLabel': dominantHandLabel,
      'dominantHand': dominantHand,
      'yearsOfExperience': yearsOfExperience,
      'status': StatusToDisplayString(status),
      'firefighterTypes': firefighterTypesToStorage(firefighterTypes),
      'firefighterStationName': firefighterStationName,
      'city': city,
      'state': state.toString().split('.').last,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final dominantHandBool = json['dominantHand'] == true;
    final dominantHandLabelRaw = json['dominantHandLabel'];
    final dominantHandLabel = (dominantHandLabelRaw != null &&
            dominantHandLabelRaw.toString().trim().isNotEmpty)
        ? dominantHandLabelRaw.toString().trim()
        : (dominantHandBool ? 'Right' : 'Left');
    return User(
      name: json['name'],
      age: json['age'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
      role: userRoleFromStorageString(json['role']),
      gender: json['gender'],
      race: json['race'],
      ethnicity: json['ethnicity'],
      birthYear: json['birthYear'],
      height: json['height'],
      weight: json['weight'],
      dominantHandLabel: dominantHandLabel,
      dominantHand: dominantHandBool,
      yearsOfExperience: json['yearsOfExperience'],
      status: StatusFromDisplayString(json['status']),
      firefighterTypes: json['firefighterTypes'] is List
          ? firefighterTypesFromStorage(json['firefighterTypes'] as List)
          : [],
      firefighterStationName: json['firefighterStationName'] ?? '—',
      city: json['city'],
      state: FFState.values.firstWhere((e) => e.toString().split('.').last == json['state']),
    );
  }
}
