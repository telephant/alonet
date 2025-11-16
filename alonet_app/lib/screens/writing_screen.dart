import 'package:flutter/material.dart';
import '../core/colors/colors.dart';

class WritingScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;

  const WritingScreen({super.key, this.initialTitle, this.initialContent});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialTitle ?? 'Dear...',
    );
    _contentController = TextEditingController(
      text: widget.initialContent ?? '',
    );
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // 背景格子
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(gridSize: 18, color: Colors.grey[300]!),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(theme),

                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const SizedBox(height: 32),
                        // Content
                        _buildContentField(theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_back_ios,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          GestureDetector(
            onTap: _handleDone,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.mediumGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '写好了',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField(ThemeData theme) {
    return TextField(
      controller: _titleController,
      focusNode: _titleFocusNode,
      style: theme.textTheme.titleLarge?.copyWith(
        color: AppColors.textHint,
        fontWeight: FontWeight.w400,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        filled: true,
        fillColor: Colors.transparent, // 背景透明
      ),
      onTap: () {
        if (_titleController.text == 'Dear...') {
          _titleController.clear();
        }
      },
    );
  }

  Widget _buildContentField(ThemeData theme) {
    return Expanded(
      child: TextField(
        controller: _contentController,
        focusNode: _contentFocusNode,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: 'Dear... \n不同场景不同的引导文案?',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textHint,
            height: 1.6,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.transparent,
          focusedBorder: InputBorder.none,
          focusColor: Colors.transparent,
        ),
        onTap: () => _contentFocusNode.requestFocus(),
      ),
    );
  }

  void _handleDone() {
    FocusScope.of(context).unfocus();
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('内容已保存'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );

    Navigator.of(context).pop({'title': title, 'content': content});
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;
  final Color color;

  GridPainter({required this.gridSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
