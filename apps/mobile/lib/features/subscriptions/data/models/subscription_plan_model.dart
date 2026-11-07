import '../../domain/entities/subscription_plan.dart';

class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.slug,
    super.googlePlayProductId,
    required super.name,
    required super.description,
    required super.priceCents,
    required super.currency,
    required super.formattedPrice,
    required super.durationDays,
    required super.features,
    super.isFeatured = false,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String? ?? '',
      googlePlayProductId: json['google_play_product_id'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priceCents: (json['price_cents'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      formattedPrice: json['formatted_price'] as String? ?? '',
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 30,
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isFeatured: json['is_featured'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'google_play_product_id': googlePlayProductId,
      'name': name,
      'description': description,
      'price_cents': priceCents,
      'currency': currency,
      'formatted_price': formattedPrice,
      'duration_days': durationDays,
      'features': features,
      'is_featured': isFeatured,
    };
  }
}
