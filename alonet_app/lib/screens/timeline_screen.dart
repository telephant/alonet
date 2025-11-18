import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/colors/colors.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '../widgets/timeline.dart';
import '../widgets/create_moment_dialog.dart';
import '../services/moment_service.dart';
import '../services/partner_service.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh moments when screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshMoments();
    });
  }

  Future<void> _refreshMoments() async {
    final momentService = Provider.of<MomentService>(context, listen: false);
    await momentService.getMomentsForDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MomentService, PartnerService>(
      builder: (context, momentService, partnerService, child) {
        final formatter = DateFormat('HH:mm');

        // get the current local time and format it to HH:mm
        final localLocation = tz.getLocation('Asia/Dubai');
        final myLocalTime = formatter.format(tz.TZDateTime.now(localLocation));

        // get partner local time (default to Berlin if not set)
        final berlin = tz.getLocation('Europe/Berlin');
        final partnerLocalTime = formatter.format(tz.TZDateTime.now(berlin));

        // Convert moments to the format expected by timeline widget
        final userMoments = momentService.userMoments.map((moment) {
          return {
            'time': moment.momentTime.millisecondsSinceEpoch ~/ 1000,
            'event': moment.event,
            'note': moment.note,
          };
        }).toList();

        return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.timelineBackgroundTop,
            AppColors.timelineBackgroundBottom,
          ],
        ),
      ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              toolbarHeight: 100,
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildUserInfo(context, true, myLocalTime),
                    _buildUserInfo(context, false, partnerLocalTime, partnerService.currentPartner?.fullName),
                  ],
                ),
              ),
              actions: [
                if (momentService.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshMoments,
                ),
              ],
            ),
            body: _buildTimelineWidget(context, userMoments),
            floatingActionButton: _buildCreateMomentFAB(context),
          ),
        );
      },
    );
  }

  /// Show create moment dialog
  void _showCreateMomentDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateMomentDialog(
        userTimezone: 'Asia/Dubai',
        onMomentCreated: _handleMomentCreated,
      ),
    );
  }

  /// Handle new moment creation
  Future<void> _handleMomentCreated(String event, String? note, DateTime momentTime, String timezone) async {
    final momentService = Provider.of<MomentService>(context, listen: false);

    final moment = await momentService.createMoment(
      event: event,
      note: note,
      momentTime: momentTime,
      timezone: timezone,
    );

    if (moment != null && mounted) {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Moment created successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (mounted && momentService.error != null) {
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(momentService.error!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// Build floating action button for creating moments
  Widget _buildCreateMomentFAB(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.fabBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.fabShadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showCreateMomentDialog,
          borderRadius: BorderRadius.circular(32),
          child: const Icon(
            Icons.add,
            color: AppColors.fabIcon,
            size: 28,
          ),
        ),
      ),
    );
  }

  /// Build timeline widget with current moments data
  Widget _buildTimelineWidget(BuildContext context, List<Map<String, dynamic>> userMoments) {
    return DualTimelineWidget(
      userTimezone: 'Asia/Dubai',
      partnerTimezone: 'Europe/Berlin',
      userMoments: userMoments,
    );
  }
}

Widget _buildUserInfo(
  BuildContext context,
  bool isCurrentUser,
  String time,
  [String? partnerName]
) {
  return Column(
    crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
    children: [
      Row(
        children: [
          if (!isCurrentUser && partnerName != null) ...[
            Text(
              partnerName.split(' ').first,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrentUser ? AppColors.userAvatarBackground : AppColors.partnerAvatarBackground,
            ),
            child: Icon(
              Icons.person,
              color: isCurrentUser ? AppColors.userAvatarIcon : AppColors.partnerAvatarIcon,
              size: 24,
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            const Text(
              'You',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 4),
      // Time
      Text(
        time,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}