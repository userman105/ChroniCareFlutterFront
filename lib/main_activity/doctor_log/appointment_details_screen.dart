import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/appointment_entry.dart';
import 'appointment_log_screen.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  const AppointmentDetailsScreen({super.key});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour == 0
        ? 12
        : dt.hour > 12
        ? dt.hour - 12
        : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  String _timeUntil(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.isNegative) return 'Past';
    if (diff.inDays > 0) return 'In ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
    if (diff.inHours > 0) return 'In ${diff.inHours}h ${diff.inMinutes % 60}m';
    if (diff.inMinutes > 0) return 'In ${diff.inMinutes} min';
    return 'Now';
  }

  @override
  Widget build(BuildContext context) {
    final all = List<AppointmentEntry>.from(
      context.watch<HealthCubit>().getAppointments(),
    )..sort((a, b) =>
        a.appointmentDateTime.compareTo(b.appointmentDateTime));

    final upcoming = all
        .where((e) => e.appointmentDateTime.isAfter(DateTime.now()))
        .toList();
    final past = all
        .where((e) =>
    !e.appointmentDateTime.isAfter(DateTime.now()))
        .toList()
        .reversed
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [

            // ── Top bar ──────────────────────────────────────
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: const Color(0xFF2D2D2D),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text('Appointments',
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const AppointmentLogScreen()),
                    ),
                    child: Image.asset('assets/icons/add.png',
                        width: 26, height: 26),
                  ),
                ],
              ),
            ),

            Expanded(
              child: all.isEmpty
                  ? _emptyState(context)
                  : ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // ── Upcoming ────────────────────────
                  if (upcoming.isNotEmpty) ...[
                    _sectionHeader('Upcoming',
                        const Color(0xFF00C950)),
                    const SizedBox(height: 10),
                    ...upcoming.map((e) =>
                        _appointmentCard(context, e)),
                    const SizedBox(height: 20),
                  ],

                  // ── Past ─────────────────────────────
                  if (past.isNotEmpty) ...[
                    _sectionHeader(
                        'Past', Colors.white38),
                    const SizedBox(height: 10),
                    ...past.map((e) =>
                        _appointmentCard(context, e,
                            isPast: true)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF00C950).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month_outlined,
                color: Color(0xFF00C950), size: 32),
          ),
          const SizedBox(height: 16),
          Text('No appointments yet',
              style: GoogleFonts.arimo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Tap + to schedule one',
              style: GoogleFonts.arimo(
                  color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 24),
          Builder(builder: (context) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const AppointmentLogScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color:
                  const Color(0xFF00C950).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF00C950)
                          .withOpacity(0.4)),
                ),
                child: Text('Add appointment',
                    style: GoogleFonts.arimo(
                        color: const Color(0xFF00C950),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────
  Widget _sectionHeader(String label, Color color) {
    return Row(
      children: [
        Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.arimo(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
      ],
    );
  }

  // ── Appointment card ──────────────────────────────────────────────────────
  Widget _appointmentCard(BuildContext context, AppointmentEntry e,
      {bool isPast = false}) {
    final accent =
    isPast ? Colors.white24 : const Color(0xFF00C950);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showDetails(context, e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: ShapeDecoration(
          color: const Color(0xFF2D2D2D),
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: isPast
                    ? Colors.white12
                    : const Color(0xFF00C950).withOpacity(0.3),
                width: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          children: [
            // ── Date sidebar ───────────────────────────────
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    e.appointmentDateTime.day.toString(),
                    style: GoogleFonts.arimo(
                        color: isPast ? Colors.white38 : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    const [
                      'Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec',
                    ][e.appointmentDateTime.month - 1],
                    style: GoogleFonts.arimo(
                        color: accent, fontSize: 12),
                  ),
                ],
              ),
            ),

            // ── Info ───────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.appointmentName,
                      style: GoogleFonts.arimo(
                        color: isPast
                            ? Colors.white54
                            : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: Colors.white38, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(e.appointmentDateTime),
                          style: GoogleFonts.arimo(
                              color: Colors.white54,
                              fontSize: 12),
                        ),
                      ],
                    ),
                    if (e.location != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.white38, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              e.location!,
                              style: GoogleFonts.arimo(
                                  color: Colors.white38,
                                  fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Time until chip ────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _timeUntil(e.appointmentDateTime),
                      style: GoogleFonts.arimo(
                          color: isPast
                              ? Colors.white24
                              : accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Icon(Icons.chevron_right,
                      color: Colors.white24, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Detail sheet ──────────────────────────────────────────────────────────
  void _showDetails(BuildContext context, AppointmentEntry e) {
    final isPast =
    !e.appointmentDateTime.isAfter(DateTime.now());
    final accent =
    isPast ? Colors.white54 : const Color(0xFF00C950);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.calendar_month_outlined,
                      color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.appointmentName,
                    style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPast ? 'Past' : _timeUntil(e.appointmentDateTime),
                    style: GoogleFonts.arimo(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Date
            _detailRow(
              icon: Icons.calendar_today_outlined,
              label: _formatDate(e.appointmentDateTime),
            ),
            const SizedBox(height: 10),

            // Time
            _detailRow(
              icon: Icons.access_time,
              label: _formatTime(e.appointmentDateTime),
            ),

            if (e.location != null) ...[
              const SizedBox(height: 10),
              _detailRow(
                icon: Icons.location_on_outlined,
                label: e.location!,
              ),
            ],

            if (e.notes != null &&
                e.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _detailRow(
                icon: Icons.notes_outlined,
                label: e.notes!,
              ),
            ],

            const SizedBox(height: 24),

            // Delete
            GestureDetector(
              onTap: () {
                context
                    .read<HealthCubit>()
                    .deleteAppointment(e);
                Navigator.pop(context);
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.red.withOpacity(0.3)),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 18),
                      const SizedBox(width: 6),
                      Text('Delete Appointment',
                          style: GoogleFonts.arimo(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({required IconData icon, required String label}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: GoogleFonts.arimo(
                  color: Colors.white70, fontSize: 14)),
        ),
      ],
    );
  }

}