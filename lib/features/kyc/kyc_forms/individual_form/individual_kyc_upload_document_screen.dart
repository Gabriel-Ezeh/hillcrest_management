import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/app/core/providers/user_local_storage_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
  // --- State (Storing bytes directly to prevent PathNotFoundException) ---
  bool _isLoading = false;
  Uint8List? _photoBytes;
  Uint8List? _poiBytes;
  Uint8List? _poaBytes;

  // Metadata for UI
  String? _poiSubtype;
  String? _poaSubtype;
  String? _poiFileName;
  String? _poaFileName;

  final ImagePicker _picker = ImagePicker();

  // Maximum file size in bytes (2MB)
  static const int _maxFileSize = 2 * 1024 * 1024;

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

  void _setDocumentData(DocumentType type, Uint8List data, {String? fileName}) {
    setState(() {
      switch (type) {
        case DocumentType.photoLiveness:
          _photoBytes = data;
          break;
        case DocumentType.identification:
          _poiBytes = data;
          _poiFileName = fileName;
          break;
        case DocumentType.proofOfAddress:
          _poaBytes = data;
          _poaFileName = fileName;
          break;
      }
    });
  }

  Future<void> _startLivenessCheck() async {
    try {
      final result = await context.router.push(const FaceCaptureRoute());

      if (!mounted || result is! File) return;

      final bytes = await result.readAsBytes();
      _setDocumentData(DocumentType.photoLiveness, bytes);
    } catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider).showError(
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

  bool _validateFileSize(int sizeInBytes) {
    if (sizeInBytes > _maxFileSize) {
      ref.read(notificationServiceProvider).showError(
          'File size exceeds 2MB limit. Please choose a smaller file.');
      return false;
    }
    return true;
  }

  Future<void> _pickFromGallery(DocumentType type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true, // Read bytes immediately
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        if (_validateFileSize(file.size)) {
          _setDocumentData(type, file.bytes!, fileName: file.name);
        }
      }
    } catch (e) {
      ref.read(notificationServiceProvider).showError('Failed to pick document. Please try again.');
    }
  }

  Future<void> _takePhoto(DocumentType type) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Slightly reduced quality to stay under 2MB
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (_validateFileSize(bytes.length)) {
          _setDocumentData(type, bytes, fileName: photo.name);
        }
      }
    } catch (e) {
      ref.read(notificationServiceProvider).showError('Failed to take photo. Please try again.');
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
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryColor),
              title: Text('Take Photo', style: AppTextStyles.cabinRegular14DarkBlue),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(type);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open, color: AppColors.primaryColor),
              title: Text('Choose File (PDF, PNG, JPG)', style: AppTextStyles.cabinRegular14DarkBlue),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(type);
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

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _onSubmitPressed() async {
    if (_photoBytes == null || _poiBytes == null || _poaBytes == null) {
      ref.read(notificationServiceProvider).showError('Please upload all required documents.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final userLocalStorage = ref.read(userLocalStorageProvider);
      final notificationService = ref.read(notificationServiceProvider);

      final customerNo = userLocalStorage.getPendingCustomerNo();
      if (customerNo == null || customerNo.isEmpty) {
        notificationService.showError('Customer number not found. Please complete personal information step.');
        return;
      }

      final username = await userLocalStorage.getUsername();
      if (username == null) {
        notificationService.showError('User information not found. Please login again.');
        return;
      }

      final realm = dotenv.env['CC_REALM']!;
      final adminToken = await authRepository.getAdminAuthToken();
      
      final users = await ref.read(authApiClientProvider).getUsers(
        realm: realm,
        username: username,
        adminToken: 'Bearer $adminToken',
      );

      if (users.isEmpty) {
        notificationService.showError('User details not found.');
        return;
      }

      final firstName = users.first.firstName ?? 'User';
      final lastName = users.first.lastName ?? '';

      final documents = [
        KycDocument(
          documentType: 'Photo',
          documentReference: customerNo,
          documentImage: _photoBytes!,
          documentComments: 'Customer photo',
        ),
        KycDocument(
          documentType: 'POI',
          documentReference: customerNo,
          documentImage: _poiBytes!,
          documentComments: 'POI: $_poiSubtype',
        ),
        KycDocument(
          documentType: 'POA',
          documentReference: customerNo,
          documentImage: _poaBytes!,
          documentComments: 'POA: $_poaSubtype',
        ),
      ];

      await authRepository.uploadKycDocuments(
        screenName: 'Individual KYC',
        fullName: '$firstName $lastName',
        customerNo: customerNo,
        documents: documents,
      );

      await authRepository.updateUserCustomerNo(username: username, customerNo: customerNo);
      await ref.read(authStateProvider.notifier).markKycCompleted(customerNo);

      if (!mounted) return;
      notificationService.showSuccess('KYC submission completed successfully');
      context.router.pushPath('/main/dashboard');

    } catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider).showError('Document upload failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              Row(
                children: [
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(2)))),
                  const SpaceW4(),
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(2)))),
                ],
              ),
              const SpaceH24(),
              Text('KYC Document Upload', style: AppTextStyles.cabinBold24DarkBlue),
              const SpaceH8(),
              Text(
                'Accepted formats: PDF, PNG, JPG (Max 2MB per file)',
                style: AppTextStyles.cabinRegular14MutedGray.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
              ),
              const SpaceH24(),

              _DocumentUploadCard(
                icon: Icons.camera_alt_outlined,
                title: 'Live Photo',
                subtitle: _photoBytes != null ? 'Liveness check completed' : 'Complete a smile verification check',
                helperText: _photoBytes != null ? 'Format: Image' : 'Selfie will be captured automatically',
                isUploaded: _photoBytes != null,
                onTap: () => _showUploadOptions(DocumentType.photoLiveness),
              ),
              const SpaceH16(),

              _DocumentUploadCard(
                icon: Icons.badge_outlined,
                title: 'Proof of Identity',
                subtitle: _poiBytes != null ? (_poiSubtype ?? 'Document uploaded') : 'Select and upload valid ID',
                helperText: _poiBytes != null 
                    ? 'Size: ${_formatSize(_poiBytes!.length)} | ${_poiFileName ?? 'File Ready'}'
                    : 'Clear scan of ID (National ID, Passport, etc.)',
                isUploaded: _poiBytes != null,
                onTap: () => _showSubtypeSelector(DocumentType.identification),
              ),
              const SpaceH16(),

              _DocumentUploadCard(
                icon: Icons.home_outlined,
                title: 'Proof of Address',
                subtitle: _poaBytes != null ? (_poaSubtype ?? 'Document uploaded') : 'Select and upload address proof',
                helperText: _poaBytes != null 
                    ? 'Size: ${_formatSize(_poaBytes!.length)} | ${_poaFileName ?? 'File Ready'}'
                    : 'Utility bill issued within last 3 months',
                isUploaded: _poaBytes != null,
                onTap: () => _showSubtypeSelector(DocumentType.proofOfAddress),
              ),
              const SpaceH32(),

              AppButton(text: 'Submit KYC', onPressed: _onSubmitPressed, isLoading: _isLoading),
              const SpaceH48(),
            ],
          ),
        ),
      ),
    );
  }
}

enum DocumentType { photoLiveness, identification, proofOfAddress }

class _DocumentUploadCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String helperText;
  final bool isUploaded;
  final VoidCallback onTap;

  const _DocumentUploadCard({
    required this.icon, required this.title, required this.subtitle, 
    required this.helperText, required this.isUploaded, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(Sizes.PADDING_16),
        decoration: BoxDecoration(
          border: Border.all(color: isUploaded ? AppColors.successGreen : AppColors.lightGray),
          borderRadius: BorderRadius.circular(12),
          color: isUploaded ? AppColors.successGreen.withValues(alpha: 0.05) : Colors.transparent,
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
                  Text(helperText, style: AppTextStyles.cabinRegular14MutedGray.copyWith(fontSize: 11, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isUploaded ? AppColors.successGreen : AppColors.lightGray, width: 2), color: isUploaded ? AppColors.successGreen : Colors.transparent),
              child: Icon(isUploaded ? Icons.check : Icons.add, color: isUploaded ? Colors.white : AppColors.mutedGray, size: Sizes.ICON_SIZE_18),
            ),
          ],
        ),
      ),
    );
  }
}
