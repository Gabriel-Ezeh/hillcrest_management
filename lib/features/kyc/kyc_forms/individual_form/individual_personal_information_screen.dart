import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

// --- Custom Imports ---
import '../../../../app/core/exceptions/network_exceptions.dart';
import '../../../../app/core/providers/networking_provider.dart';
import '../../../../app/core/providers/notification_service_provider.dart';
import '../../../../app/core/providers/user_local_storage_provider.dart';
import '../../../../app/core/router/app_router.dart';
import '../../../../ui/widgets/app_button.dart';
import '../../../../ui/widgets/forms/app_textfields.dart';
import '../../../../utils/constants/values.dart';
import '../../presentation/providers/kyc_state_notifier.dart';
import '../../../authentication/data/repositories/auth_repository.dart';

@RoutePage()
class IndividualPersonalInformationScreen extends ConsumerStatefulWidget {
  const IndividualPersonalInformationScreen({super.key});

  @override
  ConsumerState<IndividualPersonalInformationScreen> createState() =>
      _IndividualPersonalInformationScreenState();
}

class _IndividualPersonalInformationScreenState
    extends ConsumerState<IndividualPersonalInformationScreen> {
  // --- Controllers ---
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bvnController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _ninController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // --- State ---
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedCountry;
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _maritalStatuses = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];
  final List<String> _countries = [
    'Nigeria',
    'Ghana',
    'Kenya',
    'South Africa',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userLocalStorage = ref.read(userLocalStorageProvider);
      final username = await userLocalStorage.getUsername();

      if (username == null) {
        if (mounted) {
          ref
              .read(notificationServiceProvider)
              .showError(
                'Unable to load user information. Please login again.',
              );
          context.router.pop();
        }
        return;
      }

      final authRepository = ref.read(authRepositoryProvider);
      final realm = dotenv.env['CC_REALM']!;

      // Get admin token
      final adminToken = await authRepository.getAdminAuthToken();
      final bearerAdminToken = 'Bearer $adminToken';

      // Fetch user from Keycloak
      final authApiClient = ref.read(authApiClientProvider);
      final users = await authApiClient.getUsers(
        realm: realm,
        username: username,
        adminToken: bearerAdminToken,
      );

      if (users.isNotEmpty) {
        final user = users.first;

        setState(() {
          if (user.firstName != null)
            _firstNameController.text = user.firstName!;
          if (user.lastName != null) _lastNameController.text = user.lastName!;

          final phoneAttr = user.attributes?['phoneNumber'];
          if (phoneAttr is List && phoneAttr.isNotEmpty) {
            _phoneController.text = phoneAttr.first.toString();
          }

          if (user.email != null) _emailController.text = user.email!;
        });
      }

      setState(() => _isInitializing = false);
    } on NetworkException catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider).showError(e.message);
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(notificationServiceProvider)
            .showError('Failed to load user data. Please try again.');
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bvnController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _ninController.dispose();
    super.dispose();
  }

  // /// Load user data from Keycloak and pre-fill the form
  // Future<void> _loadUserData() async {
  //   try {
  //     final userLocalStorage = ref.read(userLocalStorageProvider);
  //     final username = await userLocalStorage.getUsername();
  //
  //     if (username == null) {
  //       if (mounted) {
  //         ref.read(notificationServiceProvider).showError('Unable to load user information. Please login again.');
  //         context.router.pop();
  //       }
  //       return;
  //     }
  //
  //     final authRepository = ref.read(authRepositoryProvider);
  //
  //     // Get user by username from Keycloak
  //     final realm = dotenv.env['CC_REALM']!;
  //     final adminToken = await authRepository.getAdminAuthToken();
  //     final bearerAdminToken = 'Bearer $adminToken';
  //
  //     // This requires adding a public method to AuthRepository or using the API client directly
  //     // For now, we'll use a simplified approach
  //
  //     setState(() => _isInitializing = false);
  //   } on NetworkException catch (e) {
  //     if (mounted) {
  //       ref.read(notificationServiceProvider).showError(e.message);
  //       setState(() => _isInitializing = false);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ref.read(notificationServiceProvider).showError('Failed to load user data. Please try again.');
  //       setState(() => _isInitializing = false);
  //     }
  //   }
  // }

  Future<void> _onContinuePressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedGender == null) {
      ref
          .read(notificationServiceProvider)
          .showError('Please select a gender.');
      return;
    }
    if (_selectedMaritalStatus == null) {
      ref
          .read(notificationServiceProvider)
          .showError('Please select marital status.');
      return;
    }
    if (_selectedCountry == null) {
      ref
          .read(notificationServiceProvider)
          .showError('Please select a country.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);

      // // Step 1: Validate BVN
      // print('[KYC] Step 1: Validating BVN...');
      // await authRepository.validateBvn(
      //   bvn: _bvnController.text.trim(),
      //   firstName: _firstNameController.text.trim(),
      //   lastName: _lastNameController.text.trim(),
      //   dateOfBirth: _dateOfBirthController.text.trim(),
      //   tenantId: tenantId,
      // );
      // print('[KYC] BVN validation successful');
      //
      // if (!mounted) return;
      // ref.read(notificationServiceProvider).showSuccess('BVN validation successful');

      // Step 2: Submit Personal Information
      print('[KYC] Step 2: Submitting personal information...');
      final customerNo = await authRepository.submitPersonalInfo(
        customerType: 'Individual',
        customerCategory: 'Retail',
        firstName: _firstNameController.text.trim(),
        middleName: _middleNameController.text.trim().isEmpty
            ? null
            : _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _selectedGender!,
        dateOfBirth: _dateOfBirthController.text.trim(),
        maritalStatus: _selectedMaritalStatus!,
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        bvn: _bvnController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        nin: _ninController.text.trim().isEmpty
            ? null
            : _ninController.text.trim(),
        tin: null,
      );
      print(
        '[KYC] Personal info submitted successfully. CustomerNo: $customerNo',
      );

      if (!mounted) return;

      // Step 3: Store customerNo in KYC state and update Keycloak
      if (customerNo != null && customerNo.isNotEmpty) {
        ref.read(kycStateProvider.notifier).setCustomerNo(customerNo);

        // Store pending customerNo in local storage
        final userLocalStorage = ref.read(userLocalStorageProvider);
        await userLocalStorage.savePendingCustomerNo(customerNo);
        print('[KYC] Pending customerNo stored: $customerNo');
      }

      ref
          .read(notificationServiceProvider)
          .showSuccess('Personal information submitted successfully');

      // Step 4: Navigate to document upload screen
      if (mounted) {
        context.router.pushNamed('/kyc/upload-documents');
      }
    } on ClientException catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider).showError(e.message);
      }
    } on NetworkException catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider).showError(e.message);
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(notificationServiceProvider)
            .showError('An unexpected error occurred. Please try again.');
      }
      print('[KYC] Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.darkBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SpaceW4(),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SpaceH24(),
                Text(
                  'Personal Information',
                  style: AppTextStyles.cabinBold24DarkBlue,
                ),
                const SpaceH24(),

                // First Name
                AppTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  type: AppTextFieldType.text,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.mutedGray,
                    size: Sizes.ICON_SIZE_20,
                  ),
                ),
                const SpaceH16(),

                // Middle Name
                AppTextField(
                  controller: _middleNameController,
                  label: 'Middle Name',
                  type: AppTextFieldType.text,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.mutedGray,
                    size: Sizes.ICON_SIZE_20,
                  ),
                ),
                const SpaceH16(),

                // Last Name
                AppTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  type: AppTextFieldType.text,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.mutedGray,
                    size: Sizes.ICON_SIZE_20,
                  ),
                ),
                const SpaceH16(),

                // Gender
                AppTextField(
                  label: 'Gender',
                  type: AppTextFieldType.dropdown,
                  dropdownItems: _genders,
                  onDropdownChanged: (value) =>
                      setState(() => _selectedGender = value),
                  initialDropdownValue: _selectedGender,
                ),
                const SpaceH16(),

                // Date of Birth
                AppTextField(
                  controller: _dateOfBirthController,
                  label: 'Date of Birth',
                  hintText: 'dd/MM/yyyy',
                  type: AppTextFieldType.text,
                  prefixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.mutedGray,
                    size: Sizes.ICON_SIZE_18,
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SpaceH16(),

                // Marital Status
                AppTextField(
                  label: 'Marital Status',
                  type: AppTextFieldType.dropdown,
                  dropdownItems: _maritalStatuses,
                  onDropdownChanged: (value) =>
                      setState(() => _selectedMaritalStatus = value),
                  initialDropdownValue: _selectedMaritalStatus,
                ),
                const SpaceH16(),

                // Phone Number
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone number',
                  type: AppTextFieldType.phone,
                  prefix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('+234', style: AppTextStyles.interRegular14DarkBlue),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.mutedGray,
                        size: Sizes.ICON_SIZE_18,
                      ),
                      const SpaceW8(),
                      Container(
                        width: 1,
                        height: Sizes.ICON_SIZE_20,
                        color: AppColors.lightGray,
                      ),
                      const SpaceW8(),
                    ],
                  ),
                ),
                const SpaceH16(),

                // Email Address
                AppTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  type: AppTextFieldType.email,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.mutedGray,
                    size: Sizes.ICON_SIZE_20,
                  ),
                ),
                const SpaceH16(),

                // BVN
                AppTextField(
                  controller: _bvnController,
                  label: 'BVN',
                  type: AppTextFieldType.bvn,
                ),
                const SpaceH16(),

                // Address
                AppTextField(
                  controller: _addressController,
                  label: 'Address',
                  type: AppTextFieldType.text,
                ),
                const SpaceH16(),

                // City
                AppTextField(
                  controller: _cityController,
                  label: 'City',
                  type: AppTextFieldType.text,
                ),
                const SpaceH16(),

                // State
                AppTextField(
                  controller: _stateController,
                  label: 'State',
                  type: AppTextFieldType.text,
                ),
                const SpaceH16(),

                // Country
                AppTextField(
                  label: 'Country',
                  type: AppTextFieldType.dropdown,
                  dropdownItems: _countries,
                  onDropdownChanged: (value) =>
                      setState(() => _selectedCountry = value),
                  initialDropdownValue: _selectedCountry,
                ),

                // NIN (Optional)
                AppTextField(
                  controller: _ninController,
                  label: 'NIN (Optional)',
                  type: AppTextFieldType.nin,
                  validator: (value) {
                    final nin = value?.trim() ?? '';
                    if (nin.isEmpty) return null;
                    if (nin.length != 11) return 'NIN must be 11 digits';
                    return null;
                  },
                ),
                const SpaceH32(),

                // Continue Button
                AppButton(
                  text: 'Continue',
                  onPressed: _onContinuePressed,
                  isLoading: _isLoading,
                ),
                const SpaceH48(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
