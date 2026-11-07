import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  final int id;
  final String slug;
  final String? googlePlayProductId;
  final String name;
  final String description;
  final int priceCents;
  final String currency;
  final String formattedPrice;
  final int durationDays;
  final List<String> features;
  final bool isFeatured;

  const SubscriptionPlan({
    required this.id,
    required this.slug,
    this.googlePlayProductId,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.currency,
    required this.formattedPrice,
    required this.durationDays,
    required this.features,
    this.isFeatured = false,
  });

  bool get isFree => priceCents == 0;

  @override
  List<Object?> get props => [
        id,
        slug,
        googlePlayProductId,
        name,
        description,
        priceCents,
        currency,
        formattedPrice,
        durationDays,
        features,
        isFeatured,
      ];
}
