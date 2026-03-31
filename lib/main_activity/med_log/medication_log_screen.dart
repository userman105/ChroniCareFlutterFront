import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/med_entry.dart';
import '../../widgets/components.dart';
import 'medication_reminder_screen.dart';

class MedicationLogScreen extends StatefulWidget {
  const MedicationLogScreen({super.key});

  @override
  State<MedicationLogScreen> createState() => _MedicationLogScreenState();
}

class _MedicationLogScreenState extends State<MedicationLogScreen> {
  List<Map<String, String>> _allMeds = [];
  bool _csvLoaded = false;
  final List<_MedInput> _meds = [];

  // Date/time state (mirrors LogEntryScreen internals)
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _currentDate = '';
  String _currentTime = '';

  final _notesCtrl = TextEditingController();

  bool get _canSubmit =>
      _meds.isNotEmpty && _meds.every((m) => m.isValid);

  @override
  void initState() {
    super.initState();
    _loadCsv();
    _selectedDate = context.read<HealthCubit>().getSelectedDate();
    _updateDateLabel(_selectedDate);
    _updateTimeLabel(_selectedTime);
  }

  Future<void> _loadCsv() async {
    final raw =
    await rootBundle.loadString('assets/data/medications.csv');
    final lines = raw.split('\n');
    final result = <Map<String, String>>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final cols = line.split(',');
      if (cols.length >= 2) {
        result.add({
          'arabic': cols[0].trim(),
          'english': cols[1].trim(),
        });
      }
    }
    setState(() { _allMeds = result; _csvLoaded = true; });
  }

  String _monthName(int m) => const [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ][m - 1];

  void _updateDateLabel(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    setState(() {
      _currentDate = isToday
          ? 'Today: ${_monthName(date.month)} ${date.day}'
          : '${_monthName(date.month)} ${date.day}';
    });
  }

  void _updateTimeLabel(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final p = t.period == DayPeriod.pm ? 'pm' : 'am';
    setState(() =>
    _currentTime = '$h:${t.minute.toString().padLeft(2, '0')}$p');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _updateDateLabel(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked =
    await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked == null) return;
    final now = DateTime.now();
    final candidate = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, picked.hour, picked.minute);
    if (candidate.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Future time cannot be selected')),
      );
      return;
    }
    setState(() => _selectedTime = picked);
    _updateTimeLabel(picked);
  }

  void _submit() {
    final dt = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    for (final med in _meds) {
      context.read<HealthCubit>().addMedication(MedicationEntry(
        medicationName: med.name!,
        isCustom: med.isCustom,
        dose: med.dose ?? 0,
        doseUnit: med.doseUnit,
        form: med.form,
        quantity: med.quantity,
        dateTime: dt,
        notes: _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFF212121),
      body: SafeArea(
        child: Column(
          children: [

            Container(
              height: 46,
              color: const Color(0xFF2D2D2D),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Log Medication',
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),


            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Date/Time
                    Text('Date/Time:',
                        style: GoogleFonts.arimo(
                            color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _chip(
                          onTap: _pickDate,
                          icon: 'assets/icons/calendar.png',
                          label: _currentDate,
                        ),
                        const SizedBox(width: 10),
                        _chip(
                          onTap: _pickTime,
                          icon: 'assets/icons/clock.png',
                          label: _currentTime,
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    ...List.generate(_meds.length, (i) => AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: _MedTile(
                        key: ValueKey(i),
                        input: _meds[i],
                        allMeds: _allMeds,
                        csvLoaded: _csvLoaded,
                        onRemove: () =>
                            setState(() => _meds.removeAt(i)),
                        onChanged: () => setState(() {}),
                      ),
                    )),

                    // ── Add medication button ─────────────────
                    GestureDetector(
                      onTap: () => setState(() => _meds.add(_MedInput())),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add,
                                color: Color(0xFF00C950), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              _meds.isEmpty
                                  ? 'Add Medication'
                                  : 'Add Another',
                              style: GoogleFonts.arimo(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    if (true) ...[  // replace with your onAddReminder condition if needed
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MedicationReminderScreen(),
                          ),
                        ),
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/icons/bell.png", width: 18, height: 18),
                              const SizedBox(width: 6),
                              Text(
                                "Add reminder",
                                style: GoogleFonts.arimo(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],



                    // Notes
                    Text('Notes',
                        style: GoogleFonts.arimo(
                            color: Colors.white, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'eg. take after food',
                        hintStyle: GoogleFonts.arimo(
                            color: const Color(0xFFB4B4B4)),
                        filled: true,
                        fillColor: const Color(0xFF0C0C0C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Pinned Add button ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: MainButton(
                text: 'Add',
                enabled: _canSubmit,
                onTap: _canSubmit ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
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
          color: const Color(0xFF313131),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 14, height: 14),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.arimo(
                    color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MedInput {
  String? name;
  bool isCustom = false;
  double? dose;
  String doseUnit = 'mg';
  String form = 'tablet';
  int quantity = 1;
  bool get isValid => name != null && name!.isNotEmpty && dose != null;
}

class _MedTile extends StatefulWidget {
  final _MedInput input;
  final List<Map<String, String>> allMeds;
  final bool csvLoaded;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _MedTile({
    super.key,
    required this.input,
    required this.allMeds,
    required this.csvLoaded,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_MedTile> createState() => _MedTileState();
}

class _MedTileState extends State<_MedTile> {
  final _searchCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  List<Map<String, String>> _results = [];
  bool _showResults = false;
  bool _nameConfirmed = false;

  final _units = ['mg', 'ml', 'mcg', 'IU', 'g'];
  final _forms = [
    'tablet', 'capsule', 'syrup', 'injection', 'drops', 'inhaler', 'patch'
  ];

  @override
  void initState() {
    super.initState();
    _doseCtrl.addListener(() {
      widget.input.dose = double.tryParse(_doseCtrl.text);
      widget.onChanged();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    if (q.isEmpty) {
      setState(() { _results = []; _showResults = false; });
      return;
    }
    final ql = q.toLowerCase();
    final filtered = widget.allMeds
        .where((m) =>
    m['english']!.toLowerCase().contains(ql) ||
        m['arabic']!.contains(q))
        .take(8)
        .toList();
    setState(() { _results = filtered; _showResults = true; _nameConfirmed = false; });
  }

  void _selectMed(Map<String, String> med) {
    setState(() {
      widget.input.name = med['english'];
      widget.input.isCustom = false;
      _searchCtrl.text = med['english']!;
      _showResults = false;
      _nameConfirmed = true;
    });
    widget.onChanged();
  }

  void _useCustom() {
    setState(() {
      widget.input.name = _searchCtrl.text.trim();
      widget.input.isCustom = true;
      _showResults = false;
      _nameConfirmed = true;
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.medication_outlined,
                      color: Color(0xFF00C950), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.input.name ?? 'Select medication',
                    style: GoogleFonts.arimo(
                      color: widget.input.name != null
                          ? Colors.white
                          : Colors.white38,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onRemove,
                  child: const Icon(Icons.close,
                      color: Colors.white38, size: 18),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search
                TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  style: GoogleFonts.arimo(
                      color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: widget.csvLoaded
                        ? 'Search medication...'
                        : 'Loading...',
                    hintStyle: GoogleFonts.arimo(
                        color: Colors.white38, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF0C0C0C),
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.white38, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                // Results
                if (_showResults) ...[
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        ..._results.map((med) => GestureDetector(
                          onTap: () => _selectMed(med),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white12,
                                      width: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(med['english']!,
                                        style: GoogleFonts.arimo(
                                            color: Colors.white,
                                            fontSize: 13))),
                                Text(med['arabic']!,
                                    style: GoogleFonts.arimo(
                                        color: Colors.white38,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        )),
                        if (_searchCtrl.text.trim().isNotEmpty)
                          GestureDetector(
                            onTap: _useCustom,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.add_circle_outline,
                                      color: Color(0xFF00C950),
                                      size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add "${_searchCtrl.text.trim()}" manually',
                                    style: GoogleFonts.arimo(
                                        color: const Color(0xFF00C950),
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

                // Dose + unit + quantity
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'))
                          ],
                          style: GoogleFonts.arimo(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Dose',
                            hintStyle: GoogleFonts.arimo(
                                color: Colors.white38, fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFF0C0C0C),
                            contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _dropdown<String>(
                        value: widget.input.doseUnit,
                        items: _units,
                        onChanged: (v) {
                          setState(() => widget.input.doseUnit = v);
                          widget.onChanged();
                        },
                      ),
                      const SizedBox(width: 8),
                      _stepper(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _formSelector(),
                  const SizedBox(height: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
          color: const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: const Color(0xFF2D2D2D),
          style: GoogleFonts.arimo(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.arrow_drop_down,
              color: Colors.white38, size: 18),
          items: items
              .map((v) => DropdownMenuItem<T>(
              value: v, child: Text(v.toString())))
              .toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  Widget _stepper() {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (widget.input.quantity > 1) {
                setState(() => widget.input.quantity--);
                widget.onChanged();
              }
            },
            child: Container(
                width: 30, height: 36,
                alignment: Alignment.center,
                child: const Icon(Icons.remove,
                    color: Colors.white54, size: 16)),
          ),
          Text('${widget.input.quantity}',
              style: GoogleFonts.arimo(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          GestureDetector(
            onTap: () {
              setState(() => widget.input.quantity++);
              widget.onChanged();
            },
            child: Container(
                width: 30, height: 36,
                alignment: Alignment.center,
                child: const Icon(Icons.add,
                    color: Colors.white54, size: 16)),
          ),
        ],
      ),
    );
  }

  Widget _formSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _forms.map((f) {
          final active = widget.input.form == f;
          return GestureDetector(
            onTap: () {
              setState(() => widget.input.form = f);
              widget.onChanged();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF00C950).withOpacity(0.15)
                    : const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: active
                        ? const Color(0xFF00C950)
                        : Colors.transparent),
              ),
              child: Text(f,
                  style: GoogleFonts.arimo(
                      color: active
                          ? const Color(0xFF00C950)
                          : Colors.white54,
                      fontSize: 12)),
            ),
          );
        }).toList(),
      ),
    );
  }
}