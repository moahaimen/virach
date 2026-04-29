import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reservation_model.dart';

// This line is required so Retrofit can generate the 'api_client.g.dart' code
part 'api_client.g.dart';

/// The Retrofit client for talking to your "reservations" API on PythonAnywhere.
@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  /// The factory constructor that returns the generated Retrofit implementation.
  ///
  /// Example usage:
  /// ```dart
  ///   final dio = Dio();
  ///   dio.options.headers["Authorization"] = "JWT $token"; // or "Bearer $token"
  ///   final apiClient = ApiClient(dio);
  ///   // Now call the methods below, e.g. apiClient.updateReservation(...)
  /// ```
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // --------------------------
  // CREATE
  // --------------------------
  /// Create a new reservation.
  /// POST /reservations/
  @POST("/reservations/")
  Future<ReservationModel> createReservation(
    @Body() Map<String, dynamic> reservation,
  );

  // --------------------------
  // FETCH by Doctor ID
  // --------------------------
  /// GET /reservations/?service_provider_id=...
  @GET("/reservations/")
  Future<List<ReservationModel>> fetchReservations(
    @Query('service_provider_id') String doctorId,
  );

  // --------------------------
  // FETCH by Patient ID
  // --------------------------
  /// GET /reservations/?patient_id=...
  @GET("/reservations/")
  Future<List<ReservationModel>> fetchPatientsReservations(
    @Query('patient_id') String patientId,
  );

  // --------------------------
  // FETCH specific Reservation by ID
  // --------------------------
  /// GET /reservations/{id}/
  @GET("/reservations/{id}/")
  Future<ReservationModel> fetchReservationById(
    @Path("id") String reservationId,
  );

  // --------------------------
  // FETCH by Patient+Doctor
  // --------------------------
  /// GET /reservations/?patient_id=...&service_provider_id=...
  @GET("/reservations/")
  Future<List<ReservationModel>> fetchReservationsForPatientAndDoctor(
    @Query('patient_id') String patientId,
    @Query('service_provider_id') String doctorId,
  );

  // --------------------------
  // UPDATE (PATCH) a reservation
  // --------------------------
  /// PATCH /reservations/{id}/
  /// Example usage:
  /// ```dart
  /// final data = {
  ///   "status": "CONFIRMED",
  ///   "appointment_date": "2025-03-19",
  ///   "appointment_time": "21:52:00",
  /// };
  /// final updated = await apiClient.updateReservation("some-res-id", data);
  /// ```
  @PATCH("/reservations/{id}/")
  Future<ReservationModel> updateReservation(
    @Path("id") String id,
    @Body() Map<String, dynamic> data,
  );

  // --------------------------
  // FETCH All Reservations
  // --------------------------
  /// GET /reservations/
  @GET("/reservations/")
  Future<List<ReservationModel>> fetchAllReservations();
}
