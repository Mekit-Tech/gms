import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mekit_gms/models/garage_model.dart';
import 'package:mekit_gms/provider/auth_provider.dart';
import 'package:mekit_gms/utils/utils.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  File? logo;
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    addressController.dispose();
  }

  // for selecting logo

  void selectImage() async {
    logo = await pickImage(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: false,
        title: SizedBox(
          width: 45,
          child: Image.asset('assets/icons/mekitblacklogo.png'),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 200,
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          splashColor: Colors.greenAccent.shade700,
          hoverColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () => storeData(),
          child: const Icon(
            Icons.arrow_forward,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => selectImage(),
                        child: logo == null
                            ? const CircleAvatar(
                                backgroundColor: Colors.black87,
                                radius: 40,
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                backgroundImage: FileImage(logo!),
                                radius: 40,
                              ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        margin: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            // Garage Name Field
                            TextFormField(
                              controller: nameController,
                              keyboardType: TextInputType.name,
                              maxLines: 1,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.black26)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.black26)),
                                hintText: 'Mekit Garage',
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            // Address Field
                            TextFormField(
                              controller: addressController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.black26)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.black26)),
                                hintText:
                                    '601, C1, Niraj City, Godrej Hills, Kalyan West',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Store new garage data to database
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    GarageModel garageModel = GarageModel(
      name: nameController.text.trim(),
      address: addressController.text.trim(),
      phoneNumber: "",
      garageLogo: "",
      createdAt: "",
      uid: "",
    );
    if (logo != null) {
      ap.saveUserDataToFirebase(
        context: context,
        garageModel: garageModel,
        garageLogo: logo!,
        onSuccess: () {},
      );
    } else {
      showSnackBar(context, "Please upload your Logo");
    }
  }
}
