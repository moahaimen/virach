// widgets/create_hsp/user_form_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserFormWidget extends StatefulWidget {
  final bool isGmailRegistration;
  final Map<String, String>? userCredentials;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;
  final File? profileImage;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickImage;

  UserFormWidget({
    required this.isGmailRegistration,
    required this.userCredentials,
    required this.emailController,
    required this.nameController,
    required this.passwordController,
    required this.phoneController,
    required this.profileImage,
    required this.onTakePhoto,
    required this.onPickImage,
    Key? key,
  }) : super(key: key);

  @override
  _UserFormWidgetState createState() => _UserFormWidgetState();
}

class _UserFormWidgetState extends State<UserFormWidget> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.key as GlobalKey<FormState>,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // نقل مُباشر لما كان في _buildProfileImageSection()
          GestureDetector(
            onTap: widget.isGmailRegistration ? null : widget.onPickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: widget.isGmailRegistration
                  ? (widget.userCredentials?['photoUrl'] != null
                  ? NetworkImage(widget.userCredentials!['photoUrl']!)
                  : const AssetImage('assets/icons/doctor_icon.png')
              as ImageProvider)
                  : (widget.profileImage != null
                  ? FileImage(widget.profileImage!)
                  : const AssetImage('assets/icons/doctor_icon.png')
              as ImageProvider),
              child: widget.isGmailRegistration
                  ? null
                  : (widget.profileImage == null
                  ? const Icon(Icons.camera_alt)
                  : null),
            ),
          ),
          const SizedBox(height: 10),
          if (!widget.isGmailRegistration) _buildPhotoButtons(),
          const SizedBox(height: 10),
          if (!widget.isGmailRegistration) _buildEmailField(),
          const SizedBox(height: 10),
          _buildNameField(),
          const SizedBox(height: 10),
          if (!widget.isGmailRegistration) _buildPasswordField(),
          const SizedBox(height: 10),
          _buildPhoneField(),
        ],
      ),
    );
  }

  Widget _buildPhotoButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: widget.onTakePhoto,
          child: const Text("التقط صورة"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: widget.onPickImage,
          child: const Text("اختر صورة من المعرض"),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      children: [
        TextFormField(
          controller: widget.emailController,
          decoration: const InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) return "الرجاء إدخال البريد الإلكتروني";
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value.trim())) return "صيغة البريد الإلكتروني غير صالحة";
            return null;
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: widget.nameController,
      decoration: const InputDecoration(
        labelText: "اسم الشخص",
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
        if (value.length < 3) return "الاسم قصير جدا";
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return Column(
      children: [
        TextFormField(
          controller: widget.passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "الرجاء إدخال كلمة المرور";
            if (value.length < 6) return "يجب أن تكون أطول من 6 أحرف";
            return null;
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: widget.phoneController,
        keyboardType: TextInputType.phone,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          prefix: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('+964', style: TextStyle(fontSize: 16)),
          ),
          prefixIcon: Icon(Icons.phone),
          labelText: 'رقم المحمول',
          counterText: '',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'يرجى إدخال رقم الهاتف';
          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return 'يجب أن يكون 10 أرقام (بدون +964)';
          return null;
        },
      ),
    );
  }
}
