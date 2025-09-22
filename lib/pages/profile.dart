import '../components/QAvatar.dart';
import '../components/QButton.dart';
import '../components/QTextField.dart';
import '../components/sweet_alert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/user.dart';
import '../pages/navigation.dart';
import '../pages/login.dart';
import '../pages/campaign.dart';
import '../pages/dashboard.dart';
import '../controllers/authorization.dart';
import '../constant/variables.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variables
  var profile = User(
    id: 0,
    idNum: '',
    fullName: '',
    address: '',
    postalCode: 0,
    city: '',
    state: '',
    country: '',
    hpNumber: 0,
    user: 0,
  );

  // Controller
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController identificationController =
      TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkSession();
    fetchProfile();
  }

  void checkSession() async {
    final res = await AuthController().session();
    if (!res) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false);
      }
      return;
    }
  }

  void fetchProfile() async {
    final response = await AuthController().getUserProfile();
    if (response.isSuccess && response.data != null) {
      if (mounted) {
        setState(() {
          profile = response.data!;

          // assign value
          fullnameController.text = profile.fullName.toUpperCase();
          identificationController.text = profile.idNum.toString();
          mobileController.text = profile.hpNumber.toString();
          addressController.text = profile.address.toString();
          postcodeController.text = profile.postalCode.toString();
          cityController.text = profile.city.toUpperCase();
          stateController.text = profile.state.toUpperCase();
          countryController.text = profile.country.toUpperCase();
        });
      }
    }
    // print("Failed to fetch profile!");
  }

  void updateProfile() async {
    try {
      // Validate required fields
      if (fullnameController.text.isEmpty || 
          identificationController.text.isEmpty ||
          mobileController.text.isEmpty) {
        SweetAlert.error(
          title: 'Validation Error',
          message: 'Please fill in all required fields.',
          confirmText: 'OK',
        );
        return;
      }

      print('Updating profile with data:');
      print('ID: ${profile.id}');
      print('Full Name: ${fullnameController.text}');
      print('ID Num: ${identificationController.text}');
      print('Address: ${addressController.text}');
      print('Postal Code: ${int.tryParse(postcodeController.text.toString()) ?? 0}');
      print('City: ${cityController.text}');
      print('State: ${stateController.text}');
      print('Country: ${countryController.text}');
      print('Mobile: ${int.tryParse(mobileController.text.toString()) ?? 0}');
      print('User: ${int.tryParse(profile.user.toString()) ?? 0}');

      final response = await AuthController().updateUserProfile(
        profile.id,
        fullnameController.text.toString(),
        identificationController.text.toString(),
        addressController.text.toString(),
        int.tryParse(postcodeController.text.toString()) ?? 0,
        cityController.text.toString(),
        stateController.text.toString(),
        countryController.text.toString(),
        int.tryParse(mobileController.text.toString()) ?? 0,
        int.tryParse(profile.user.toString()) ?? 0,
      );

      print('Update response:');
      print('Success: ${response.isSuccess}');
      print('Message: ${response.message}');
      if (response.error != null) {
        print('Error: ${response.error!.message}');
        print('Error Type: ${response.error!.type}');
        print('Status Code: ${response.error!.statusCode}');
      }

      if (mounted) {
        if (response.isSuccess) {
          SweetAlert.success(
            title: Variables.successTitle,
            message: Variables.profileUpdatedText,
            confirmText: Variables.okText,
            onConfirm: () {
              Get.back(); // Go back to dashboard
            },
          );
        } else {
          SweetAlert.error(
            title: Variables.failedTitle,
            message: response.error?.message ?? Variables.profileUpdateFailedText,
            confirmText: Variables.okText,
          );
        }
      }
    } catch (e) {
      print('Exception in updateProfile: $e');
      if (mounted) {
        SweetAlert.error(
          title: 'Error',
          message: 'An error occurred while updating profile: ${e.toString()}',
          confirmText: 'OK',
        );
      }
    }
  }

  void _showLogoutDialog() {
    SweetAlert.confirm(
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      onConfirm: () async {
        await _performLogout();
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final response = await AuthController().logout();

      // Close loading dialog
      Get.back();

      if (response.isSuccess && response.data == true) {
        // Show success message
        Get.snackbar(
          'Success',
          'You have been signed out successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Navigate to campaign page
        Get.offAll(const CampaignPage());
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          'Failed to sign out. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      // Show error message
      Get.snackbar(
        'Error',
        'An error occurred during sign out: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    fullnameController.dispose();
    identificationController.dispose();
    mobileController.dispose();
    addressController.dispose();
    postcodeController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: AppTheme.textWhite,
        elevation: 0,
        title: Text(
          'My Profile',
          style: AppTheme.getAppBarTitleStyle(scaleFactor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Personal Information Section
              _buildSectionHeader('Personal Information', Icons.person, scaleFactor),
              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
              
              QTextField(
                hintText: 'Full Name',
                controller: fullnameController,
                obscureText: false,
                icon: Icons.person,
                showCardStyle: true,
                fontSize: AppTheme.responsiveSize(9, scaleFactor),
              ),
              
              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
              
              QTextField(
                hintText: 'Identification Card No.',
                controller: identificationController,
                obscureText: false,
                icon: Icons.credit_card,
                showCardStyle: true,
                fontSize: AppTheme.responsiveSize(9, scaleFactor),
              ),
              
              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
              
              QTextField(
                hintText: 'Mobile Number',
                controller: mobileController,
                obscureText: false,
                icon: Icons.phone,
                showCardStyle: true,
                fontSize: AppTheme.responsiveSize(9, scaleFactor),
              ),

              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXXLarge, scaleFactor)),

              // Address Information Section
              _buildSectionHeader('Address Information', Icons.location_on, scaleFactor),
              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
              
              QTextField(
                hintText: 'Address',
                controller: addressController,
                obscureText: false,
                icon: Icons.home,
                showCardStyle: true,
                fontSize: AppTheme.responsiveSize(9, scaleFactor),
              ),
              
              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
              
              QTextField(
                hintText: 'Postcode',
                controller: postcodeController,
                obscureText: false,
                icon: Icons.location_city,
                showCardStyle: true,
                fontSize: AppTheme.responsiveSize(9, scaleFactor),
              ),
              
              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
              
              QTextField(
                hintText: 'City',
                controller: cityController,
                obscureText: false,
                icon: Icons.location_city,
                showCardStyle: true,
                fontSize: AppTheme.responsiveSize(9, scaleFactor),
              ),
              
              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
              
              QTextField(
                hintText: 'State',
                controller: stateController,
                obscureText: false,
                icon: Icons.map,
                showCardStyle: true,
                fontSize: AppTheme.responsiveSize(9, scaleFactor),
              ),
              
              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
              
              QTextField(
                hintText: 'Country',
                controller: countryController,
                obscureText: false,
                icon: Icons.public,
                showCardStyle: true,
                fontSize: AppTheme.responsiveSize(9, scaleFactor),
              ),

              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXXLarge, scaleFactor)),

              // Action Buttons
              _buildActionButtons(scaleFactor),

              SizedBox(height: AppTheme.responsiveSize(AppTheme.spacingXXLarge, scaleFactor)),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title, IconData icon, double scaleFactor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.responsiveSize(6, scaleFactor)),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryOrange,
            size: AppTheme.responsiveSize(16, scaleFactor),
          ),
        ),
        SizedBox(width: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor)),
        Text(
          title,
          style: TextStyle(
            fontSize: AppTheme.responsiveSize(14, scaleFactor),
            fontWeight: AppTheme.fontWeightSemiBold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(
    String hintText,
    IconData icon,
    TextEditingController controller,
    bool obscureText,
    double scaleFactor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusLarge, scaleFactor)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: AppTheme.getCaptionStyle(scaleFactor),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: AppTheme.primaryOrange,
            size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
          ),
          hintText: hintText,
          hintStyle: AppTheme.getCaptionStyle(scaleFactor).copyWith(
            color: AppTheme.textMuted,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusLarge, scaleFactor)),
            borderSide: BorderSide(
              color: AppTheme.borderLight,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.responsiveSize(AppTheme.radiusLarge, scaleFactor)),
            borderSide: BorderSide(
              color: AppTheme.primaryOrange,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppTheme.backgroundWhite,
          contentPadding: EdgeInsets.all(AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor)),
        ),
      ),
    );
  }

  // Helper method to build action buttons
  Widget _buildActionButtons(double scaleFactor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Update Profile Button
        QButton(
          text: 'Update Profile',
          onPressed: updateProfile,
          backgroundColor: AppTheme.primaryOrange,
          foregroundColor: AppTheme.textWhite,
          height: AppTheme.responsiveSize(36, scaleFactor),
          fontSize: AppTheme.responsiveSize(9, scaleFactor),
          fontWeight: AppTheme.fontWeightMedium,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
            vertical: AppTheme.responsiveSize(4, scaleFactor),
          ),
        ),
      ],
    );
  }
}
