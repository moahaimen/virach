import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../models/jobs_models/job_posting_model.dart';

class JobPostingService {
  final String apiUrl = 'https://example.com/api/job_postings';

  Future<List<JobPosting>> fetchJobPostings() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => JobPosting.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load job postings');
    }
  }
}
