import 'package:flutter/foundation.dart';

import '../models/jobs_models/application_model.dart';
import '../models/hsp_models/beauty_center_model.dart';

import '../models/hsp_models/doctors_model.dart';
import '../models/hsp_models/hospital_model.dart';
import '../models/hsp_models/laboratory_model.dart';
import '../models/hsp_models/medical_center_model.dart';
import '../models/hsp_models/nurse_models.dart';
import '../models/hsp_models/pharmacist_model.dart';
import '../models/hsp_models/therapist_model.dart';
import '../models/jobs_models/job_notification_model.dart';

import '../models/jobs_models/job_posting_model.dart';
import '../models/jobs_models/job_seeker_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/review_model.dart';

class MockDataProvider extends ChangeNotifier {
  // Mock data for doctors
  final List<Doctor> _doctors = [
    Doctor(
      doctorId: 1,
      userId: 1,
      name: 'Dr. John Doe',
      specialty: 'Cardiology',
      degrees: 'MD, FACC',
      bio: 'Experienced cardiologist with 15 years of practice.',
      address: '123 Medical St, Baghdad',
      availabilityTime: '9 AM - 5 PM',
      advertise: true,
      advertisePrice: 200.00,
      advertiseDuration: 'month',
      profileImage: null,
      phoneNumber: 5551234567,
      isInternational: false,
      country: 'Iraq',
      homeVisit: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more doctors as mock data
  ];

  // Mock data for nurses
  final List<Nurse> _nurses = [
    Nurse(
      nurseId: 1,
      userId: 2,
      gpsLocation: '',
      name: 'Nurse Jane Smith',
      specialty: 'Pediatrics',
      bio: '5 years of experience in pediatric care.',
      degree: 'BSc Nursing',
      address: '456 Nursing Rd, Baghdad',
      availabilityTime: '8 AM - 4 PM',
      advertise: true,
      advertisePrice: 150.00,
      advertiseDuration: 'year',
      profileImage: null,
      phoneNumber: 5559876543,
      homeVisit: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more nurses as mock data
  ];

  // Mock data for therapists
  final List<Therapist> _therapists = [
    Therapist(
      therapistId: 1,
      gpsLocation: '',
      userId: 3,
      name: 'Therapist Emily Green',
      degree: 'MSc Physical Therapy',
      bio: '7 years of experience in physical therapy and rehabilitation.',
      address: '789 Therapy Ave, Baghdad',
      availabilityTime: '10 AM - 6 PM',
      advertise: true,
      advertisePrice: 180.00,
      advertiseDuration: 'month',
      profileImage: null,
      phoneNumber: 5552233445,
      homeVisit: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more therapists as mock data
  ];

  // Mock data for pharmacists
  final List<Pharmacist> _pharmacists = [
    Pharmacist(
      pharmacistId: 1,
      userId: 4,
      pharmacyName: 'City Pharmacy',
      address: '101 Pharmacy St, Baghdad',
      bio: 'Community pharmacist with 10 years of experience.',
      availabilityTime: '24/7',
      gpsLocation: '33.3152,44.3661',
      onDutyPharmacy: true,
      advertise: true,
      advertisePrice: 250.00,
      advertiseDuration: 'year',
      profileImage: null,
      phoneNumber: 5554455667,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more pharmacists as mock data
  ];

  // Mock data for laboratories
  final List<Laboratory> _laboratories = [
    Laboratory(
      laboratoryId: 1,
      userId: 5,
      laboratoryName: 'Advanced Medical Labs',
      availableTests: 'Blood test, DNA analysis',
      bio: 'State-of-the-art medical laboratory services.',
      address: '202 Lab St, Baghdad',
      availabilityTime: '8 AM - 6 PM',
      gpsLocation: '33.3152,44.3661',
      advertise: true,
      advertisePrice: 300.00,
      advertiseDuration: 'year',
      profileImage: null,
      phoneNumber: 5557788990,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more laboratories as mock data
  ];

  // Mock data for hospitals
  final List<Hospital> _hospitals = [
    Hospital(
      hospitalId: 1,
      userId: 6,
      hospitalName: 'Baghdad General Hospital',
      specialty: 'General Medicine',
      administration: 'Government',
      bio: 'Largest government hospital in Baghdad.',
      address: '303 Hospital St, Baghdad',
      availabilityTime: '24/7',
      gpsLocation: '33.3152,44.3661',
      advertise: true,
      advertisePrice: 500.00,
      advertiseDuration: 'year',
      profileImage: null,
      phoneNumber: 5559988776,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more hospitals as mock data
  ];

  // Mock data for medical centers
  final List<MedicalCenter> _medicalCenters = [
    MedicalCenter(
      centerId: 1,
      userId: 7,
      centerName: 'City Medical Center',
      directorName: 'Dr. Sarah Ali',
      bio: 'Comprehensive healthcare services for the community.',
      address: '404 Center St, Baghdad',
      availabilityTime: '9 AM - 8 PM',
      gpsLocation: '33.3152,44.3661',
      advertise: true,
      advertisePrice: 400.00,
      advertiseDuration: 'year',
      profileImage: null,
      phoneNumber: 5551122334,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more medical centers as mock data
  ];

  // Mock data for beauty centers
  final List<BeautyCenter> _beautyCenters = [
    BeautyCenter(
      beautyCenterId: 1,
      userId: 8,
      centerName: 'Luxury Beauty Spa',
      bio: 'Premium beauty treatments and wellness services.',
      address: '505 Beauty St, Baghdad',
      availabilityTime: '10 AM - 9 PM',
      gpsLocation: '33.3152,44.3661',
      advertise: true,
      advertisePrice: 350.00,
      advertiseDuration: 'year',
      profileImage: null,
      phoneNumber: 5552211445,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more beauty centers as mock data
  ];

  // Mock data for job seekers
  final List<JobSeeker> _jobSeekers = [
    JobSeeker(
      jobSeekerId: 1,
      fullName: 'Ali Hasan',
      phoneNumber: 5553322110,
      profileImage: null,
      specialty: 'Nurse',
      degree: 'BSc Nursing',
      degreeImage: null,
      address: '606 Job Seeker St, Baghdad',
      email: 'ali@example.com',
      password: 'password123',
      gpsLocation: null,
      birthDate: DateTime(1979, 6, 15),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more job seekers as mock data
  ];

  // Mock data for offers
  // final List<Offer> _offers = [
  //   Offer(
  //     offerId: 1,
  //     serviceProviderId: 1,
  //     serviceProviderType: 'doctor',
  //     offerTitle: '50% Off for New Patients',
  //     offerDescription: 'Special offer for first-time consultations.',
  //     offerImage: null,
  //     discountPercentage: 50.00,
  //     originalPrice: 100.00,
  //     discountedPrice: 50.00,
  //     periodOfTime: '1 week',
  //     startDate: DateTime.now(),
  //     endDate: DateTime.now().add(Duration(days: 7)),
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //     name: '',
  //     image: '',
  //     discount: '',
  //     price: '',
  //     oldPrice: '',
  //     rating: 3,
  //     reviews: 5,
  //     doctorName: '',
  //     location: '',
  //   ),
  //   // Add two more offers as mock data
  // ];

  // Mock data for reviews
  final List<Review> _reviews = [
    Review(
      reviewId: 1,
      userId: 2,
      serviceProviderType: 'doctor',
      serviceProviderId: 1,
      rating: 5,
      reviewText: 'Excellent service and care!',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more reviews as mock data
  ];

  // Mock data for messages
  final List<Message> _messages = [
    Message(
      messageId: 1,
      senderId: 1,
      receiverId: 2,
      messageText: 'Hello, I would like to schedule an appointment.',
      messageImage: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more messages as mock data
  ];

  // Mock data for notifications
  final List<NotificationModel> _notifications = [
    NotificationModel(
      notificationId: 1,
      userId: 1,
      notificationText: 'You have a new appointment confirmation.',
      createdAt: DateTime.now(),
    ),
    // Add two more notifications as mock data
  ];

  // Mock data for job postings
  final List<JobPosting> _jobPostings = [
    JobPosting(
      jobId: 1,
      serviceProviderId: 1,
      serviceProviderType: 'doctor',
      jobTitle: 'Nurse Needed',
      jobDescription: 'Looking for an experienced nurse for a busy clinic.',
      qualifications: 'BSc Nursing, 2+ years experience',
      salary: 1000.00,
      jobLocation: 'Baghdad, Iraq',
      jobStatus: 'open',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more job postings as mock data
  ];

  // Mock data for applications
  final List<Application> _applications = [
    Application(
      applicationId: 1,
      jobSeekerId: 1,
      jobId: 1,
      resume: 'My resume is attached.',
      coverLetter: 'I am very interested in the nursing position.',
      applicationStatus: 'submitted',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add two more applications as mock data
  ];

  // Mock data for job notifications
  final List<JobNotification> _jobNotifications = [
    JobNotification(
      notificationId: 1,
      jobId: 1,
      jobSeekerId: 1,
      notificationText: 'Your application for Nurse has been received.',
      createdAt: DateTime.now(),
    ),
    // Add two more job notifications as mock data
  ];

  List<Doctor> get doctors => _doctors;
  List<Nurse> get nurses => _nurses;
  List<Therapist> get therapists => _therapists;
  List<Pharmacist> get pharmacists => _pharmacists;
  List<Laboratory> get laboratories => _laboratories;
  List<Hospital> get hospitals => _hospitals;
  List<MedicalCenter> get medicalCenters => _medicalCenters;
  List<BeautyCenter> get beautyCenters => _beautyCenters;
  List<JobSeeker> get jobSeekers => _jobSeekers;
  // List<Offer> get offers => _offers;
  List<Review> get reviews => _reviews;
  List<Message> get messages => _messages;
  List<NotificationModel> get notifications => _notifications;
  List<JobPosting> get jobPostings => _jobPostings;
  List<Application> get applications => _applications;
  List<JobNotification> get jobNotifications => _jobNotifications;
}
