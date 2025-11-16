import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../core/colors/colors.dart';

/// Dialog for creating a new moment entry
/// Allows users to select time, emoji, and add optional notes
class CreateMomentDialog extends StatefulWidget {
  final String? userTimezone;
  final Function(Map<String, dynamic>) onMomentCreated;

  const CreateMomentDialog({
    super.key,
    this.userTimezone,
    required this.onMomentCreated,
  });

  @override
  State<CreateMomentDialog> createState() => _CreateMomentDialogState();
}

class _CreateMomentDialogState extends State<CreateMomentDialog> {
  // Form controllers and state
  final TextEditingController _noteController = TextEditingController();
  String _selectedEmoji = '😊';
  late DateTime _selectedDateTime;
  
  // Common emojis for quick selection
  final List<String> _commonEmojis = [
    '💩', '😴', '🍕', '☕️', '🏋️', '📚', '🎵', '🎮',
    '💼', '🚗', '✈️', '🏠', '💤', '🍜', '🧘‍♂️', '📱',
    '🍳', '🍚', '🌅', '🌙', '❤️', '🏃', '🛀', '⭐'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current time in user's timezone
    final userTimezone = widget.userTimezone ?? 'Asia/Dubai';
    final location = tz.getLocation(userTimezone);
    _selectedDateTime = tz.TZDateTime.now(location);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Show time picker and update selected time
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.dialogAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  /// Create moment and close dialog
  void _createMoment() {
    // Convert DateTime to timestamp
    final timestamp = _selectedDateTime.millisecondsSinceEpoch ~/ 1000;
    
    final moment = {
      'time': timestamp,
      'event': _selectedEmoji,
      'note': _noteController.text.trim(),
      'create_time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };

    widget.onMomentCreated(moment);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog title
            const Text(
              'Create Moment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Time selection
            _buildTimeSection(),
            const SizedBox(height: 24),

            // Emoji selection
            _buildEmojiSection(),
            const SizedBox(height: 24),

            // Note input (optional)
            _buildNoteSection(),
            const SizedBox(height: 32),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Build time selection section
  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.dialogBorder),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.dialogSecondary.withOpacity(0.3),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: AppColors.dialogAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build emoji selection section
  Widget _buildEmojiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What happened?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // Selected emoji display
        Container(
          width: 60,
          height: 60,
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
          child: Text(
            _selectedEmoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
        const SizedBox(height: 16),
        // Emoji grid
        Container(
          height: 120,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _commonEmojis.length,
            itemBuilder: (context, index) {
              final emoji = _commonEmojis[index];
              final isSelected = emoji == _selectedEmoji;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEmoji = emoji;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.dialogSecondary.withOpacity(0.6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected ? Border.all(color: AppColors.dialogAccent, width: 2) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build note input section
  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a note about this moment...',
            hintStyle: const TextStyle(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.dialogSecondary.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.dialogBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.dialogAccent, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.dialogBorder),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  /// Build action buttons (Cancel/Create)
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Create button
        Expanded(
          child: ElevatedButton(
            onPressed: _createMoment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dialogAccent,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Create',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}