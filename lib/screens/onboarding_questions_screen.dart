import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

class OnboardingQuestionsScreen extends StatefulWidget {
  const OnboardingQuestionsScreen({super.key});

  @override
  State<OnboardingQuestionsScreen> createState() => _OnboardingQuestionsScreenState();
}

class _OnboardingQuestionsScreenState extends State<OnboardingQuestionsScreen> {
  static const int _totalQuestions = 13;

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _hba1cController = TextEditingController();
  final _lowThresholdController = TextEditingController();
  final _highThresholdController = TextEditingController();

  int _step = 0;
  String? _diabetesType;
  String? _glucoseUnit;
  String? _cgmSensor;
  String? _activityLevel;
  String? _dietaryPattern;
  final Set<String> _medications = {};
  final Set<String> _comorbidities = {};
  DateTime _diagnosisDate = DateTime(2026, 1, 1);
  bool _didBootstrap = false;

  final List<String> _diabetesTypes = const [
    'None',
    'Type 1 Diabetes',
    'Type 2 Diabetes',
    'Generational Diabetes',
    'Special Diabetes',
    'Others',
  ];

  final List<_UnitOption> _unitOptions = const [
    _UnitOption('mg/dL', '(70-180 mg/dL)'),
    _UnitOption('mmol/L', '(3.9-10.0 mmol/L)'),
  ];

  final List<String> _cgmSensors = const [
    'Dexcom G7',
    'Dexcom G6',
    'Libre 3',
    'Libre 2',
    'Medtronic Guardian',
    'Eversense E3',
    'Other',
  ];

  final List<String> _medicationOptions = const [
    'Insulin — Rapid-acting',
    'Insulin — Long-acting',
    'Metformin',
    'GLP-1 Agonist (Semaglutide / Liraglutide)',
    'SGLT2 Inhibitor',
    'DPP-4 Inhibitor',
    'Sulfonylurea',
    'None',
  ];

  final List<String> _comorbidityOptions = const [
    'Hypertension',
    'Chronic Kidney Disease (CKD)',
    'Non-Alcoholic Fatty Liver',
    'Dyslipidaemia',
    'Obesity (BMI ≥30)',
    'Thyroid Disorder',
    'None',
  ];

  final List<String> _activityOptions = const [
    'Little to no exercise',
    '1–3 days/week',
    '3–5 days/week',
    '6–7 days/week',
    'Twice daily / competitive training',
  ];

  final List<_ChoiceOption> _dietaryOptions = const [
    _ChoiceOption('Standard / Mixed', subtitle: 'No specific restriction'),
    _ChoiceOption('Low Carb / Keto', subtitle: '<50g carbs/day'),
    _ChoiceOption('Intermittent Fasting', subtitle: '16:8 / OMAD / 5:2'),
    _ChoiceOption('Plant-Based', subtitle: 'Vegan or vegetarian'),
    _ChoiceOption('Mediterranean', subtitle: 'Whole foods, olive oil, fish'),
    _ChoiceOption('Other', subtitle: 'Custom or prescribed diet'),
  ];

  bool get _isCurrentStepValid {
    switch (_step) {
      case 0:
        return true;
      case 1:
        return _weightController.text.trim().isNotEmpty;
      case 2:
        return _heightController.text.trim().isNotEmpty;
      case 3:
        return _diabetesType != null;
      case 4:
        return true;
      case 5:
        return _glucoseUnit != null;
      case 6:
        return _cgmSensor != null;
      case 7:
        return _hba1cController.text.trim().isNotEmpty;
      case 8:
        return _lowThresholdController.text.trim().isNotEmpty &&
            _highThresholdController.text.trim().isNotEmpty;
      case 9:
        return _medications.isNotEmpty;
      case 10:
        return _comorbidities.isNotEmpty;
      case 11:
        return _activityLevel != null;
      case 12:
        return _dietaryPattern != null;
      default:
        return false;
    }
  }

  String get _primaryButtonLabel {
    if (_step == 0 || _step == 5 || _step == 12) {
      return 'Continue';
    }
    return 'Next';
  }

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_onInputChanged);
    _heightController.addListener(_onInputChanged);
    _hba1cController.addListener(_onInputChanged);
    _lowThresholdController.addListener(_onInputChanged);
    _highThresholdController.addListener(_onInputChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didBootstrap) {
      return;
    }

    _didBootstrap = true;
    _bootstrapOnboarding();
  }

  Future<void> _bootstrapOnboarding() async {
    final authProvider = context.read<AuthProvider>();
    final onboardingProvider = context.read<OnboardingProvider>();
    final userId = authProvider.user?.id;

    if (userId == null || userId.isEmpty) {
      return;
    }

    final loaded = await onboardingProvider.loadAnswers(userId);
    if (!mounted || !loaded) {
      return;
    }

    final answers = onboardingProvider.answers;
    if (answers == null || answers.isEmpty) {
      return;
    }

    _applySavedAnswers(answers);
  }

  void _applySavedAnswers(Map<String, dynamic> answers) {
    setState(() {
      _weightController.text = (answers['weight'] ?? '').toString();
      _heightController.text = (answers['height'] ?? '').toString();
      _hba1cController.text = (answers['hba1c'] ?? '').toString();
      _lowThresholdController.text = (answers['targetLow'] ?? '').toString();
      _highThresholdController.text = (answers['targetHigh'] ?? '').toString();

      _diabetesType = answers['diabetesType']?.toString();
      _glucoseUnit = answers['glucoseUnit']?.toString();
      _cgmSensor = answers['cgmSensor']?.toString();
      _activityLevel = answers['activityLevel']?.toString();
      _dietaryPattern = answers['dietaryPattern']?.toString();

      final diagnosisRaw = answers['diagnosisDate'];
      if (diagnosisRaw is String && diagnosisRaw.isNotEmpty) {
        final parsed = DateTime.tryParse(diagnosisRaw);
        if (parsed != null) {
          _diagnosisDate = parsed;
        }
      }

      _medications
        ..clear()
        ..addAll(
          (answers['medications'] is List)
              ? (answers['medications'] as List).map((item) => item.toString())
              : const <String>[],
        );

      _comorbidities
        ..clear()
        ..addAll(
          (answers['comorbidities'] is List)
              ? (answers['comorbidities'] as List).map((item) => item.toString())
              : const <String>[],
        );
    });
  }

  void _onInputChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _weightController.removeListener(_onInputChanged);
    _heightController.removeListener(_onInputChanged);
    _hba1cController.removeListener(_onInputChanged);
    _lowThresholdController.removeListener(_onInputChanged);
    _highThresholdController.removeListener(_onInputChanged);
    _weightController.dispose();
    _heightController.dispose();
    _hba1cController.dispose();
    _lowThresholdController.dispose();
    _highThresholdController.dispose();
    super.dispose();
  }

  Future<bool> _handleBack() async {
    if (_step == 0) {
      return true;
    }

    setState(() {
      _step -= 1;
    });
    return false;
  }

  Future<void> _onPrimaryTap() async {
    if (!_isCurrentStepValid) {
      return;
    }

    if (_step < 12) {
      setState(() {
        _step += 1;
      });
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final onboardingProvider = context.read<OnboardingProvider>();
    final userId = authProvider.user?.id;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      return;
    }

    final payload = {
      'weight': _weightController.text.trim(),
      'height': _heightController.text.trim(),
      'diabetesType': _diabetesType,
      'diagnosisDate': _diagnosisDate.toIso8601String(),
      'glucoseUnit': _glucoseUnit,
      'cgmSensor': _cgmSensor,
      'hba1c': _hba1cController.text.trim(),
      'targetLow': _lowThresholdController.text.trim(),
      'targetHigh': _highThresholdController.text.trim(),
      'medications': _medications.toList(),
      'comorbidities': _comorbidities.toList(),
      'activityLevel': _activityLevel,
      'dietaryPattern': _dietaryPattern,
      'progress': '13/13',
    };

    final success = await onboardingProvider.saveAnswers(userId, payload);
    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(onboardingProvider.error ?? 'Unable to save onboarding')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Onboarding (part 1) saved.')),
    );
    context.push('/device/setup');
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F4),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                const SizedBox(height: 18),
                _OnboardingProgressHeader(
                  progress: ((_step + 1) / _totalQuestions).clamp(0.0, 1.0),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _buildStepBody(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 26),
                  child: _PrimaryActionButton(
                    label: _primaryButtonLabel,
                    enabled: _isCurrentStepValid && !onboardingProvider.isLoading,
                    isLoading: onboardingProvider.isLoading,
                    onTap: () {
                      _onPrimaryTap();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case 0:
        return _WelcomeStep(
          key: const ValueKey('welcome'),
          questionIndex: 1,
          totalQuestions: _totalQuestions,
        );
      case 1:
        return _NumericInputStep(
          key: const ValueKey('weight'),
          title: 'Weight',
          hint: 'Weight',
          controller: _weightController,
        );
      case 2:
        return _NumericInputStep(
          key: const ValueKey('height'),
          title: 'Height',
          hint: 'Height',
          controller: _heightController,
        );
      case 3:
        return _SingleSelectStep(
          key: const ValueKey('diabetes_type'),
          title: 'Type of Diabetes',
          options: _diabetesTypes,
          selected: _diabetesType,
          onSelect: (value) {
            setState(() {
              _diabetesType = value;
            });
          },
        );
      case 4:
        return _DateDiagnosisStep(
          key: const ValueKey('diagnosis_date'),
          date: _diagnosisDate,
          onDateChanged: (value) {
            setState(() {
              _diagnosisDate = value;
            });
          },
        );
      case 5:
        return _UnitSelectStep(
          key: const ValueKey('glucose_unit'),
          options: _unitOptions,
          selectedUnit: _glucoseUnit,
          onSelect: (value) {
            setState(() {
              _glucoseUnit = value;
            });
          },
        );
      case 6:
        return _SingleSelectStep(
          key: const ValueKey('cgm_sensor'),
          title: 'CGM Sensor',
          description: 'Which sensor are you pairing\nwith this app?',
          options: _cgmSensors,
          selected: _cgmSensor,
          onSelect: (value) {
            setState(() {
              _cgmSensor = value;
            });
          },
        );
      case 7:
        return _DescriptionInputStep(
          key: const ValueKey('hba1c'),
          title: 'HbA1c at Baseline',
          description: 'Enter your most recent HbA1c reading.',
          hint: 'Enter reading',
          helperText: 'If unknown, we\'ll estimate from your CGM data.',
          controller: _hba1cController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        );
      case 8:
        return _TargetRangeStep(
          key: const ValueKey('target_range'),
          lowController: _lowThresholdController,
          highController: _highThresholdController,
        );
      case 9:
        return _MultiSelectStep(
          key: const ValueKey('medications'),
          title: 'Current Medications',
          description: 'Select all medications you are\ncurrently taking.',
          options: _medicationOptions,
          selectedValues: _medications,
          onToggle: (value) {
            setState(() {
              if (_medications.contains(value)) {
                _medications.remove(value);
              } else {
                _medications.add(value);
              }
            });
          },
        );
      case 10:
        return _MultiSelectStep(
          key: const ValueKey('comorbidities'),
          title: 'Comorbidities',
          description: 'Do you have any of the following\nconditions?',
          options: _comorbidityOptions,
          selectedValues: _comorbidities,
          onToggle: (value) {
            setState(() {
              if (_comorbidities.contains(value)) {
                _comorbidities.remove(value);
              } else {
                _comorbidities.add(value);
              }
            });
          },
        );
      case 11:
        return _SingleSelectStep(
          key: const ValueKey('activity_level'),
          title: 'Activity Level',
          description: 'How physically active are you on\na typical week?',
          options: _activityOptions,
          selected: _activityLevel,
          onSelect: (value) {
            setState(() {
              _activityLevel = value;
            });
          },
        );
      case 12:
        return _DietaryPatternStep(
          key: const ValueKey('dietary_pattern'),
          options: _dietaryOptions,
          selected: _dietaryPattern,
          onSelect: (value) {
            setState(() {
              _dietaryPattern = value;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _OnboardingProgressHeader extends StatelessWidget {
  const _OnboardingProgressHeader({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          backgroundColor: const Color(0xFFD7D8DB),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    required super.key,
    required this.questionIndex,
    required this.totalQuestions,
  });

  final int questionIndex;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('welcome_scroll'),
      padding: const EdgeInsets.fromLTRB(30, 80, 30, 24),
      children: [
        const Text(
          'Welcome to CGM',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52 / 2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Before you begin, let\'s take a few minutes\nto learn more about you!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48 / 2,
            height: 1.25,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class _NumericInputStep extends StatelessWidget {
  const _NumericInputStep({
    required super.key,
    required this.title,
    required this.hint,
    required this.controller,
  });

  final String title;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: ValueKey('numeric_$title'),
      padding: const EdgeInsets.fromLTRB(32, 56, 32, 24),
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 54 / 2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 28),
        _OnboardingTextField(
          controller: controller,
          hint: hint,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }
}

class _SingleSelectStep extends StatelessWidget {
  const _SingleSelectStep({
    required super.key,
    required this.title,
    this.description,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final String? description;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: ValueKey('single_$title'),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 52 / 2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 16),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48 / 2,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.72),
            ),
          ),
        ],
        const SizedBox(height: 30),
        for (final option in options) ...[
          _SelectableCard(
            title: option,
            selected: selected == option,
            onTap: () => onSelect(option),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _DescriptionInputStep extends StatelessWidget {
  const _DescriptionInputStep({
    required super.key,
    required this.title,
    required this.description,
    required this.hint,
    required this.helperText,
    required this.controller,
    this.keyboardType,
  });

  final String title;
  final String description;
  final String hint;
  final String helperText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: ValueKey('desc_$title'),
      padding: const EdgeInsets.fromLTRB(32, 26, 32, 12),
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 52 / 2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48 / 2,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 34),
        _OnboardingTextField(
          controller: controller,
          hint: hint,
          keyboardType: keyboardType,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            helperText,
            style: const TextStyle(
              fontSize: 18 / 2 * 2,
              height: 1.3,
              color: Color(0xFF6F737A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _TargetRangeStep extends StatelessWidget {
  const _TargetRangeStep({
    required super.key,
    required this.lowController,
    required this.highController,
  });

  final TextEditingController lowController;
  final TextEditingController highController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('target_range_scroll'),
      padding: const EdgeInsets.fromLTRB(32, 26, 32, 12),
      children: [
        const Text(
          'Target Glucose Range',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52 / 2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Set your personal time-in-range targets.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48 / 2,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 34),
        _OnboardingTextField(
          controller: lowController,
          hint: 'Low Threshold',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        _OnboardingTextField(
          controller: highController,
          hint: 'High Threshold',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Standard TIR target: 70–180 mg/dL for ≥70% of time.',
            style: TextStyle(
              fontSize: 18 / 2 * 2,
              height: 1.3,
              color: Color(0xFF6F737A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _MultiSelectStep extends StatelessWidget {
  const _MultiSelectStep({
    required super.key,
    required this.title,
    required this.description,
    required this.options,
    required this.selectedValues,
    required this.onToggle,
  });

  final String title;
  final String description;
  final List<String> options;
  final Set<String> selectedValues;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: ValueKey('multi_$title'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 52 / 2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48 / 2,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 26),
        for (final option in options) ...[
          _SelectableCard(
            title: option,
            selected: selectedValues.contains(option),
            onTap: () => onToggle(option),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _DietaryPatternStep extends StatelessWidget {
  const _DietaryPatternStep({
    required super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<_ChoiceOption> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('dietary_pattern_scroll'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      children: [
        const Text(
          'Dietary Pattern',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52 / 2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Which best describes your current\neating pattern?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48 / 2,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 26),
        for (final option in options) ...[
          _SelectableCard(
            title: option.title,
            subtitle: option.subtitle,
            selected: selected == option.title,
            onTap: () => onSelect(option.title),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _DateDiagnosisStep extends StatelessWidget {
  const _DateDiagnosisStep({
    required super.key,
    required this.date,
    required this.onDateChanged,
  });

  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('diagnosis_date_scroll'),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
      children: [
        const Text(
          'Date of Diagnosis',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52 / 2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 34),
        Container(
          height: 210,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(14),
          ),
          child: CupertinoTheme(
            data: const CupertinoThemeData(brightness: Brightness.light),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: date,
              minimumDate: DateTime(1950, 1, 1),
              maximumDate: DateTime.now(),
              onDateTimeChanged: onDateChanged,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _UnitSelectStep extends StatelessWidget {
  const _UnitSelectStep({
    required super.key,
    required this.options,
    required this.selectedUnit,
    required this.onSelect,
  });

  final List<_UnitOption> options;
  final String? selectedUnit;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('glucose_unit_scroll'),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      children: [
        const Text(
          'Glucose Unit',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52 / 2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 34),
        for (final option in options) ...[
          _SelectableCard(
            title: option.unit,
            subtitle: option.helperText,
            selected: selectedUnit == option.unit,
            onTap: () => onSelect(option.unit),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _OnboardingTextField extends StatelessWidget {
  const _OnboardingTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF6B6F75),
            fontSize: 42 / 2,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD9DADC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD9DADC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1F2933), width: 1.2),
          ),
        ),
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFF111111) : const Color(0xFFD9DADC),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: const TextStyle(
                          fontSize: 19 / 2 * 2,
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null)
                        TextSpan(
                          text: ' $subtitle',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B6F75),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF111111) : const Color(0xFFF1F1F2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: selected ? const Color(0xFF111111) : const Color(0xFFE1E2E4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 74,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          disabledBackgroundColor: const Color(0xFF7B7C87),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 42 / 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _UnitOption {
  const _UnitOption(this.unit, this.helperText);

  final String unit;
  final String helperText;
}

class _ChoiceOption {
  const _ChoiceOption(this.title, {this.subtitle});

  final String title;
  final String? subtitle;
}
