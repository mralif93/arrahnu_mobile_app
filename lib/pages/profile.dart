import 'package:bmmb_pajak_gadai_i/components/QAvatar.dart';
import 'package:bmmb_pajak_gadai_i/components/QButton.dart';
import 'package:bmmb_pajak_gadai_i/components/QTextField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/user.dart';
import '../pages/navigation.dart';
import '../controllers/authorization.dart';
import '../constant/variables.dart';

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
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => NavigationPage()),
          (route) => false);
      return;
    }
  }

  void fetchProfile() async {
    final res = await AuthController().getUserProfile();
    setState(() {
      profile = res;

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
    // print("Failed to fetch profile!");
  }

  void updateProfile() async {
    final res = await AuthController().updateUserProfile(
      profile.id,
      fullnameController.text.toString(),
      identificationController.text.toString(),
      addressController.text.toString(),
      int.parse(postcodeController.text.toString()),
      cityController.text.toString(),
      stateController.text.toString(),
      countryController.text.toString(),
      int.parse(mobileController.text.toString()),
      int.parse(profile.user.toString()),
    );

    if (res) {
      Get.defaultDialog(
        title: Variables.successTitle,
        middleText: Variables.profileUpdatedText,
        textConfirm: Variables.okText,
        onConfirm: () {
          Navigator.pop(context);
        },
      );
    } else {
      Get.defaultDialog(
        title: Variables.failedTitle,
        middleText: Variables.profileUpdateFailedText,
        textConfirm: Variables.okText,
        onConfirm: () {
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Variables.appName,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            // avatar image
            QAvatar(
              name: '',
              mobile: '',
              image:
                  Variables.defaultAvatarUrl,
            ),

            // fullname text field
            QTextField(
              icon: const Icon(Icons.person),
              hintText: 'Full Name',
              controller: fullnameController,
              obscureText: false,
            ),

            // space
            const SizedBox(height: 6),

            // mykad text field
            QTextField(
              icon: const Icon(Icons.credit_card),
              hintText: 'Identification Card No.',
              controller: identificationController,
              obscureText: false,
            ),

            // space
            const SizedBox(height: 6),

            // mobile text field
            QTextField(
              icon: const Icon(Icons.phone),
              hintText: 'Mobile Number',
              controller: mobileController,
              obscureText: false,
            ),

            // space
            const SizedBox(height: 6),

            // address text field
            QTextField(
              icon: const Icon(Icons.location_on),
              hintText: 'Address',
              controller: addressController,
              obscureText: false,
            ),

            // space
            const SizedBox(height: 6),

            // postcode text field
            QTextField(
              icon: const Icon(Icons.location_on),
              hintText: 'Postcode',
              controller: postcodeController,
              obscureText: false,
            ),

            // space
            const SizedBox(height: 6),

            // city text field
            QTextField(
              icon: const Icon(Icons.location_on),
              hintText: 'City',
              controller: cityController,
              obscureText: false,
            ),

            // space
            const SizedBox(height: 6),

            // state text field
            QTextField(
              icon: const Icon(Icons.location_on),
              hintText: 'State',
              controller: stateController,
              obscureText: false,
            ),

            // space
            const SizedBox(height: 6),

            // country text field
            QTextField(
              icon: const Icon(Icons.location_on),
              hintText: 'Country',
              controller: countryController,
              obscureText: false,
            ),

            // space
            const SizedBox(height: 12),

            // update button
            QButton(
              text: 'Update',
              onTap: updateProfile,
            ),
          ],
        ),
      ),
    );
  }
}
