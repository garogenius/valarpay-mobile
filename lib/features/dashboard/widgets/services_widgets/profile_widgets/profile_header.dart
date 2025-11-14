import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/profile_notifier.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/dashboard/view/KYC/upgrade_kyc.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  final VoidCallback? onEditTap;
  final BuildContext context;

  const ProfileHeader({super.key, required this.context, this.onEditTap});

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  bool _loadingShown = false;

  void _hideLoading() {
    if (!_loadingShown) return;
    _loadingShown = false;

    if (mounted && Navigator.canPop(widget.context)) {
      Navigator.of(widget.context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Fallbacks for safety
    final wallet =
        user?.wallets.isNotEmpty == true ? user!.wallets.first : null;

    // Extract wallet data
    final accountNumber = wallet?.accountNumber ?? '00000000';
    final fullName = user?.fullname ?? 'User';

    return Container(
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar with edit button
          Stack(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor:
                    isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                child: ClipOval(
                  child:
                      user?.profileImageUrl != null &&
                              user!.profileImageUrl!.isNotEmpty
                          ? Image.network(
                            user.profileImageUrl!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          )
                          : Icon(
                            Icons.person,
                            size: 36,
                            color:
                                isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280),
                          ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      // show dialog with options (camera / gallery)
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text(
                              'Update profile image',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Take photo'),
                                    onTap: () async {
                                      Navigator.of(dialogContext).pop();
                                      final XFile? picked = await ImagePicker()
                                          .pickImage(
                                            source: ImageSource.camera,
                                            imageQuality: 80,
                                          );
                                      if (picked != null) {
                                        // show loading
                                        _loadingShown = true;
                                        showDialog(
                                          context: widget.context,
                                          barrierDismissible: false,
                                          builder:
                                              (_) => WillPopScope(
                                                onWillPop: () async => false,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                        );
                                        try {
                                          final ok = await ref
                                              .read(
                                                profileNotifierProvider
                                                    .notifier,
                                              )
                                              .uploadProfileImage(
                                                picked.path,
                                                user?.fullname ?? '',
                                              );
                                          _hideLoading();

                                          if (!mounted) return;

                                          if (ok) {
                                            final updated =
                                                await ref
                                                    .read(
                                                      userNotifierProvider
                                                          .notifier,
                                                    )
                                                    .refreshUserProfile();
                                            if (updated != null) {
                                              ref
                                                  .read(userProvider.notifier)
                                                  .setUser(updated);
                                            }
                                            AppMessenger.show(
                                              widget.context,
                                              message: 'Profile image updated',
                                              type: MessageType.success,
                                            );

                                            if (widget.onEditTap != null)
                                              widget.onEditTap!();
                                          } else {
                                            AppMessenger.show(
                                              widget.context,
                                              message:
                                                  ref
                                                      .read(
                                                        profileNotifierProvider,
                                                      )
                                                      .message ??
                                                  'Failed to update profile',
                                              type: MessageType.error,
                                            );
                                          }
                                        } catch (e) {
                                          _hideLoading();

                                          if (!mounted) return;

                                          AppMessenger.show(
                                            widget.context,
                                            message:
                                                'Error updating profile: $e',
                                            type: MessageType.error,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Choose from gallery'),
                                    onTap: () async {
                                      Navigator.of(dialogContext).pop();
                                      final XFile? picked = await ImagePicker()
                                          .pickImage(
                                            source: ImageSource.gallery,
                                            imageQuality: 80,
                                          );
                                      if (picked != null) {
                                        _loadingShown = true;
                                        showDialog(
                                          context: widget.context,
                                          barrierDismissible: false,
                                          builder:
                                              (_) => WillPopScope(
                                                onWillPop: () async => false,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                        );
                                        try {
                                          final ok = await ref
                                              .read(
                                                profileNotifierProvider
                                                    .notifier,
                                              )
                                              .uploadProfileImage(
                                                picked.path,
                                                user?.fullname ?? '',
                                              );
                                          _hideLoading();

                                          if (!mounted) return;

                                          if (ok) {
                                            final updated =
                                                await ref
                                                    .read(
                                                      userNotifierProvider
                                                          .notifier,
                                                    )
                                                    .refreshUserProfile();
                                            if (updated != null) {
                                              ref
                                                  .read(userProvider.notifier)
                                                  .setUser(updated);
                                            }
                                            AppMessenger.show(
                                              widget.context,
                                              message: 'Profile image updated',
                                              type: MessageType.success,
                                            );

                                            if (widget.onEditTap != null)
                                              widget.onEditTap!();
                                          } else {
                                            AppMessenger.show(
                                              widget.context,
                                              message:
                                                  ref
                                                      .read(
                                                        profileNotifierProvider,
                                                      )
                                                      .message ??
                                                  'Failed to update profile',
                                              type: MessageType.error,
                                            );
                                          }
                                        } catch (e) {
                                          _hideLoading();

                                          if (!mounted) return;

                                          AppMessenger.show(
                                            widget.context,
                                            message:
                                                'Error updating profile: $e',
                                            type: MessageType.error,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (accountNumber.isNotEmpty && accountNumber != '00000000')
            const SizedBox(height: 12),

          // User Info - Display Full Name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fullName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: accountNumber));
                  AppMessenger.show(
                    context,
                    message: 'Account number copied',
                    type: MessageType.success,
                  );
                },
                child: Icon(Icons.copy, size: 14),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UpgradeKycScreen(),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.tierLevel ?? 'Tier 1',
                  style: TextStyle(color: appTheme.primaryColor, fontSize: 14),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: appTheme.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
