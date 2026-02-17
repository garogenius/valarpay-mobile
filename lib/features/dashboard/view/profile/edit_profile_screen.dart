import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/responsive_text_field.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _occupationController;
  late TextEditingController _primaryPurposeController;
  late TextEditingController _sourceOfFundsController;
  late TextEditingController _expectedInflowController;
  late TextEditingController _passportNumberController;
  late TextEditingController _passportCountryController;

  String? _employmentStatus;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    
    _fullNameController = TextEditingController(text: user?.fullname);
    _phoneNumberController = TextEditingController(text: user?.phoneNumber);
    _dobController = TextEditingController(text: user?.dateOfBirth);
    _addressController = TextEditingController(text: user?.address);
    _cityController = TextEditingController(text: user?.city);
    _stateController = TextEditingController(text: user?.state);
    _postalCodeController = TextEditingController(text: user?.postalCode);
    _occupationController = TextEditingController(text: user?.occupation);
    _primaryPurposeController = TextEditingController(text: user?.primaryPurpose);
    _sourceOfFundsController = TextEditingController(text: user?.sourceOfFunds);
    _expectedInflowController =
        TextEditingController(text: user?.expectedMonthlyInflow?.toString());
    _passportNumberController = TextEditingController(text: user?.passportNumber);
    _passportCountryController = TextEditingController(text: user?.passportCountry);
    _employmentStatus = user?.employmentStatus;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _occupationController.dispose();
    _primaryPurposeController.dispose();
    _sourceOfFundsController.dispose();
    _expectedInflowController.dispose();
    _passportNumberController.dispose();
    _passportCountryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(userNotifierProvider.notifier).editProfile(
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        dateOfBirth: _dobController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _postalCodeController.text,
        employmentStatus: _employmentStatus,
        occupation: _occupationController.text,
        primaryPurpose: _primaryPurposeController.text,
        sourceOfFunds: _sourceOfFundsController.text,
        expectedMonthlyInflow: double.tryParse(_expectedInflowController.text),
        passportNumber: _passportNumberController.text,
        passportCountry: _passportCountryController.text,
        profileImagePath: _imageFile?.path,
      );

      if (mounted) {
        AppMessenger.show(
          context,
          message: 'Profile updated successfully',
          type: MessageType.success,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppMessenger.show(
          context,
          message: e.toString(),
          type: MessageType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final userState = ref.watch(userNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider
                          : (user?.profileImageUrl != null
                              ? NetworkImage(user!.profileImageUrl!)
                              : null),
                      child: _imageFile == null && user?.profileImageUrl == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF76301),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              
              ResponsiveTextField(
                controller: _fullNameController,
                hintText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (v) => v!.isEmpty ? 'Enter full name' : null,
              ),
              const SizedBox(height: 12),
              
              ResponsiveTextField(
                controller: _phoneNumberController,
                hintText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: ResponsiveTextField(
                    controller: _dobController,
                    hintText: 'Date of Birth (YYYY-MM-DD)',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Address Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              
              ResponsiveTextField(
                controller: _addressController,
                hintText: 'Street Address',
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: ResponsiveTextField(
                      controller: _cityController,
                      hintText: 'City',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ResponsiveTextField(
                      controller: _stateController,
                      hintText: 'State',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              ResponsiveTextField(
                controller: _postalCodeController,
                hintText: 'Postal Code',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              const Text('Background Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _employmentStatus,
                decoration: InputDecoration(
                  labelText: 'Employment Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                ),
                items: ['employed', 'self_employed', 'unemployed', 'student', 'retired']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _employmentStatus = v),
              ),
              const SizedBox(height: 12),

              ResponsiveTextField(
                controller: _occupationController,
                hintText: 'Occupation',
              ),
              const SizedBox(height: 12),

              ResponsiveTextField(
                controller: _primaryPurposeController,
                hintText: 'Primary Purpose',
              ),
              const SizedBox(height: 12),

              ResponsiveTextField(
                controller: _sourceOfFundsController,
                hintText: 'Source of Funds',
              ),
              const SizedBox(height: 12),

              ResponsiveTextField(
                controller: _expectedInflowController,
                hintText: 'Expected Monthly Inflow',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 32),

              FullWidthButton(
                text: 'Save Changes',
                isLoading: userState.isInitialLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
