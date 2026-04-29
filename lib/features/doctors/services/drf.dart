import 'package:flutter/material.dart';
import '../../reviews/models/review_model.dart';

class checking_reviews extends StatefulWidget {
  final String doctorId;

  checking_reviews({required this.doctorId});

  @override
  _checking_reviewsState createState() => _checking_reviewsState();
}

class _checking_reviewsState extends State<checking_reviews> {
  List<ReviewModel> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // fetchReviews();
  }

  // Future<void> fetchReviews() async {
  //   final provider =
  //       Provider.of<DoctorRetroDisplayGetProvider>(context, listen: false);
  //   final result = await provider.fetchDoctorReviews(widget.doctorId);
  //   setState(() {
  //     reviews = result;
  //     isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Doctor Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ListTile(
                  title: Text("Rating: ${review.rating}/5"),
                  subtitle: Text(review.reviewText ?? "No review text"),
                  // trailing: Text(review.createdAt ?? ""),
                );
              },
            ),
    );
  }
}
