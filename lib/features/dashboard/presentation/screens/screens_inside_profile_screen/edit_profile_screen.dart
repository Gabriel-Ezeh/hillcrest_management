import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';
import 'package:hillcrest_finance/ui/widgets/app_button.dart';
import 'package:hillcrest_finance/ui/widgets/forms/app_textfields.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

@RoutePage()
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Controllers to hold user data
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    // Initialize empty controllers
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    // Load user data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    try {
      // Get the current authenticated user from AuthState
      final authState = ref.read(authStateProvider);
      final user = authState.user;

      if (user != null) {
        setState(() {
          _firstNameController.text = user.firstName ?? '';
          _lastNameController.text = user.lastName ?? '';
          _emailController.text = user.email ?? '';

          // Extract phone number from attributes if available
          final phoneAttr = user.attributes?['phoneNumber'];
          if (phoneAttr is List && phoneAttr.isNotEmpty) {
            _phoneController.text = phoneAttr.first.toString();
          } else if (phoneAttr is String) {
            _phoneController.text = phoneAttr;
          }

          // Extract home address from attributes if available
          final addressAttr = user.attributes?['homeAddress'];
          if (addressAttr is List && addressAttr.isNotEmpty) {
            _addressController.text = addressAttr.first.toString();
          } else if (addressAttr is String) {
            _addressController.text = addressAttr;
          }

          _isLoadingUserData = false;
        });
      } else {
        // If no user data available, keep controllers empty
        setState(() {
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      print('[EDIT_PROFILE] Error loading user data: $e');
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String firstName = _firstNameController.text.trim();
    final String profileInitial = firstName.isNotEmpty
        ? firstName.substring(0, 1).toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.darkBlue,
            size: 28,
          ),
          onPressed: () => context.router.back(),
        ),
        title: Text("Edit Profile", style: AppTextStyles.cabinBold18DarkBlue),
      ),
      body: SafeArea(
        child: _isLoadingUserData
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.PADDING_24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SpaceH20(),

                    // ...existing code...
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryColor.withOpacity(
                          0.12,
                        ),
                        child: Text(
                          profileInitial,
                          style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                            fontSize: 36,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SpaceH12(),

                    // ...existing code...

                    // --- 2. KYC Status Badge (Creative Touch) ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            color: AppColors.successGreen,
                            size: 14,
                          ),
                          const SpaceW4(),
                          Text(
                            "Fully Verified Account",
                            style: AppTextStyles.cabinRegular11mutedGray
                                .copyWith(color: AppColors.successGreen),
                          ),
                        ],
                      ),
                    ),

                    const SpaceH32(),

                    // --- 3. Personal Information Form ---
                    AppTextField(
                      label: "First Name",
                      type: AppTextFieldType.text,
                      controller: _firstNameController,
                      hintText: "Enter first name",
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.mutedGray,
                      ),
                    ),
                    const SpaceH20(),

                    AppTextField(
                      label: "Last Name",
                      type: AppTextFieldType.text,
                      controller: _lastNameController,
                      hintText: "Enter last name",
                    ),
                    const SpaceH20(),

                    AppTextField(
                      label: "Email Address",
                      type: AppTextFieldType.email,
                      controller: _emailController,
                      readOnly:
                          true, // Email is typically locked in finance apps
                      hintText: "Email address",
                      prefixIcon: const Icon(
                        Icons.mail_outline,
                        color: AppColors.mutedGray,
                      ),
                      suffixIcon: const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: AppColors.lightGray,
                      ),
                    ),
                    const SpaceH20(),

                    AppTextField(
                      label: "Phone Number",
                      type: AppTextFieldType.phone,
                      controller: _phoneController,
                      hintText: "800 000 0000",
                    ),
                    const SpaceH20(),

                    AppTextField(
                      label: "Home Address",
                      type: AppTextFieldType.address,
                      controller: _addressController,
                      hintText: "Enter your full address",
                      maxLines: 2,
                    ),

                    const SpaceH40(),

                    // --- 4. Security Options Shortcut ---
                    GestureDetector(
                      onTap: () {
                        context.router.push(const ForgotPasswordRoute());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.brandSoftGray,
                          borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              color: AppColors.mutedGray,
                            ),
                            const SpaceW12(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Security Settings",
                                    style: AppTextStyles.cabinBold14DarkBlue,
                                  ),
                                  Text(
                                    "Change password or PIN",
                                    style:
                                        AppTextStyles.cabinRegular11mutedGray,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.mutedGray,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SpaceH40(),

                    // --- 5. Save Button ---
                    AppButton(
                      text: "Update Profile",
                      onPressed: () {
                        // Logic to call API update
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profile updated successfully!"),
                          ),
                        );
                      },
                    ),
                    const SpaceH32(),
                  ],
                ),
              ),
      ),
    );
  }
}
