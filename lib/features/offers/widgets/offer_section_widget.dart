import 'package:flutter/material.dart';
import 'package:racheeta/models/offer_model.dart';
import 'package:racheeta/widgets/offers/offerlistitem.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import 'offeritem_widget.dart';
import '../screens/offer_details_screen.dart';

class OfferSection extends StatelessWidget {
  const OfferSection({
    super.key,
    required this.title,
    required this.offers,
    this.scrollDirection = Axis.horizontal,
    int maxToShow = 5,
  }) : _maxToShow = maxToShow;

  final String title;
  final List<Offer> offers;
  final Axis scrollDirection;
  final int _maxToShow;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    final isH = scrollDirection == Axis.horizontal;
    final visible = offers.take(_maxToShow).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          RacheetaSectionHeader(
            title: title,
            onSeeAll: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AllOffersScreen(title: title, offers: offers),
              ),
            ),
          ),
        if (isH)
          SizedBox(
            height: 275,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: visible.length,
              itemBuilder: (ctx, i) => OfferItem(offer: visible[i]),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visible.length,
            itemBuilder: (ctx, i) => OfferListItem(offer: visible[i]),
          ),
      ],
    );
  }
}

class AllOffersScreen extends StatelessWidget {
  const AllOffersScreen({super.key, required this.title, required this.offers});

  final String title;
  final List<Offer> offers;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: offers.length,
          itemBuilder: (_, i) => OfferListItem(offer: offers[i]),
        ),
      );
}
