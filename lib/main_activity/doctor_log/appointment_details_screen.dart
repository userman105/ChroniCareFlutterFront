import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/appointment_entry.dart';
import '../../widgets/components.dart';
import 'appointment_log_screen.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  const AppointmentDetailsScreen({super.key});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour == 0
        ? 12
        : dt.hour > 12
        ? dt.hour - 12
        : dt.hour;
    final m  = dt.minute.toString().padLeft(2, '0');
    final p  = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  String _timeUntil(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Past';
    if (diff.inDays > 0)
      return 'In ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
    if (diff.inHours > 0)
      return 'In ${diff.inHours}h ${diff.inMinutes % 60}m';
    if (diff.inMinutes > 0) return 'In ${diff.inMinutes} min';
    return 'Now';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final all = List<AppointmentEntry>.from(
      context.watch<HealthCubit>().getAppointments(),
    )..sort((a, b) => a.appointmentDateTime
        .compareTo(b.appointmentDateTime));

    final upcoming = all
        .where((e) =>
        e.appointmentDateTime.isAfter(DateTime.now()))
        .toList();
    final past = all
        .where((e) =>
    !e.appointmentDateTime.isAfter(DateTime.now()))
        .toList()
        .reversed
        .toList();

    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14),
              color: c.surface,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back,
                        color: c.primaryText),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Appointments',
                    style: GoogleFonts.arimo(
                        color: c.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const AppointmentLogScreen()),
                    ),
                    child: Image.asset(
                        'assets/icons/add.png',
                        width: 26,
                        height: 26),
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
                  if (upcoming.isNotEmpty) ...[
                    _sectionHeader(
                        'Upcoming', AppColors.primary),
                    const SizedBox(height: 10),
                    ...upcoming.map((e) =>
                        _appointmentCard(context, e)),
                    const SizedBox(height: 20),
                  ],
                  if (past.isNotEmpty) ...[
                    _sectionHeader(
                        'Past', c.subtleText),
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


  Widget _emptyState(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments yet',
            style: GoogleFonts.arimo(
                color: c.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to schedule one',
            style: GoogleFonts.arimo(
                color: c.subtleText, fontSize: 13),
          ),
          const SizedBox(height: 24),
          GestureDetector(
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
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4)),
              ),
              child: Text(
                'Add appointment',
                style: GoogleFonts.arimo(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _sectionHeader(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.arimo(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5),
        ),
      ],
    );
  }



  Widget _appointmentCard(
      BuildContext context, AppointmentEntry e,
      {bool isPast = false}) {
    final c      = context.colors;
    final accent = isPast ? c.subtleText : AppColors.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showDetails(context, e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isPast
                  ? c.divider
                  : AppColors.primary.withOpacity(0.3),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              padding:
              const EdgeInsets.symmetric(vertical: 16),
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
                        color: isPast
                            ? c.subtleText
                            : c.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    const [
                      'Jan', 'Feb', 'Mar', 'Apr', 'May',
                      'Jun', 'Jul', 'Aug', 'Sep', 'Oct',
                      'Nov', 'Dec',
                    ][e.appointmentDateTime.month - 1],
                    style: GoogleFonts.arimo(
                        color: accent, fontSize: 12),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.appointmentName,
                      style: GoogleFonts.arimo(
                        color: isPast
                            ? c.hintText
                            : c.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: c.subtleText, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(
                              e.appointmentDateTime),
                          style: GoogleFonts.arimo(
                              color: c.hintText,
                              fontSize: 12),
                        ),
                      ],
                    ),
                    if (e.location != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                              Icons.location_on_outlined,
                              color: c.subtleText,
                              size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              e.location!,
                              style: GoogleFonts.arimo(
                                  color: c.subtleText,
                                  fontSize: 12),
                              overflow:
                              TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    child: Text(
                      _timeUntil(e.appointmentDateTime),
                      style: GoogleFonts.arimo(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(Icons.chevron_right,
                      color: c.subtleText, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showDetails(
      BuildContext context, AppointmentEntry e) {
    final c      = context.colors;
    final isPast =
    !e.appointmentDateTime.isAfter(DateTime.now());
    final accent =
    isPast ? c.hintText : AppColors.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.bottomSheet,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: c.subtleText,
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
                  child: Icon(
                      Icons.calendar_month_outlined,
                      color: accent,
                      size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.appointmentName,
                    style: GoogleFonts.arimo(
                        color: c.primaryText,
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
                    isPast
                        ? 'Past'
                        : _timeUntil(
                        e.appointmentDateTime),
                    style: GoogleFonts.arimo(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _detailRow(context,
                icon: Icons.calendar_today_outlined,
                label: _formatDate(e.appointmentDateTime)),
            const SizedBox(height: 10),
            _detailRow(context,
                icon: Icons.access_time,
                label: _formatTime(e.appointmentDateTime)),

            if (e.location != null) ...[
              const SizedBox(height: 10),
              _detailRow(context,
                  icon: Icons.location_on_outlined,
                  label: e.location!),
            ],

            if (e.notes != null &&
                e.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _detailRow(context,
                  icon: Icons.notes_outlined,
                  label: e.notes!),
            ],

            const SizedBox(height: 24),

            // Delete button
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
                          color: Colors.redAccent,
                          size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Delete Appointment',
                        style: GoogleFonts.arimo(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
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

  Widget _detailRow(
      BuildContext context, {
        required IconData icon,
        required String label,
      }) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: c.subtleText, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: GoogleFonts.arimo(
                  color: c.secondaryText, fontSize: 14)),
        ),
      ],
    );
  }
}
