import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/jobseeker_model.dart';

class JobSeekerProfilePage extends StatefulWidget {
  final JobSeekerModel jobSeeker;

  const JobSeekerProfilePage({Key? key, required this.jobSeeker})
      : super(key: key);

  @override
  _JobSeekerProfilePageState createState() => _JobSeekerProfilePageState();
}

class _JobSeekerProfilePageState extends State<JobSeekerProfilePage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          widget.jobSeeker.user?.fullName ??
              'Profile', // ✅ This correctly gets the name
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image Section
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: widget.jobSeeker.degreeImage != null
                            ? NetworkImage(widget.jobSeeker.degreeImage!)
                            : const AssetImage(
                                    'assets/icons/jobseeker_icon.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.jobSeeker.user?.fullName ?? 'No Name Provided',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.jobSeeker.specialty ?? 'No Specialty Provided',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Profile Details Section
                _buildProfileDetail('Specialty:', widget.jobSeeker.specialty),
                _buildProfileDetail('Degree:', widget.jobSeeker.degree),
                _buildProfileDetail('Address:', widget.jobSeeker.address),
                _buildProfileDetail(
                  'Created Date:',
                  widget.jobSeeker.createDate,
                ),
                const SizedBox(height: 24),

                // Contact Information
                Text(
                  'Contact Information',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  icon: Icons.phone,
                  label: 'Phone Number',
                  value: widget.jobSeeker.updateDate ?? 'No Phone Number',
                  onTap: () =>
                      _makePhoneCall(widget.jobSeeker.updateDate ?? ''),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.chat,
                  label: 'Start Chat',
                  value: 'Tap to chat',
                  onTap: _startChat,
                ),
                const SizedBox(height: 24),

                // Action Button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    Future.delayed(const Duration(seconds: 2), () {
                      setState(() {
                        isLoading = false;
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Send Job Request',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Loading Indicator
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      subtitle: Text(value),
      onTap: onTap,
    );
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print("Could not make phone call to $phoneNumber");
      }
    }
  }

  void _startChat() {
    // Implement chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat functionality not implemented yet')),
    );
  }
}
