import 'package:flutter/material.dart';
import '../models/user_model.dart' as user_model;
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'manual_verify_email_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _stationNameController = TextEditingController();

  // Demographics
  String? _selectedGender;
  final _otherGenderController = TextEditingController();
  String? _selectedRace;
  final _otherRaceController = TextEditingController();
  String? _selectedEthnicity;
  int? _selectedBirthYear;
  late final List<int> _birthYearOptions;

  // Height
  final _heightValueController = TextEditingController();
  final _heightFeetController = TextEditingController();
  final _heightInchesController = TextEditingController();
  String _heightUnit = 'cm'; // 'cm', 'inches', 'feet_inches'

  // Weight
  final _weightValueController = TextEditingController();
  String _weightUnit = 'kg'; // 'kg', 'lb'

  // Dominant hand
  String? _dominantHandSelection; // 'Right', 'Left', 'Ambidextrous'

  // Experience
  final _yearsExperienceController = TextEditingController();
  final _monthsExperienceController = TextEditingController();
  Status? _selectedStatus;
  final _otherStatusController = TextEditingController();

  // Firefighting types
  bool _typeStructure = false;
  bool _typeWildland = false;
  bool _typeWui = false;
  bool _typeOther = false;
  final _otherTypeController = TextEditingController();

  // Location
  final _cityController = TextEditingController();
  user_model.FFState? _selectedState;

  final _authService = AuthService();
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.firefighter;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _birthYearOptions = List<int>.generate(
      currentYear - 1950 + 1,
      (i) => currentYear - i,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _stationNameController.dispose();
    _otherGenderController.dispose();
    _otherRaceController.dispose();
    _heightValueController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightValueController.dispose();
    _yearsExperienceController.dispose();
    _monthsExperienceController.dispose();
    _otherStatusController.dispose();
    _otherTypeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  String _heightDisplayString() {
    if (_heightUnit == 'cm' || _heightUnit == 'inches') {
      return '${_heightValueController.text.trim()} $_heightUnit';
    }
    return '${_heightFeetController.text.trim()} ft ${_heightInchesController.text.trim()} in';
  }

  double? _heightToCm() {
    switch (_heightUnit) {
      case 'cm':
        return double.tryParse(_heightValueController.text.trim());
      case 'inches':
        final inches = double.tryParse(_heightValueController.text.trim());
        return inches != null ? inches * 2.54 : null;
      case 'feet_inches':
        final feet = double.tryParse(_heightFeetController.text.trim());
        final inches = double.tryParse(_heightInchesController.text.trim());
        if (feet != null && inches != null) {
          return (feet * 12.0 + inches) * 2.54;
        }
        return null;
      default:
        return null;
    }
  }

  double? _weightToKg() {
    final raw = double.tryParse(_weightValueController.text.trim());
    if (raw == null) return null;
    return _weightUnit == 'kg' ? raw : raw * 0.45359237;
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    String? gender;
    if (_selectedGender != null) {
      final raw = _selectedGender == 'Other'
          ? _otherGenderController.text.trim()
          : _selectedGender!;
      if (raw.isNotEmpty) gender = raw;
    }

    String? race;
    if (_selectedRace != null) {
      final raw = _selectedRace == 'Other (please specify)'
          ? _otherRaceController.text.trim()
          : _selectedRace!;
      if (raw.isNotEmpty) race = raw;
    }

    final ethnicity = _selectedEthnicity;
    final birthYear = _selectedBirthYear;

    final height = _heightDisplayString();
    final weight = '${_weightValueController.text.trim()} $_weightUnit';

    final double? heightCm = _heightToCm();
    final double? weightKg = _weightToKg();

    if (heightCm == null || weightKg == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid height or weight'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final bool dominantHand = _dominantHandSelection == 'Left' ? false : true;
    final dominantHandLabel = _dominantHandSelection!;

    final years = int.parse(_yearsExperienceController.text.trim());
    final months = int.parse(_monthsExperienceController.text.trim());
    final yearsOfExperience = 'Y${years}M$months';

    final Status status = _selectedStatus!;

    final List<FirefighterType> firefighterTypes = [];

    if (_typeStructure) {
      firefighterTypes.add(FirefighterType.structure);
    }

    if (_typeWildland) {
      firefighterTypes.add(FirefighterType.wildlandFirefighter);
    }

    if (_typeWui) {
      firefighterTypes.add(FirefighterType.wui);
    }

    if (_typeOther) {
      firefighterTypes.add(FirefighterType.other);
    }

    final city = _cityController.text.trim();
    final state = _selectedState!;

    setState(() {
      _isLoading = true;
    });

    final success = await _authService.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      gender: gender,
      race: race,
      ethnicity: ethnicity,
      birthYear: birthYear,
      height: height,
      weight: weight,
      dominantHand: dominantHand,
      dominantHandLabel: dominantHandLabel,
      heightCm: heightCm,
      weightKg: weightKg,
      yearsOfExperience: yearsOfExperience,
      status: status,
      firefighterTypes: firefighterTypes,
      otherFirefighterTypeDetail: _otherTypeController.text.trim(),
      firefighterStationName: _stationNameController.text.trim(),
      city: city,
      state: state,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully. Please verify your email before signing in.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ManualVerifyEmailPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Basic Info',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  maxLength: 15,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (value.length > 15) {
                      return 'Password must be at most 15 characters';
                    }
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Password must contain a lowercase letter';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Password must contain an uppercase letter';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Password must contain a number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 24),
                const Text(
                  'Demographics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Select option'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Male',
                      child: Text('Male'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Female',
                      child: Text('Female'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Other',
                      child: Text('Other (please specify)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                if (_selectedGender == 'Other') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otherGenderController,
                    decoration: const InputDecoration(
                      labelText: 'Please specify gender',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: _selectedRace,
                  decoration: const InputDecoration(
                    labelText: 'Race (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Select option'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Native American/Alaskan Native',
                      child: Text('Native American/Alaskan Native'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Black/African American',
                      child: Text('Black/African American'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'White',
                      child: Text('White'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Chinese',
                      child: Text('Chinese'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Vietnamese',
                      child: Text('Vietnamese'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Native Hawaiian',
                      child: Text('Native Hawaiian'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Filipino',
                      child: Text('Filipino'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Korean',
                      child: Text('Korean'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Samoan',
                      child: Text('Samoan'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Asian Indian',
                      child: Text('Asian Indian'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Japanese',
                      child: Text('Japanese'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Chamorro',
                      child: Text('Chamorro'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Other (please specify)',
                      child: Text('Other (please specify)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRace = value;
                    });
                  },
                ),
                if (_selectedRace == 'Other (please specify)') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otherRaceController,
                    decoration: const InputDecoration(
                      labelText: 'Please specify race',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: _selectedEthnicity,
                  decoration: const InputDecoration(
                    labelText: 'Ethnicity (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Select option'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Hispanic or Latino or Spanish',
                      child: Text('Hispanic or Latino or Spanish'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'Not Hispanic or Latino or Spanish',
                      child: Text('Not Hispanic or Latino or Spanish'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedEthnicity = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  value: _selectedBirthYear,
                  decoration: const InputDecoration(
                    labelText: 'Year of birth (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Select option'),
                    ),
                    ..._birthYearOptions.map(
                      (y) => DropdownMenuItem<int?>(
                        value: y,
                        child: Text('$y'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedBirthYear = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Physical Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _heightUnit,
                  decoration: const InputDecoration(
                    labelText: 'Height unit',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'cm',
                      child: Text('Centimeters (cm)'),
                    ),
                    DropdownMenuItem(
                      value: 'inches',
                      child: Text('Inches'),
                    ),
                    DropdownMenuItem(
                      value: 'feet_inches',
                      child: Text('Feet and inches'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _heightUnit = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_heightUnit == 'feet_inches') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightFeetController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Feet',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_heightUnit != 'feet_inches') {
                              return null;
                            }
                            if (value == null || value.isEmpty) {
                              return 'Enter feet';
                            }
                            final v = int.tryParse(value);
                            if (v == null || v <= 0) {
                              return 'Invalid feet';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _heightInchesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Inches',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_heightUnit != 'feet_inches') {
                              return null;
                            }
                            if (value == null || value.isEmpty) {
                              return 'Enter inches';
                            }
                            final v = int.tryParse(value);
                            if (v == null || v < 0 || v > 11) {
                              return '0-11 only';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  TextFormField(
                    controller: _heightValueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _heightUnit == 'cm'
                          ? 'Height (cm)'
                          : 'Height (inches)',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      final v = double.tryParse(value);
                      if (v == null || v <= 0) {
                        return 'Please enter a valid height';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _weightUnit,
                  decoration: const InputDecoration(
                    labelText: 'Weight unit',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'kg',
                      child: Text('Kilograms (kg)'),
                    ),
                    DropdownMenuItem(
                      value: 'lb',
                      child: Text('Pounds (lb)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _weightUnit = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightValueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        _weightUnit == 'kg' ? 'Weight (kg)' : 'Weight (lb)',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    final v = double.tryParse(value);
                    if (v == null || v <= 0) {
                      return 'Please enter a valid weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dominant hand',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                RadioListTile<String>(
                  title: const Text('Right'),
                  value: 'Right',
                  groupValue: _dominantHandSelection,
                  onChanged: (value) {
                    setState(() {
                      _dominantHandSelection = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Left'),
                  value: 'Left',
                  groupValue: _dominantHandSelection,
                  onChanged: (value) {
                    setState(() {
                      _dominantHandSelection = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Ambidextrous'),
                  value: 'Ambidextrous',
                  groupValue: _dominantHandSelection,
                  onChanged: (value) {
                    setState(() {
                      _dominantHandSelection = value;
                    });
                  },
                ),
                Builder(
                  builder: (context) {
                    return Visibility(
                      visible: false,
                      child: TextFormField(
                        validator: (_) {
                          if (_dominantHandSelection == null) {
                            return 'Please select your dominant hand';
                          }
                          return null;
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Firefighting Experience',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearsExperienceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Years',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter years';
                          }
                          final v = int.tryParse(value);
                          if (v == null || v < 0) {
                            return 'Invalid years';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _monthsExperienceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Months',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter months';
                          }
                          final v = int.tryParse(value);
                          if (v == null || v < 0 || v > 11) {
                            return '0-11 only';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Status>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Firefighting status',
                    border: OutlineInputBorder(),
                  ),
                  items: Status.values
                      .map(
                        (s) => DropdownMenuItem<Status>(
                          value: s,
                          child: Text(StatusToDisplayString(s)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your firefighting status';
                    }
                    if (value == Status.other &&
                        _otherStatusController.text.trim().isEmpty) {
                      return 'Please specify your firefighting status';
                    }
                    return null;
                  },
                ),
                if (_selectedStatus == Status.other) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otherStatusController,
                    decoration: const InputDecoration(
                      labelText: 'Please specify firefighting status',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Type of firefighting (select all that apply)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                CheckboxListTile(
                  title: const Text('Structure'),
                  value: _typeStructure,
                  onChanged: (value) {
                    setState(() {
                      _typeStructure = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Wildland'),
                  value: _typeWildland,
                  onChanged: (value) {
                    setState(() {
                      _typeWildland = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('WUI'),
                  value: _typeWui,
                  onChanged: (value) {
                    setState(() {
                      _typeWui = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Other (please specify)'),
                  value: _typeOther,
                  onChanged: (value) {
                    setState(() {
                      _typeOther = value ?? false;
                    });
                  },
                ),
                if (_typeOther) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _otherTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Please specify type of firefighting',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                Builder(
                  builder: (context) {
                    return Visibility(
                      visible: false,
                      child: TextFormField(
                        validator: (_) {
                          if (!(_typeStructure ||
                              _typeWildland ||
                              _typeWui ||
                              _typeOther)) {
                            return 'Please select at least one type of firefighting';
                          }
                          if (_typeOther &&
                              _otherTypeController.text.trim().isEmpty) {
                            return 'Please specify the other type of firefighting';
                          }
                          return null;
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stationNameController,
                  decoration: const InputDecoration(
                    labelText: 'Firefighter Station Name',
                    prefixIcon: Icon(Icons.home_work_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your firefighter station name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Firefighting city/town',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your firefighting city/town';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<user_model.FFState>(
                  value: _selectedState,
                  decoration: const InputDecoration(
                    labelText: 'US state',
                    border: OutlineInputBorder(),
                  ),
                  items: user_model.FFState.values
                      .map(
                        (s) => DropdownMenuItem<user_model.FFState>(
                          value: s,
                          child: Text(stateToDisplayString(s)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your state';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                  items: UserRole.values
                      .map(
                        (role) => DropdownMenuItem<UserRole>(
                          value: role,
                          child: Text(userRoleToDisplayString(role)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}