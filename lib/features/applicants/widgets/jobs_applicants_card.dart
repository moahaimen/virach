import 'package:flutter/material.dart';
import '../../jobposting/models/jobposting_model.dart';
import '../models/applicants_model.dart';

class ApplicantCard extends StatefulWidget {
  final ApplicantsModel applicant;
  final JobPostingModel job;

  /// If you pass these the card shows the three action buttons.
  /// If you leave them `null`, the buttons are hidden automatically.
  final Future<bool> Function(String newStatus)? onRemotePatch; // accept / reject
  final Future<bool> Function()?               onDelete;

  /// Set to `false` explicitly if you still want to hide the buttons even
  /// when callbacks are provided.
  final bool showActions;

  const ApplicantCard({
    Key? key,
    required this.applicant,
    required this.job,
    this.onRemotePatch,
    this.onDelete,
    this.showActions = true,
  }) : super(key: key);

  @override
  State<ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<ApplicantCard> {
  late String _status;    // local copy of status
  bool _busy = false;     // simple loading flag

  @override
  void initState() {
    super.initState();
    _status = widget.applicant.applicationStatus ?? 'submitted';
  }

  /*───────────────────────────────────────────────────────────*/
  Future<void> _patch(String newStatus) async {
    if (_busy || widget.onRemotePatch == null) return;

    setState(() {
      _status = newStatus; // optimistic
      _busy   = true;
    });

    final ok = await widget.onRemotePatch!.call(newStatus);

    if (!ok && mounted) {
      // rollback
      setState(() => _status = 'submitted');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تغيير الحالة')),
      );
    }

    if (mounted) setState(() => _busy = false);
  }

  /*───────────────────────────────────────────────────────────*/
  Color get _statusColor => switch (_status) {
    'accepted' => Colors.green,
    'rejected' => Colors.red,
    _          => Colors.grey,
  };

  String get _statusLabel => switch (_status) {
    'accepted' => 'مقبول',
    'rejected' => 'مرفوض',
    _          => 'submitted',
  };

  /*───────────────────────────────────────────────────────────*/
  @override
  Widget build(BuildContext context) {
    final user = widget.applicant.jobSeekerUser;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /*──────── header row (avatar + info) ────────*/
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user?.profileImage != null
                      ? NetworkImage(user!.profileImage!)
                      : const AssetImage('assets/images/default_avatar.png')
                  as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'بدون اسم',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (user?.email != null)       Text('📧 ${user!.email}'),
                      if (user?.phoneNumber != null) Text('📱 ${user!.phoneNumber}'),
                      if (user?.gender != null)      Text('⚧️ ${user!.gender}'),
                      const SizedBox(height: 6),
                      if (widget.applicant.resume?.isNotEmpty ?? false)
                        Text('📄 السيرة الذاتية: ${widget.applicant.resume}'),
                      if (widget.applicant.coverLetter?.isNotEmpty ?? false)
                        Text('📝 رسالة التقديم: ${widget.applicant.coverLetter}'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('الحالة: '),
                          Text(
                            _statusLabel,
                            style: TextStyle(
                              color: _statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /*──────── buttons row ────────*/
            if (widget.showActions && widget.onRemotePatch != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // قبول
                  ElevatedButton.icon(
                    onPressed: _busy ? null : () => _patch('accepted'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('قبول', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  // رفض
                  ElevatedButton.icon(
                    onPressed: _busy ? null : () => _patch('rejected'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text('رفض', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  // حذف  (optional)
                  if (widget.onDelete != null)
                    ElevatedButton.icon(
                      onPressed: _busy
                          ? null
                          : () async {
                        final ok = await widget.onDelete!.call();
                        if (!ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('فشل الحذف')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text('حذف',
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
