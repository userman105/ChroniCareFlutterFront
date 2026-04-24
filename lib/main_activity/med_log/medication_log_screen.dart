import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/health_cubit.dart';
import '../../cubit/locale_cubit.dart';
import '../../models/med_entry.dart';
import '../../widgets/components.dart';
import 'medication_reminder_screen.dart';

class MedicationLogScreen extends StatefulWidget {
  const MedicationLogScreen({super.key});

  @override
  State<MedicationLogScreen> createState() =>
      _MedicationLogScreenState();
}

class _MedicationLogScreenState extends State<MedicationLogScreen> {
  List<Map<String, String>> _allMeds  = [];
  bool                      _csvLoaded = false;
  final List<_MedInput>     _meds      = [];

  DateTime  _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String    _currentDate  = '';
  String    _currentTime  = '';

  final _notesCtrl = TextEditingController();

  bool get _canSubmit =>
      _meds.isNotEmpty && _meds.every((m) => m.isValid);

  @override
  void initState() {
    super.initState();
    _loadCsv();
    _selectedDate = context.read<HealthCubit>().getSelectedDate();
    _updateTimeLabel(_selectedTime);
  }

  Future<void> _loadCsv() async {
    final raw =
    await rootBundle.loadString('assets/data/medications.csv');
    final lines  = raw.split('\n');
    final result = <Map<String, String>>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final cols = line.split(',');
      if (cols.length >= 2) {
        result.add({
          'arabic':  cols[0].trim(),
          'english': cols[1].trim(),
        });
      }
    }
    setState(() {
      _allMeds   = result;
      _csvLoaded = true;
    });
  }


  Color _textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  Color _subtextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white54
          : Colors.black54;

  Color _surfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D2D2D)
          : const Color(0xFFF0F0F0);

  Color _inputFill(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0C0C0C)
          : const Color(0xFFE8E8E8);


  void _updateDateLabel(DateTime date, String lang) {
    final now     = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final monthName =
    AppStrings.get('month_${date.month}', lang);
    final month =
    lang == 'ar' ? monthName : monthName.substring(0, 3);
    setState(() {
      _currentDate = isToday
          ? '${AppStrings.get('today_int', lang)}: $month ${date.day}'
          : '$month ${date.day}';
    });
  }

  void _updateTimeLabel(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final p = t.period == DayPeriod.pm ? 'pm' : 'am';
    setState(() =>
    _currentTime = '$h:${t.minute.toString().padLeft(2, '0')}$p');
  }

  Future<void> _pickDate(String lang) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _updateDateLabel(picked, lang);
    }
  }

  Future<void> _pickTime(String lang) async {
    final picked = await showTimePicker(
        context: context, initialTime: _selectedTime);
    if (picked == null) return;
    final now       = DateTime.now();
    final candidate = DateTime(_selectedDate.year,
        _selectedDate.month, _selectedDate.day,
        picked.hour, picked.minute);
    if (candidate.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppStrings.get('future_time_error', lang))));
      return;
    }
    setState(() => _selectedTime = picked);
    _updateTimeLabel(picked);
  }

  void _submit() {
    final dt = DateTime(
        _selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour,
        _selectedTime.minute);

    for (final med in _meds) {
      context.read<HealthCubit>().addMedication(MedicationEntry(
        medicationName: med.name!,
        isCustom:       med.isCustom,
        dose:           med.dose ?? 0,
        doseUnit:       med.doseUnit,
        form:           med.form, // always stored as English key
        quantity:       med.quantity,
        dateTime:       dt,
        notes: _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang    = context.watch<LocaleCubit>().state;
    final primary = Theme.of(context).primaryColor;
    final isRtl   = lang == 'ar';

    // Lazy-init date label on first build
    if (_currentDate.isEmpty) _updateDateLabel(_selectedDate, lang);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [

              Container(
                height: 46,
                color: _surfaceColor(context),
                padding:
                const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isRtl
                            ? Icons.arrow_forward_ios
                            : Icons.arrow_back_ios_new,
                        color: _textColor(context),
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      AppStrings.get('log_medication', lang),
                      style: GoogleFonts.arimo(
                          color: _textColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.fromLTRB(20, 25, 20, 0),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        '${AppStrings.get('date_time', lang)}:',
                        style: GoogleFonts.arimo(
                            color: _textColor(context),
                            fontSize: 16),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _chip(
                            context: context,
                            onTap: () => _pickDate(lang),
                            icon: 'assets/icons/calendar.png',
                            label: _currentDate,
                          ),
                          const SizedBox(width: 10),
                          _chip(
                            context: context,
                            onTap: () => _pickTime(lang),
                            icon: 'assets/icons/clock.png',
                            label: _currentTime,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      ...List.generate(
                          _meds.length,
                              (i) => AnimatedSize(
                            duration: const Duration(
                                milliseconds: 300),
                            curve: Curves.easeOut,
                            child: _MedTile(
                              key: ValueKey(i),
                              input: _meds[i],
                              allMeds: _allMeds,
                              csvLoaded: _csvLoaded,
                              lang: lang,
                              onRemove: () => setState(
                                      () => _meds.removeAt(i)),
                              onChanged: () => setState(() {}),
                            ),
                          )),

                      GestureDetector(
                        onTap: () => setState(
                                () => _meds.add(_MedInput())),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: _surfaceColor(context),
                            borderRadius:
                            BorderRadius.circular(10),
                            border: Border.all(
                                color: _textColor(context)
                                    .withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add,
                                  color: primary, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                _meds.isEmpty
                                    ? AppStrings.get(
                                    'add_medication', lang)
                                    : AppStrings.get(
                                    'add_another', lang),
                                style: GoogleFonts.arimo(
                                    color: _textColor(context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const MedicationReminderScreen()),
                        ),
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: _textColor(context)),
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/icons/bell.png',
                                  width: 18,
                                  height: 18,
                                  color: _textColor(context)),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.get(
                                    'add_reminder_med', lang),
                                style: GoogleFonts.arimo(
                                    color: _textColor(context),
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Text(
                        AppStrings.get('notes', lang),
                        style: GoogleFonts.arimo(
                            color: _textColor(context),
                            fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesCtrl,
                        textDirection: isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: TextStyle(
                            color: _textColor(context)),
                        decoration: InputDecoration(
                          hintText: AppStrings.get(
                              'eg_take_after_food', lang),
                          hintStyle: GoogleFonts.arimo(
                              color: _subtextColor(context)),
                          filled: true,
                          fillColor: _inputFill(context),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(4),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: MainButton(
                  text: AppStrings.get('add', lang),
                  enabled: _canSubmit,
                  onTap: _canSubmit ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required BuildContext context,
    required VoidCallback onTap,
    required String icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _surfaceColor(context),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Image.asset(icon,
                width: 14,
                height: 14,
                color: _textColor(context)),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.arimo(
                    color: _textColor(context), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}


class _MedInput {
  String? name;
  bool    isCustom  = false;
  double? dose;
  String  doseUnit  = 'mg';
  String  form      = 'tablet'; // always the English key
  int     quantity  = 1;
  bool get isValid =>
      name != null && name!.isNotEmpty && dose != null;
}


class _MedTile extends StatefulWidget {
  final _MedInput              input;
  final List<Map<String, String>> allMeds;
  final bool                   csvLoaded;
  final String                 lang;
  final VoidCallback           onRemove;
  final VoidCallback           onChanged;

  const _MedTile({
    super.key,
    required this.input,
    required this.allMeds,
    required this.csvLoaded,
    required this.lang,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_MedTile> createState() => _MedTileState();
}

class _MedTileState extends State<_MedTile> {
  final _searchCtrl = TextEditingController();
  final _doseCtrl   = TextEditingController();
  List<Map<String, String>> _results    = [];
  bool                      _showResults   = false;
  bool                      _nameConfirmed = false;

  // English keys — localised at display time via AppStrings
  static const _units = ['mg', 'ml', 'mcg', 'IU', 'g'];
  static const _formKeys = [
    'tablet', 'capsule', 'syrup',
    'injection', 'drops', 'inhaler', 'patch',
  ];


  Color _textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  Color _inputFill(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0C0C0C)
          : const Color(0xFFE8E8E8);

  Color _tileColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white;

  Color _surfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D2D2D)
          : const Color(0xFFF0F0F0);

  String _localForm(String key) {
    const map = {
      'tablet':    'form_tablet',
      'capsule':   'form_capsule',
      'syrup':     'form_syrup',
      'injection': 'form_injection',
      'drops':     'form_drops',
      'inhaler':   'form_inhaler',
      'patch':     'form_patch',
    };
    return AppStrings.get(map[key] ?? key, widget.lang);
  }

  @override
  void initState() {
    super.initState();
    _doseCtrl.addListener(() {
      widget.input.dose = double.tryParse(_doseCtrl.text);
      widget.onChanged();
    });
  }

  void _onSearch(String q) {
    if (q.isEmpty) {
      setState(() {
        _results     = [];
        _showResults = false;
      });
      return;
    }
    final ql       = q.toLowerCase();
    final filtered = widget.allMeds
        .where((m) =>
    m['english']!.toLowerCase().contains(ql) ||
        m['arabic']!.contains(q))
        .take(8)
        .toList();
    setState(() {
      _results       = filtered;
      _showResults   = true;
      _nameConfirmed = false;
    });
  }

  void _selectMed(Map<String, String> med) {
    setState(() {
      widget.input.name     = med['english'];
      widget.input.isCustom = false;
      _searchCtrl.text      = med['english']!;
      _showResults          = false;
      _nameConfirmed        = true;
    });
    widget.onChanged();
  }

  void _useCustom() {
    setState(() {
      widget.input.name     = _searchCtrl.text.trim();
      widget.input.isCustom = true;
      _showResults          = false;
      _nameConfirmed        = true;
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final lang    = widget.lang;
    final primary = Theme.of(context).primaryColor;
    final isRtl   = lang == 'ar';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _tileColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _textColor(context).withOpacity(0.1)),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: _surfaceColor(context),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.medication_outlined,
                      color: primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.input.name ??
                        AppStrings.get('select_medication', lang),
                    style: GoogleFonts.arimo(
                      color: widget.input.name != null
                          ? _textColor(context)
                          : _textColor(context).withOpacity(0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Icon(Icons.close,
                      color: _textColor(context).withOpacity(0.4),
                      size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  textDirection: isRtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: GoogleFonts.arimo(
                      color: _textColor(context), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: widget.csvLoaded
                        ? AppStrings.get(
                        'search_medication', lang)
                        : AppStrings.get('loading_meds', lang),
                    hintStyle: GoogleFonts.arimo(
                        color:
                        _textColor(context).withOpacity(0.4),
                        fontSize: 14),
                    filled: true,
                    fillColor: _inputFill(context),
                    prefixIcon: Icon(Icons.search,
                        color:
                        _textColor(context).withOpacity(0.4),
                        size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                ),

                if (_showResults) ...[
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: _surfaceColor(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _textColor(context)
                              .withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        ..._results.map((med) => GestureDetector(
                          onTap: () => _selectMed(med),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets
                                .symmetric(
                                horizontal: 12,
                                vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: _textColor(context)
                                        .withOpacity(0.1)),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    med['english']!,
                                    style: GoogleFonts.arimo(
                                        color: _textColor(
                                            context),
                                        fontSize: 13),
                                  ),
                                ),
                                Text(
                                  med['arabic']!,
                                  style: GoogleFonts.arimo(
                                      color: _textColor(context)
                                          .withOpacity(0.4),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )),
                        if (_searchCtrl.text.trim().isNotEmpty)
                          GestureDetector(
                            onTap: _useCustom,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Icon(
                                      Icons.add_circle_outline,
                                      color: primary,
                                      size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${AppStrings.get('add', lang)} "${_searchCtrl.text.trim()}"',
                                    style: GoogleFonts.arimo(
                                        color: primary,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (_nameConfirmed) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _doseCtrl,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                          style: GoogleFonts.arimo(
                              color: _textColor(context),
                              fontSize: 14),
                          decoration: InputDecoration(
                            hintText: AppStrings.get('dose', lang),
                            hintStyle: GoogleFonts.arimo(
                                color: _textColor(context)
                                    .withOpacity(0.4),
                                fontSize: 13),
                            filled: true,
                            fillColor: _inputFill(context),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _dropdown<String>(
                          value: widget.input.doseUnit,
                          items: _units,
                          onChanged: (v) {
                            setState(
                                    () => widget.input.doseUnit = v);
                            widget.onChanged();
                          }),
                      const SizedBox(width: 8),
                      _stepper(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _formSelector(lang),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required void Function(T) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: _inputFill(context),
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: _surfaceColor(context),
          style: GoogleFonts.arimo(
              color: _textColor(context), fontSize: 13),
          icon: Icon(Icons.arrow_drop_down,
              color: _textColor(context).withOpacity(0.4),
              size: 18),
          items: items
              .map((v) => DropdownMenuItem<T>(
              value: v, child: Text(v.toString())))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _stepper() {
    return Container(
      decoration: BoxDecoration(
          color: _inputFill(context),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (widget.input.quantity > 1) {
                setState(() => widget.input.quantity--);
                widget.onChanged();
              }
            },
            icon: Icon(Icons.remove,
                size: 16, color: _textColor(context)),
          ),
          Text('${widget.input.quantity}',
              style: GoogleFonts.arimo(
                  color: _textColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          IconButton(
            onPressed: () {
              setState(() => widget.input.quantity++);
              widget.onChanged();
            },
            icon: Icon(Icons.add,
                size: 16, color: _textColor(context)),
          ),
        ],
      ),
    );
  }

  Widget _formSelector(String lang) {
    final primary = Theme.of(context).primaryColor;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _formKeys.map((key) {
          final active = widget.input.form == key;
          return GestureDetector(
            onTap: () {
              setState(() => widget.input.form = key);
              widget.onChanged();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: active
                    ? primary.withOpacity(0.15)
                    : _surfaceColor(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: active ? primary : Colors.transparent),
              ),
              child: Text(
                _localForm(key),
                style: GoogleFonts.arimo(
                    color: active
                        ? primary
                        : _textColor(context).withOpacity(0.5),
                    fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}