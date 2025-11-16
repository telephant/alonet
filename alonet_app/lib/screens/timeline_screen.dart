import 'package:flutter/material.dart'; 
import '../core/colors/colors.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '../widgets/timeline.dart';
import '../widgets/create_moment_dialog.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // Store user moments locally (in real app, this would come from state management/API)
  final List<Map<String, dynamic>> _userMoments = [
    {'time': 1762318900, 'event': '☕'},  // 09:00 
    {'time': 1762323300, 'event': '🧘‍♂️'}, // 10:15
    {'time': 1762333500, 'event': '🍜'},  // 13:05
  ];

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('HH:mm');

    // get the current local time and format it to HH:mm
    final localLocation = tz.getLocation('Asia/Dubai');
    final myLocalTime = formatter.format(tz.TZDateTime.now(localLocation));

    // get germany local time
    final berlin = tz.getLocation('Europe/Berlin');
    final partnerLocalTime = formatter.format(tz.TZDateTime.now(berlin));

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
                _buildUserInfo(context, false, partnerLocalTime),
              ],
            ),
          ), 
        ),
        body: _buildTimelineWidget(context),
        floatingActionButton: _buildCreateMomentFAB(context),
      ),
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
  void _handleMomentCreated(Map<String, dynamic> moment) {
    setState(() {
      _userMoments.add(moment);
    });
    
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
  Widget _buildTimelineWidget(BuildContext context) {
    return DualTimelineWidget(
      userTimezone: 'Asia/Dubai',
      partnerTimezone: 'Europe/Berlin',
      userMoments: _userMoments,
    );
  }
}

Widget _buildUserInfo(
  BuildContext context,
  bool isCurrentUser,
  String time,
) {
  return Row(
    children: [
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
      const SizedBox(width: 12),
      // Time
      Text(
        time,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}