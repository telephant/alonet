import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/colors/colors.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0), // Moderate padding for subtle rotated cards
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 22, // Reduced spacing for subtle rotation
              crossAxisSpacing: 20, // Reduced spacing for subtle rotation 
            ),
            itemCount: _sampleInboxItems.length,
            itemBuilder: (context, index) {
              final item = _sampleInboxItems[index];
              return _buildInboxCard(theme, item, index);
            },
          ),
        ),
      ),
    );
  }

  // Build individual inbox card with random rotation
  Widget _buildInboxCard(ThemeData theme, InboxItem item, int index) {
    // Generate consistent random rotation for each card based on index
    final random = math.Random(index); // Use index as seed for consistency
    final rotationAngle = (random.nextDouble() * 20 - 10) * (math.pi / 180); // -10 to 10 degrees in radians
    
    return Transform.rotate(
      angle: rotationAngle,
      child: GestureDetector(
        onTap: () => _handleCardTap(item),
        child: Stack(

          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 12),

                  // From label
                  Text(
                    'From:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Sender name
                  Text(
                    item.senderName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Address
                  Expanded(
                    child: Text(
                      item.address,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                        fontSize: 11,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(child: _buildColorDecorations(8)),
            Positioned(
              top: -5,
              right: 50,
              child: Row(
                children: [
                  // Date circle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.error, width: 1.5),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      item.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle card tap
  void _handleCardTap(InboxItem item) {
    // You can navigate to a detail screen or perform other actions
    print('Tapped card from: ${item.senderName}');
    // Example: Navigate to a detail screen
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => InboxDetailScreen(item: item),
    //   ),
    // );
  }

  // Build decorative colored rectangles
  Widget _buildColorDecorations(int n) {
    final colors = [
      Colors.pink.shade200,
      Colors.blue.shade200,
    ];

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: ParallelogramRow(colors: colors),
    );
  }

  // Sample data for inbox items
  static final List<InboxItem> _sampleInboxItems = [
    InboxItem(
      date: '2025\n08/12',
      senderName: '大流士',
      address: '炎之大陆流云市彩虹社区\n23#204',
      colors: [
        Colors.pink.shade200,
        Colors.orange.shade200,
        Colors.blue.shade200,
        Colors.yellow.shade200,
      ],
    ),
    InboxItem(
      date: '2025\n08/10',
      senderName: '路德',
      address: '炎之大陆桑德市斯提木街月牙公寓56号1102-3',
      colors: [
        Colors.pink.shade200,
        Colors.orange.shade200,
        Colors.blue.shade200,
        Colors.cyan.shade200,
      ],
    ),
    InboxItem(
      date: '2025\n08/08',
      senderName: '阿梓',
      address: '炎之大陆流云市彩虹社区\n23#204',
      colors: [
        Colors.pink.shade200,
        Colors.orange.shade200,
        Colors.blue.shade200,
        Colors.cyan.shade200,
      ],
    ),
    InboxItem(
      date: '2025\n08/02',
      senderName: 'Daisy Aomori',
      address: '炎之大陆雷德市冰霜社区\n23#104',
      colors: [
        Colors.pink.shade200,
        Colors.orange.shade200,
        Colors.blue.shade200,
        Colors.yellow.shade200,
      ],
    ),
    InboxItem(
      date: '2025\n02/20',
      senderName: '路德',
      address: '炎之大陆桑德市斯提木街月牙公寓56号1102-3',
      colors: [
        Colors.pink.shade200,
        Colors.orange.shade200,
        Colors.blue.shade200,
        Colors.cyan.shade200,
      ],
    ),
  ];
}

// Data model for inbox items
class InboxItem {
  final String date;
  final String senderName;
  final String address;
  final List<Color> colors;

  InboxItem({
    required this.date,
    required this.senderName,
    required this.address,
    required this.colors,
  });
}

class ParallelogramRow extends StatelessWidget {
  final List<Color> colors;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final double skewX;

  const ParallelogramRow({
    super.key,
    required this.colors,
    this.itemWidth = 10,
    this.itemHeight = 10,
    this.spacing = 8,
    this.skewX = -0.4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        final itemFullWidth = itemWidth + spacing + 2;

        final count = (totalWidth / itemFullWidth).ceil();

        return Row(
          children: List.generate(count, (index) {
            final color = colors[index % colors.length];

            return Container(
              width: itemWidth,
              height: itemHeight,
              margin: EdgeInsets.only(right: index == count - 1 ? 0 : spacing),
              child: Transform(
                transform: Matrix4.skewX(skewX),
                child: Container(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
