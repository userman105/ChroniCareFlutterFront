import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment_entry.dart';
import '../models/blood_pressure_entry.dart';
import '../models/food_entry.dart';
import '../models/glucose_entry.dart';
import '../models/labTest_entry.dart';
import '../models/med_entry.dart';
import '../models/symptom_entry.dart';
import '../models/weight_entry.dart';

import '../cubit/health_cubit.dart';

class PdfExportService {

  static Future<File> exportHealthReport({
    required HealthCubit cubit,
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {

    final pdf = pw.Document();

    final logoBytes =
    (await rootBundle.load('assets/logos/appIcon.png'))
        .buffer
        .asUint8List();


    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('is_guest') ?? false;

    final String? userName   = prefs.getString('name');
    final String? userEmail  = prefs.getString('email');
    final String? userGender = prefs.getString('gender');
    final String? userDob    = prefs.getString('birthday') // "MM / DD / YYYY"
        ?? prefs.getString('dob');                        // "YYYY-MM-DD" fallback


    int? userAge;
    if (!isGuest && userDob != null) {
      userAge = _calculateAge(userDob);
    }

    bool inRange(DateTime dt) {
      if (startDate == null || endDate == null) return true;

      return dt.isAfter(
          startDate.subtract(const Duration(days: 1))) &&
          dt.isBefore(
              endDate.add(const Duration(days: 1)));
    }

    final blood =
    cubit.getEntries().where((e) => inRange(e.dateTime)).toList();

    final glucose =
    cubit.getGlucoseEntries()
        .where((e) => inRange(e.dateTime))
        .toList();

    final weight =
    cubit.getWeightEntries()
        .where((e) => inRange(e.dateTime))
        .toList();

    final meds =
    cubit.getMedicationEntries()
        .where((e) => inRange(e.dateTime))
        .toList();

    final food =
    cubit.getFoodEntries()
        .where((e) => inRange(e.dateTime))
        .toList();

    final symptoms =
    cubit.getSymptomEntries()
        .where((e) => inRange(e.dateTime))
        .toList();

    final appointments =
    cubit.getAppointments()
        .where((e) => inRange(e.appointmentDateTime))
        .toList();

    final labs =
    cubit.getLabTests()
        .where((e) => inRange(e.testDate))
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(32),
        ),
        build: (context) => [


          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [

              pw.Image(
                pw.MemoryImage(logoBytes),
                width: 55,
                height: 55,
              ),

              pw.SizedBox(width: 18),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [

                  pw.Text(
                    'ChroniCare Health Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 4),

                  pw.Text(
                    'Generated on ${DateFormat.yMMMMd().format(DateTime.now())}',
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 24),

          if (!isGuest) ...[
            pw.Text(
              'Patient Details',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            _patientDetailsTable([
              if (userName  != null) ['Name',   userName],
              if (userEmail != null) ['Email',  userEmail],
              if (userGender != null) ['Gender', userGender],
              if (userAge   != null) ['Age',    '$userAge years'],
            ]),

            pw.SizedBox(height: 24),
          ],

          pw.Text(
            'Export Summary',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 12),

          _summaryTable([
            ['Blood Pressure Logs', blood.length.toString()],
            ['Glucose Logs',        glucose.length.toString()],
            ['Weight Logs',         weight.length.toString()],
            ['Medication Logs',     meds.length.toString()],
            ['Food Logs',           food.length.toString()],
            ['Symptom Logs',        symptoms.length.toString()],
            ['Appointments',        appointments.length.toString()],
            ['Lab Tests',           labs.length.toString()],
          ]),

          pw.SizedBox(height: 28),

          ..._bloodPressureSection(blood),
          ..._glucoseSection(glucose),
          ..._weightSection(weight),
          ..._medicationSection(meds),
          ..._foodSection(food),
          ..._symptomSection(symptoms),
          ..._appointmentSection(appointments),
          ..._labSection(labs),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final reportsDir = Directory('${dir.path}/reports');

    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final file = File(
      '${reportsDir.path}/health_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Handles two stored formats:
  //   "MM / DD / YYYY"  (from login flow → prefs key "birthday")
  //   "YYYY-MM-DD"      (from register flow → prefs key "dob")
  static int? _calculateAge(String dobRaw) {
    try {
      DateTime? dob;

      final trimmed = dobRaw.trim();

      if (trimmed.contains('/')) {
        // "MM / DD / YYYY"  →  remove spaces around slashes
        final parts = trimmed
            .split('/')
            .map((s) => s.trim())
            .toList();

        if (parts.length == 3) {
          final month = int.parse(parts[0]);
          final day   = int.parse(parts[1]);
          final year  = int.parse(parts[2]);
          dob = DateTime(year, month, day);
        }
      } else if (trimmed.contains('-')) {
        // "YYYY-MM-DD"
        dob = DateTime.parse(trimmed);
      }

      if (dob == null) return null;

      final today = DateTime.now();
      int age = today.year - dob.year;

      // Subtract 1 if birthday hasn't occurred yet this year
      final hadBirthday = (today.month > dob.month) ||
          (today.month == dob.month && today.day >= dob.day);

      if (!hadBirthday) age--;

      return age < 0 ? null : age;
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _patientDetailsTable(List<List<String>> rows) {
    if (rows.isEmpty) return pw.SizedBox();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FixedColumnWidth(120),
        1: const pw.FlexColumnWidth(),
      },
      children: rows.map((row) {
        return pw.TableRow(
          children: [
            _cell(row[0], bold: true),
            _cell(row[1]),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _summaryTable(List<List<String>> rows) {
    return pw.Table.fromTextArray(
      headers: ['Section', 'Entries'],
      data: rows,
      border: pw.TableBorder.all(
        color: PdfColors.grey400,
      ),
    );
  }

  static List<pw.Widget> _bloodPressureSection(
      List<BloodPressureEntry> entries,
      ) {
    if (entries.isEmpty) return [];

    return [
      _title('Blood Pressure Logs'),

      pw.Table.fromTextArray(
        headers: [
          'Date',
          'Systolic',
          'Diastolic',
          'Heart Rate',
        ],
        data: entries.map<List<String>>((e) {
          return [
            DateFormat.yMd().add_jm().format(e.dateTime),
            '${e.systolic}',
            '${e.diastolic}',
            '${e.heartRate ?? '-'}',
          ];
        }).toList(),
      ),

      pw.SizedBox(height: 20),
    ];
  }

  static List<pw.Widget> _glucoseSection(
      List<GlucoseEntry> entries,
      ) {
    if (entries.isEmpty) return [];

    return [
      _title('Glucose Logs'),

      pw.Table.fromTextArray(
        headers: ['Date', 'Value', 'Unit'],
        data: entries.map<List<String>>((e) {
          return [
            DateFormat.yMd().add_jm().format(e.dateTime),
            '${e.value}',
            e.unit,
          ];
        }).toList(),
      ),

      pw.SizedBox(height: 20),
    ];
  }

  static List<pw.Widget> _weightSection(
      List<WeightEntry> entries,
      ) {
    if (entries.isEmpty) return [];

    return [
      _title('Weight Logs'),

      pw.Table.fromTextArray(
        headers: ['Date', 'KG', 'LBS'],
        data: entries.map<List<String>>((e) {
          return [
            DateFormat.yMd().format(e.dateTime),
            '${e.kg ?? '-'}',
            '${e.lbs ?? '-'}',
          ];
        }).toList(),
      ),

      pw.SizedBox(height: 20),
    ];
  }

  static List<pw.Widget> _medicationSection(
      List<MedicationEntry> entries,
      ) {
    if (entries.isEmpty) return [];

    return [
      _title('Medication Logs'),

      pw.Table.fromTextArray(
        headers: [
          'Medication',
          'Dose',
          'Quantity',
          'Date',
        ],
        data: entries.map<List<String>>((e) {
          return [
            e.medicationName,
            '${e.dose} ${e.doseUnit}',
            '${e.quantity}',
            DateFormat.yMd().add_jm().format(e.dateTime),
          ];
        }).toList(),
      ),

      pw.SizedBox(height: 20),
    ];
  }

  static List<pw.Widget> _foodSection(
      List<FoodEntry> entries,
      ) {
    if (entries.isEmpty) return [];

    return [
      _title('Food Logs'),

      pw.Table.fromTextArray(
        headers: [
          'Food',
          'Meal',
          'Calories',
          'Date',
        ],
        data: entries.map<List<String>>((e) {
          return [
            e.name,
            e.mealType ?? '-',
            '${e.calories ?? '-'}',
            DateFormat.yMd().add_jm().format(e.dateTime),
          ];
        }).toList(),
      ),

      pw.SizedBox(height: 20),
    ];
  }

  static List<pw.Widget> _symptomSection(
      List<SymptomEntry> entries,
      ) {
    if (entries.isEmpty) return [];

    return [
      _title('Symptom Logs'),

      pw.Table.fromTextArray(
        headers: [
          'Symptom',
          'Severity',
          'Date',
        ],
        data: entries.map<List<String>>((e) {
          return [
            e.symptom,
            '${e.severity}/10',
            DateFormat.yMd().add_jm().format(e.dateTime),
          ];
        }).toList(),
      ),

      pw.SizedBox(height: 20),
    ];
  }

  static List<pw.Widget> _appointmentSection(
      List<AppointmentEntry> entries,
      ) {
    if (entries.isEmpty) return [];

    return [
      _title('Appointments'),

      pw.Table.fromTextArray(
        headers: [
          'Appointment',
          'Location',
          'Date',
        ],
        data: entries.map<List<String>>((e) {
          return [
            e.appointmentName,
            e.location ?? '-',
            DateFormat.yMd().add_jm().format(
              e.appointmentDateTime,
            ),
          ];
        }).toList(),
      ),

      pw.SizedBox(height: 20),
    ];
  }

  static List<pw.Widget> _labSection(
      List<LabTestEntry> entries,
      ) {
    if (entries.isEmpty) return [];

    return [
      _title('Lab Tests'),

      pw.Table.fromTextArray(
        headers: [
          'Test',
          'Date',
          'Notes',
        ],
        data: entries.map<List<String>>((e) {
          return [
            e.testName,
            DateFormat.yMd().format(e.testDate),
            e.notes ?? '-',
          ];
        }).toList(),
      ),

      pw.SizedBox(height: 20),
    ];
  }

  static pw.Widget _title(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10, top: 14),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }
}