import 'package:flutter/material.dart';
import '../core/colors/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';


class NoPartnerScreen extends StatelessWidget {
  const NoPartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with title and notification icon
              _buildHeader(theme),

              const SizedBox(height: 24),

              // Main content cards
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Add a partner to start sharing!'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: 'Your unique invite link'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.all(16),
                            content: Text(
                              'Copied to clipboard. Give it to your partner to join you!',
                            ),
                          ),
                        );
                      },
                      child: Text('Add Partner'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header with alonet title and notification bell
  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // alonet logo/title
        SvgPicture.asset('assets/icons/logo.svg', width: 32, height: 32),

        // Notification bell icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.surface),
          child: SvgPicture.asset(
            'assets/icons/notification.svg',
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildAddPartnerModal(BuildContext context) {
    // show a copy button to copy the alonet url to the clipboard
    return SimpleDialog(
      children: [
        Column(
          children: [
            Text('Add a partner to start sharing!'),
            ElevatedButton(onPressed: () {
              
            }, child: Text('Copy URL')),
          ],  
        ),
      ],
    );
  }
}
