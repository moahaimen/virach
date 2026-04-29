import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/doctor_model.dart';
import '../services/api_client.dart';

class DoctorRetroProvider with ChangeNotifier {
  late ApiClient _apiClient;

  DoctorRetroProvider() {
    Dio dio = Dio();
    dio.options.headers["Authorization"] =
        "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzI4OTMwNTQ5LCJpYXQiOjE3Mjg5MjY5NDksImp0aSI6IjI1MDljNWNkNjljNDQ2MWY5YjVhZTE2NjNhMWUwNTY2IiwidXNlcl9pZCI6IjZkY2EwZTUwLWJmMmQtNDcxZC04NmZmLTE3ZjVlODIyZDk4YyJ9.J14bX0cDoqyQJJsEC3NP6FZPD146VhWpcXEfRgol1AM"; // Replace with actual token
    _apiClient = ApiClient(dio);
  }

  Future<void> addDoctor(DoctorAPI doctor) async {
    try {
      DoctorAPI createdDoctor = await _apiClient.createDoctor(doctor);
      print("Doctor created successfully: ${createdDoctor.toJson()}");
    } catch (e) {
      print("Failed to create doctor: $e");
    }
  }

  // Method to fetch all doctors
  // Future<List<DoctorAPI>> getDoctors() async {
  //   try {
  //     List<DoctorAPI> doctors = await _apiClient.getDoctors(specialty);
  //     return doctors;
  //   } catch (e) {
  //     print("Failed to fetch doctors: $e");
  //     return [];
  //   }
  // }

  // Method to fetch doctors based on specialty
  Future<List<DoctorAPI>> getDoctorsBySpecialty(String specialty) async {
    try {
      print("Fetching doctors with specialty: $specialty"); // Debugging print
      List<DoctorAPI> doctors =
          await _apiClient.getDoctors(specialty); // Pass the specialty
      print("Doctors fetched: ${doctors.length}"); // Debugging print
      return doctors;
    } catch (e) {
      print("Failed to fetch doctors: $e");
      return [];
    }
  }
}
