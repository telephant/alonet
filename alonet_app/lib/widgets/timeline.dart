import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:timezone/timezone.dart' as tz;
import '../core/colors/colors.dart';

// 全局配置
const double hourHeight = 80.0; // 每小时高度（px）
const double timelineWidth = 350.0;
const double circleSize = 56.0; // emoji 背景圆大小

final List<Map<String, dynamic>> myMoments = [
  {'time': 1762318900, 'event': '☕'},  // 09:00 
  {'time': 1762323300, 'event': '🧘‍♂️'}, // 10:15
  {'time': 1762333500, 'event': '🍜'},  // 13:05
];

final List<Map<String, dynamic>> partnerMoments = [
  {'time': 1762328226, 'event': '🌅'},  // 06:00
  {'time': 1762347246, 'event': '💬'},  // 10:15
];

class DualTimelineWidget extends StatefulWidget {
  final String? userTimezone;
  final String? partnerTimezone;
  final List<Map<String, dynamic>>? userMoments;
  final List<Map<String, dynamic>>? partnerMoments;
  
  const DualTimelineWidget({
    super.key,
    this.userTimezone,
    this.partnerTimezone,
    this.userMoments,
    this.partnerMoments,
  });

  @override
  State<DualTimelineWidget> createState() => _DualTimelineWidgetState();
}

class _DualTimelineWidgetState extends State<DualTimelineWidget> {
  final ScrollController _scrollController = ScrollController();

  // 存储 reaction：key 用 "L-idx" 或 "R-idx" 表示左右第 idx 个 moment
  final Map<String, String> _reactions = {};

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    // 自动滚动到当前时间附近（使用用户时区）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get current hour as decimal in user's timezone
      final userTimezone = widget.userTimezone ?? 'Asia/Dubai';
      final location = tz.getLocation(userTimezone);
      final now = tz.TZDateTime.now(location);
      final currentHour = now.hour + (now.minute / 60.0);
      final targetOffset = currentHour * hourHeight - 200;
      
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _scrollController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
void _showReactionBar(
    BuildContext context,
    Offset globalPosition,
    void Function(String) onSelect,
  ) {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '👎'];
    _removeOverlay();

    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    const barHeight = 48.0;
    const barPadding = 8.0;
    double left = globalPosition.dx - (reactions.length * 44) / 2;
    left = left.clamp(8.0, screenSize.width - reactions.length * 44 - 8.0);

    double top = globalPosition.dy - barHeight - 12.0;
    if (top < MediaQuery.of(context).padding.top + 8) {
      top = globalPosition.dy + 12.0; // 空间不足则放下面
    }

    _overlayEntry = OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay, // 点击空白区域关闭
        child: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: barPadding / 2,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.momentBackground,
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: reactions.map((r) {
                      return GestureDetector(
                        onTap: () {
                          onSelect(r);
                          _removeOverlay();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(r, style: const TextStyle(fontSize: 22)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _globalPointerRouter(PointerEvent event) {
    // 任意点击都移除 overlay
    _removeOverlay();
    GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _globalPointerRouter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = hourHeight * 24; // 24 hour total height
    
    // Use provided moments or fall back to default data
    final userMoments = widget.userMoments ?? myMoments;
    final currentPartnerMoments = widget.partnerMoments ?? partnerMoments;
    
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      child: Center(
        child: Container(
          width: timelineWidth,
          height: totalHeight,
          margin: const EdgeInsets.all(20),
          // Use Stack to draw dotted line at bottom, emoji positioned on top for interaction
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Timeline dotted line (CustomPaint)
              Positioned.fill(
                child: CustomPaint(painter: _TimelinePainter()),
              ),

              // Left side moments (user moments)
              ...userMoments.asMap().entries.expand((entry) => 
                _buildMomentWidget(
                  context: context,
                  isLeft: true,
                  index: entry.key,
                  timestamp: (entry.value['time'] as num).toInt(),
                  emoji: entry.value['event'] as String,
                ),
              ),

              // Right side moments (partner moments)
              ...currentPartnerMoments.asMap().entries.expand((entry) =>
                _buildMomentWidget(
                  context: context,
                  isLeft: false,
                  index: entry.key,
                  timestamp: (entry.value['time'] as num).toInt(),
                  emoji: entry.value['event'] as String,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMomentWidget({
    required BuildContext context,
    required bool isLeft,
    required int index,
    required int timestamp,
    required String emoji,
  }) {
    // Convert timestamp to DateTime in USER's timezone (timeline is based on user's location)
    final userTimezone = widget.userTimezone ?? 'Asia/Dubai';
    final location = tz.getLocation(userTimezone);
    final dateTime = tz.TZDateTime.fromMillisecondsSinceEpoch(location, timestamp * 1000);
    
    // Calculate position based on time of day in the user's timezone
    final hours = dateTime.hour;
    final minutes = dateTime.minute;
    final seconds = dateTime.second;
    
    // Convert to decimal hours (e.g., 10:30 = 10.5)
    final decimalHours = hours + (minutes / 60.0) + (seconds / 3600.0);
    
    // Calculate top position
    final top = decimalHours * hourHeight;
    final centerX = timelineWidth * 0.5;
    final momentOffset = 100.0; // Distance from center
    
    // Format time string
    final timeStr = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    final key = '${isLeft ? "L" : "R"}-$index';

    // Return a list of Positioned widgets
    return [
      // Horizontal line
      Positioned(
        top: top - 1,
        left: isLeft ? (centerX - momentOffset) : centerX,
        child: Container(
          width: momentOffset,
          height: 2,
          color: AppColors.timelineConnectionLine,
        ),
      ),
      // Time label
      Positioned(
        top: top + circleSize/2 + 8,
        left: isLeft ? (centerX - momentOffset - circleSize/2) : (centerX + momentOffset - circleSize/2),
        child: Container(
          alignment: Alignment.center,
          width: circleSize,
          child: Text(
            timeStr,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.timelineText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      // Emoji circle
      Positioned(
        top: top - circleSize / 2,
        left: isLeft ? (centerX - momentOffset - circleSize) : (centerX + momentOffset),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // 点击可以做别的交互
          },
          onLongPressStart: (details) {
            if (isLeft) {return;}

            // 显示 reaction bar，基于全局位置
            _showReactionBar(context, details.globalPosition, (selected) {
              setState(() {
                _reactions[key] = selected;
              });
            });
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 圆形白底
              Container(
                width: circleSize,
                height: circleSize,
                decoration: const BoxDecoration(
                  color: AppColors.momentBackground,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.momentShadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),

              // 若已 reaction，则在右上角显示小气泡
              if (_reactions.containsKey(key))
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.momentBackground,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      _reactions[key]!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ];
  }
}

class _TimelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.timelineLine
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const segmentHeight = 6.0;
    const segmentSpace = 12.0;
    double y = 0;
    final centerX = size.width / 2;

    // Draw dotted segments
    while (y < size.height) {
      final path = Path();
      path.moveTo(centerX, y);
      path.lineTo(centerX, y + segmentHeight);
      canvas.drawPath(path, paint);
      y += segmentHeight + segmentSpace;
    }
    
    // Draw dots at top and bottom
    final dotPaint = Paint()
      ..color = AppColors.timelineLine
      ..style = PaintingStyle.fill;
    
    // Top dots
    canvas.drawCircle(Offset(centerX, -20), 3, dotPaint);
    canvas.drawCircle(Offset(centerX, -10), 3, dotPaint);
    
    // Bottom dots
    canvas.drawCircle(Offset(centerX, size.height + 10), 3, dotPaint);
    canvas.drawCircle(Offset(centerX, size.height + 20), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
