import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/providers/auth_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class RiderProfile extends ConsumerStatefulWidget {
  const RiderProfile({super.key});

  @override
  ConsumerState<RiderProfile> createState() => _RiderProfileState();
}

class _RiderProfileState extends ConsumerState<RiderProfile> {
  int _currentIndex = 4;
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final initials = user != null
        ? user.name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join()
        : 'R';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary, elevation: 0,
        title: const Text('Profile', style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ScreenCard(
              child: Column(children: [
                GestureDetector(
                  onTap: _uploading ? null : _pickPhoto,
                  child: Stack(children: [
                    CircleAvatar(radius: 36,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                      child: user?.photoUrl == null
                          ? Text(initials, style: const TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary))
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                        child: _uploading
                            ? const Padding(padding: EdgeInsets.all(5), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                            : const Icon(Icons.camera_alt, size: 14, color: AppColors.white),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? 'Rider', style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkNavy)),
                Text(user?.email ?? 'rider@mkataba.com', style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.muted)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                  child: Text(user?.role.name.toUpperCase() ?? 'RIDER',
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            ScreenCard(
              child: Column(children: [
                _tile(Icons.phone_outlined, 'Phone', user?.phone.isNotEmpty == true ? user!.phone : '+255 712 345 678'),
                const Divider(height: 1, color: AppColors.border),
                _tile(Icons.motorcycle_outlined, 'Assigned Vehicle', 'T 123 ABC · Bajaj'),
                const Divider(height: 1, color: AppColors.border),
                _tile(Icons.person_outline, 'Owner', 'Sarah K.'),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 48,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login/rider');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Sign Out', style: TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex, activeColor: AppColors.primary,
        items: const [
          NavItemData(icon: Icons.dashboard_outlined, label: 'Dashboard'),
          NavItemData(icon: Icons.payments_outlined, label: 'Payments'),
          NavItemData(icon: Icons.description_outlined, label: 'Contracts'),
          NavItemData(icon: Icons.notifications_outlined, label: 'Alerts'),
          NavItemData(icon: Icons.person_outline, label: 'Profile'),
        ],
        onTap: (i) {
          setState(() => _currentIndex = i);
          final routes = ['/rider/dashboard', '/rider/payments', '/rider/contracts', '/rider/notifications', '/rider/profile'];
          if (i < routes.length) context.go( routes[i]);
        },
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (picked == null) return;
    setState(() => _uploading = true);
    final url = await ref.read(authProvider.notifier).uploadProfilePhoto(picked.path);
    setState(() => _uploading = false);
    if (mounted && url != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo updated!')));
    }
  }

  Widget _tile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.muted),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
          Text(value, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkNavy)),
        ])),
      ]),
    );
  }
}
