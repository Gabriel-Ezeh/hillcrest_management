import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';
import 'package:hillcrest_finance/ui/widgets/app_button.dart';
import 'package:flutter/services.dart';

@RoutePage()
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const String _supportEmail = 'Info@hillcrestcapmgt.com';
  static const String _supportPhone = '08164218808';

  void _copyToClipboard(
    BuildContext context,
    String value,
    String label,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state to get user information
    final authState = ref.watch(authStateProvider);
    final user = authState.user; // Using the 'user' field from your AuthState

    // Format the display name: First + Last or fallback to a default
    final String displayName = user != null
        ? '${user.firstName} ${user.lastName}'.trim()
        : StringConst.profileName;

    final String displayEmail = user?.email ?? StringConst.profileEmail;
    final String firstName = (user?.firstName ?? '').trim();
    final String profileInitial = firstName.isNotEmpty
        ? firstName.substring(0, 1).toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SpaceH40(),

              // --- 1. Profile Image with Pencil Icon ---
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lightGray, width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.lightGray.withOpacity(0.2),
                    child: Text(
                      profileInitial,
                      style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                        fontSize: 44,
                      ),
                    ),
                  ),
                ),
              ),

              const SpaceH16(),

              // --- 2. User Name & Email ---
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: AppTextStyles.cabinBold20DarkBlue,
              ),
              const SpaceH4(),
              Text(
                displayEmail,
                textAlign: TextAlign.center,
                style: AppTextStyles.cabinRegular14MutedGray,
              ),

              const SpaceH32(),

              // --- 3. Tappable List ---
              _buildProfileTile(
                title: StringConst.generateReferenceLetter,
                onTap: () {
                  context.router.push(const GenerateReferenceLetterRoute());
                },
              ),
              _buildProfileTile(
                title: StringConst.generateAccountStatement,
                onTap: () {
                  context.router.push(const GenerateAccountStatementRoute());
                },
              ),
              _buildProfileTile(
                title: StringConst.viewFundPrice,
                onTap: () {
                  context.router.push(const FundPriceRoute());
                },
              ),
              _buildProfileTile(
                title: StringConst.faqs,
                onTap: () {
                  context.router.push(const FAQRoute());
                },
              ),
              _buildProfileTile(
                title: StringConst.appVersionLabel,
                trailingText: StringConst.appVersionValue,
                showArrow: false,
              ),

              // --- 4. Support Section ---
              const SpaceH24(),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.PADDING_24,
                  ),
                  child: Text(
                    StringConst.supportHeader,
                    style: AppTextStyles.interRegular14DarkBlue.copyWith(
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SpaceH8(),
              _buildProfileTile(
                title: _supportEmail,
                icon: Icons.email_outlined,
                onTap: () => _copyToClipboard(context, _supportEmail, 'Email'),
              ),
              _buildProfileTile(
                title: _supportPhone,
                icon: Icons.phone_outlined,
                onTap: () =>
                    _copyToClipboard(context, _supportPhone, 'Phone number'),
              ),

              const SpaceH40(),

              // --- 5. Logout Button ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.PADDING_24,
                ),
                child: AppButton(
                  text: StringConst.logout,
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).logout();

                    if (context.mounted) {
                      context.router.replaceAll([const SignInRoute()]);
                    }
                  },
                ),
              ),

              const SpaceH40(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required String title,
    VoidCallback? onTap,
    String? trailingText,
    IconData? icon,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: Sizes.PADDING_24,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.lightGray.withOpacity(0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: AppTextStyles.interRegular14DarkBlue),
            ),
            if (trailingText != null)
              Text(trailingText, style: AppTextStyles.interRegular14DarkBlue),
            if (icon != null) Icon(icon, size: 20, color: AppColors.darkBlue),
            if (showArrow && icon == null)
              const Icon(
                Icons.chevron_right,
                color: AppColors.darkBlue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
