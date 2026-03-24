import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/app/core/providers/user_local_storage_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hillcrest_finance/features/kyc/data/models/kyc_document_submission_request.dart';
import 'package:hillcrest_finance/app/core/providers/networking_provider.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';

// --- Custom Imports ---
import '../../../../app/core/exceptions/network_exceptions.dart';
import '../../../../app/core/providers/notification_service_provider.dart';
import '../../../../ui/widgets/app_button.dart';
import '../../../../utils/constants/values.dart';
import 'dart:typed_data';
import 'dart:convert';

@RoutePage()
class IndividualKycDocumentUploadScreen extends ConsumerStatefulWidget {
  const IndividualKycDocumentUploadScreen({super.key});

  @override
  ConsumerState<IndividualKycDocumentUploadScreen> createState() =>
      _IndividualKycDocumentUploadScreenState();
}

class _IndividualKycDocumentUploadScreenState
    extends ConsumerState<IndividualKycDocumentUploadScreen> {
  // --- State ---
  bool _isLoading = false;
  File? _photoLivenessCheck;
  File? _meansOfIdentification;
  File? _proofOfAddress;

  // Store selected subtypes
  String? _poiSubtype;
  String? _poaSubtype;

  final ImagePicker _picker = ImagePicker();

  // Document subtype options
  final Map<String, List<String>> _documentSubtypes = {
    'poi': [
      'NIN (National Identity Number)',
      'Driver\'s License',
      'International Passport',
      'Voter\'s Card',
    ],
    'poa': [
      'Electricity Bill',
      'Bank Statement',
      'Water Bill',
      'Waste Bill',
      'House Rent Receipt',
      'Tenancy Agreement',
      'Land Use Charge',
    ],
  };

  void _setDocumentFile(DocumentType type, String path) {
    final file = File(path);

    setState(() {
      switch (type) {
        case DocumentType.photoLiveness:
          _photoLivenessCheck = file;
          break;
        case DocumentType.identification:
          _meansOfIdentification = file;
          break;
        case DocumentType.proofOfAddress:
          _proofOfAddress = file;
          break;
      }
    });
  }

  Future<void> _startLivenessCheck() async {
    try {
      final result = await context.router.push(const LivenessCheckRoute());

      if (!mounted || result is! File) return;

      _setDocumentFile(DocumentType.photoLiveness, result.path);
    } catch (_) {
      if (mounted) {
        ref
            .read(notificationServiceProvider)
            .showError(
              'Unable to complete the liveness check. Please try again.',
            );
      }
    }
  }

  void _showSubtypeSelector(DocumentType type) {
    final subtypes = type == DocumentType.identification
        ? _documentSubtypes['poi']!
        : _documentSubtypes['poa']!;

    final title = type == DocumentType.identification
        ? 'Select ID Type'
        : 'Select Proof of Address Type';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(Sizes.PADDING_24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.cabinBold18DarkBlue),
              const SpaceH16(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: subtypes.length,
                  itemBuilder: (context, index) {
                    final subtype = subtypes[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.description_outlined,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        subtype,
                        style: AppTextStyles.cabinRegular14DarkBlue,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (type == DocumentType.identification) {
                          setState(() => _poiSubtype = subtype);
                        } else {
                          setState(() => _poaSubtype = subtype);
                        }
                        _showUploadOptions(type);
                      },
                    );
                  },
                ),
              ),
              const SpaceH16(),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.cabinRegular14Primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocument(DocumentType type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _setDocumentFile(type, image.path);
      }
    } catch (e) {
      ref
          .read(notificationServiceProvider)
          .showError('Failed to pick document. Please try again.');
    }
  }

  Future<void> _takePhoto(DocumentType type) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        _setDocumentFile(type, photo.path);
      }
    } catch (e) {
      ref
          .read(notificationServiceProvider)
          .showError('Failed to take photo. Please try again.');
    }
  }

  void _showUploadOptions(DocumentType type) {
    if (type == DocumentType.photoLiveness) {
      _startLivenessCheck();
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(Sizes.PADDING_24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.primaryColor,
              ),
              title: Text(
                'Take Photo',
                style: AppTextStyles.cabinRegular14DarkBlue,
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(type);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primaryColor,
              ),
              title: Text(
                'Choose from Gallery',
                style: AppTextStyles.cabinRegular14DarkBlue,
              ),
              onTap: () {
                Navigator.pop(context);
                _pickDocument(type);
              },
            ),
            const SpaceH16(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTextStyles.cabinRegular14Primary),
            ),
          ],
        ),
      ),
    );
  }

  // Add this helper method here
  String _truncateBinaryData(Uint8List? data, {int maxLength = 50}) {
    if (data == null) return 'null';
    if (data.length <= maxLength) return base64Encode(data);
    return '${base64Encode(data.sublist(0, maxLength))}... (${data.length} bytes total)';
  }

  Future<void> _onSubmitPressed() async {
    if (_photoLivenessCheck == null ||
        _meansOfIdentification == null ||
        _proofOfAddress == null) {
      ref
          .read(notificationServiceProvider)
          .showError('Please upload all required documents.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Cache all provider reads BEFORE any async operations
      final authRepository = ref.read(authRepositoryProvider);
      final userLocalStorage = ref.read(userLocalStorageProvider);
      final notificationService = ref.read(notificationServiceProvider);

      // Step 1: Retrieve customerNo from storage
      final customerNo = userLocalStorage.getPendingCustomerNo();
      if (customerNo == null || customerNo.isEmpty) {
        notificationService.showError(
          'Customer number not found. Please complete personal information step.',
        );
        return;
      }

      // Fetch username and get user data from Keycloak
      final username = await userLocalStorage.getUsername();
      if (username == null) {
        if (mounted) {
          notificationService.showError(
            'User information not found. Please login again.',
          );
        }
        return;
      }

      // Get user details from Keycloak
      final realm = dotenv.env['CC_REALM']!;
      final adminToken = await authRepository.getAdminAuthToken();
      final bearerAdminToken = 'Bearer $adminToken';

      final authApiClient = ref.read(authApiClientProvider);
      final users = await authApiClient.getUsers(
        realm: realm,
        username: username,
        adminToken: bearerAdminToken,
      );

      if (users.isEmpty) {
        if (mounted) {
          notificationService.showError('User details not found.');
        }
        return;
      }

      final firstName = users.first.firstName ?? 'User';
      final lastName = users.first.lastName ?? '';

      print('[KYC_UI] Starting KYC document upload...');
      print('[KYC_UI] CustomerNo: $customerNo');
      print('[KYC_UI] Username: $username');

      // Step 2: Convert files to Uint8List and create KycDocument list
      print('[KYC_UI] Converting images to bytes...');
      final photoBytes = await _photoLivenessCheck!.readAsBytes();
      final idBytes = await _meansOfIdentification!.readAsBytes();
      final addressBytes = await _proofOfAddress!.readAsBytes();

      // Use truncated output in prints
      print('[KYC_UI] Photo: ${_truncateBinaryData(photoBytes)}');
      print('[KYC_UI] ID: ${_truncateBinaryData(idBytes)}');
      print('[KYC_UI] Proof of Address: ${_truncateBinaryData(addressBytes)}');

      final documents = [
        KycDocument(
          documentType: 'Photo',
          documentReference: customerNo,
          documentImage: photoBytes,
          documentComments: 'Customer photo',
        ),
        KycDocument(
          documentType: 'POI',
          documentReference: customerNo,
          documentImage: idBytes,
          documentComments: _poiSubtype != null
              ? 'Proof of identity: $_poiSubtype'
              : 'Proof of identity',
        ),
        KycDocument(
          documentType: 'POA',
          documentReference: customerNo,
          documentImage: addressBytes,
          documentComments: _poaSubtype != null
              ? 'Proof of address: $_poaSubtype'
              : 'Proof of address',
        ),
      ];

      print('[KYC_UI] Created ${documents.length} documents');
      print('[KYC_UI] Calling uploadKycDocuments...');
      // Step 3: Upload KYC documents
      await authRepository.uploadKycDocuments(
        screenName: 'Individual KYC',
        fullName: '$firstName $lastName',
        customerNo: customerNo,
        documents: documents,
      );

      print('[KYC_UI] Documents uploaded successfully');

      // Step 4: update Keycloak with customerNo
      print('[KYC_UI] Updating Keycloak with customerNo...');
      await authRepository.updateUserCustomerNo(
        username: username,
        customerNo: customerNo,
      );
      print('[KYC_UI] Keycloak updated successfully');

      // Step 5: mark KYC complete locally so post-navigation checks use fresh state
      await ref.read(authStateProvider.notifier).markKycCompleted(customerNo);
      print('[KYC_UI] Auth state updated locally with completed KYC');

      if (!mounted) return;
      notificationService.showSuccess('KYC submission completed successfully');

      // Step 6: Navigate to next screen
      if (mounted) {
        context.router.pushPath('/main/dashboard');
      }
    } on ClientException catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider).showError(e.message);
      }
      print('[KYC_UI] ClientException: ${e.message}');
    } on NetworkException catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider).showError(e.message);
      }
      print('[KYC_UI] NetworkException: ${e.message}');
    } catch (e) {
      if (mounted) {
        ref
            .read(notificationServiceProvider)
            .showError('Document upload failed. Please try again.');
      }
      print('[KYC_UI] Error during document submission: $e');
      print('[KYC_UI] Error type: ${e.runtimeType}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SpaceW4(),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SpaceH24(),
              Text(
                'KYC Document Upload',
                style: AppTextStyles.cabinBold24DarkBlue,
              ),
              const SpaceH24(),

              // Photo - Liveness Check
              _DocumentUploadCard(
                icon: Icons.camera_alt_outlined,
                title: 'Photo',
                subtitle: _photoLivenessCheck != null
                    ? 'Document uploaded'
                    : 'Complete a smile verification check',
                helperText:
                    'We will capture your selfie automatically once you smile',
                isUploaded: _photoLivenessCheck != null,
                onTap: () => _showUploadOptions(DocumentType.photoLiveness),
              ),
              const SpaceH16(),

              // Proof of Identity
              _DocumentUploadCard(
                icon: Icons.badge_outlined,
                title: 'Proof of Identity',
                subtitle: _meansOfIdentification != null
                    ? (_poiSubtype ?? 'Document uploaded')
                    : 'Select and upload valid ID',
                helperText:
                    'Upload one valid government-issued ID (NIN, Driver\'s License, etc.)',
                isUploaded: _meansOfIdentification != null,
                onTap: () => _showSubtypeSelector(DocumentType.identification),
              ),
              const SpaceH16(),

              // Proof of Address
              _DocumentUploadCard(
                icon: Icons.home_outlined,
                title: 'Proof of Address',
                subtitle: _proofOfAddress != null
                    ? (_poaSubtype ?? 'Document uploaded')
                    : 'Select and upload address proof',
                helperText:
                    'Upload utility bill or financial document issued within 3 months',
                isUploaded: _proofOfAddress != null,
                onTap: () => _showSubtypeSelector(DocumentType.proofOfAddress),
              ),
              const SpaceH32(),

              // Submit Button
              AppButton(
                text: 'Submit',
                onPressed: _onSubmitPressed,
                isLoading: _isLoading,
              ),
              const SpaceH48(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Document Type Enum ---
enum DocumentType { photoLiveness, identification, proofOfAddress }

// --- Document Upload Card Widget ---
class _DocumentUploadCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String helperText;
  final bool isUploaded;
  final VoidCallback onTap;

  const _DocumentUploadCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.helperText,
    required this.isUploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(Sizes.PADDING_16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isUploaded ? AppColors.successGreen : AppColors.lightGray,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isUploaded
              ? AppColors.successGreen.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkBlue, size: Sizes.ICON_SIZE_24),
            const SpaceW12(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.interSemiBold14DarkBlue),
                  const SpaceH4(),
                  Text(subtitle, style: AppTextStyles.cabinRegular14MutedGray),
                  const SpaceH4(),
                  Text(
                    helperText,
                    style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUploaded
                      ? AppColors.successGreen
                      : AppColors.lightGray,
                  width: 2,
                ),
                color: isUploaded ? AppColors.successGreen : Colors.transparent,
              ),
              child: isUploaded
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: Sizes.ICON_SIZE_18,
                    )
                  : const Icon(
                      Icons.add,
                      color: AppColors.mutedGray,
                      size: Sizes.ICON_SIZE_18,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
