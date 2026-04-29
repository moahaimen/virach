import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../../constansts/constants.dart';
import '../../../models/offer_model.dart';
import '../models/coupon_model.dart';

class CouponSheet extends StatefulWidget {
  final Offer offer;
  final Coupon coupon;
  const CouponSheet({Key? key, required this.offer, required this.coupon})
      : super(key: key);

  @override
  State<CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends State<CouponSheet> {
  final _shot = ScreenshotController();
  bool _saving = false;
// --------------------------------------------------
// Everything we want in the QR
// --------------------------------------------------
  String _qrPayload() {
    return '''
كوبون راجيتة ✅
العميل : ${widget.coupon.userName}
الكود  : ${widget.coupon.code}
العرض  : ${widget.offer.name}
النوع  : ${widget.offer.offerType ?? '—'}
الخصم  : ${widget.coupon.discount}
رقم العرض: ${widget.coupon.offerId}
'''
        .trim();
  }

  Future<void> _saveAndShare() async {
    setState(() => _saving = true);

    final Uint8List? png = await _shot.capture(pixelRatio: 2.5);
    if (png != null) {
      // write to temporary file
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.coupon.code}.png');
      await file.writeAsBytes(png);

      // open native share sheet (user can save to gallery, WhatsApp, …)
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'كوبون خصم من تطبيق راجيته',
      );
    }

    if (context.mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => Screenshot(
        controller: _shot,
        child: Padding(
          padding: kSectionPadding,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kCardRadius),
            child: Padding(
              padding: kCardPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /* logo + greeting */
                  Row(
                    children: [
                      Image.asset('assets/images/logo2.png',
                          width: 40, height: 40),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'مرحباً ${widget.coupon.userName} 👋',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /* offer title */
                  Text(widget.offer.name,
                      style: kOfferNameTextStyle, textAlign: TextAlign.center),
                  const SizedBox(height: 12),

                  /* discount */
                  Text('خصم ${widget.coupon.discount}',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const SizedBox(height: 8),

                  /* code */
                  SelectableText(widget.coupon.code,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 8),

                  /* QR */
                  QrImageView(
                    data: _qrPayload(),
                    size: MediaQuery.of(context).size.width * 0.35,
                  ),
                  const SizedBox(height: 16),

                  /* buttons */
                  _saving
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: kBlueButtonStyle,
                          onPressed: _saveAndShare,
                          child: const Text('مشاركة / حفظ',
                              style: kButtonTextStyle),
                        ),
                ],
              ),
            ),
          ),
        ),
      );
}
