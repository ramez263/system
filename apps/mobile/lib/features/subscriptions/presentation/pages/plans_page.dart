import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../../domain/entities/subscription_plan.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final TextEditingController _promoCodeController = TextEditingController();

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  void _showPromoCodeDialog(BuildContext context, bool isArabic) {
    _promoCodeController.clear();
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(isArabic ? 'تفعيل قسيمة أو كود خصم' : 'Redeem Promo Voucher'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic
                    ? 'أدخل رمز القسيمة الترويجية لتفعيل عضوية VIP مجاناً.'
                    : 'Enter your promotional gift voucher code to unlock VIP features.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _promoCodeController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. RAMEZVIP',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final code = _promoCodeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(dialogCtx);
                  context.read<SubscriptionCubit>().redeemPromoCode(code);
                }
              },
              child: Text(isArabic ? 'تطبيق الكود' : 'Redeem Code'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasCubit = context.findAncestorWidgetOfExactType<BlocProvider<SubscriptionCubit>>() != null;

    if (!hasCubit) {
      return _buildStaticFallback(context, theme, isArabic);
    }

    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionLoaded) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        } else if (state is SubscriptionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: ModernAppBar(
            title: 'Subscription Plans',
            subtitle: 'Choose your premium tier',
            actions: [
              IconButton(
                icon: const Icon(Icons.confirmation_number_outlined),
                tooltip: 'Promo Code',
                onPressed: () => _showPromoCodeDialog(context, isArabic),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: isArabic ? 'تحديث' : 'Refresh',
                onPressed: () => context.read<SubscriptionCubit>().loadSubscriptionData(),
              ),
            ],
          ),
          body: _buildBody(context, theme, state, isArabic),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    SubscriptionState state,
    bool isArabic,
  ) {
    if (state is SubscriptionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SubscriptionError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(state.message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.read<SubscriptionCubit>().loadSubscriptionData(),
                icon: const Icon(Icons.refresh),
                label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is SubscriptionLoaded) {
      return RefreshIndicator(
        onRefresh: () => context.read<SubscriptionCubit>().loadSubscriptionData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Current Entitlement Status Card
            _buildStatusHeader(context, theme, state, isArabic),
            const SizedBox(height: 20),

            // 2. Section Title
            Text(
              isArabic ? 'اختر الباقة المناسبة لاحتياجاتك' : 'Choose Your Subscription Tier',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              isArabic
                  ? 'سرعات فائقة 1Gbps، خوادم VIP حصرية، وبدون قيود'
                  : 'All plans include zero-log encryption, VIP servers & unlimited speed.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 3. Dynamic Plan Cards from Database
            ...state.plans.map((plan) {
              final isSelected = state.selectedPlan?.id == plan.id;
              final isCurrent = state.isPremium && (state.status?.activePlanName == plan.name);

              return _buildPlanCard(
                context: context,
                theme: theme,
                plan: plan,
                isSelected: isSelected,
                isCurrent: isCurrent,
                isArabic: isArabic,
                onSelect: () => context.read<SubscriptionCubit>().selectPlan(plan),
              );
            }),

            const SizedBox(height: 16),

            // 4. Primary Purchase CTA Button
            if (state.selectedPlan != null && !state.selectedPlan!.isFree) ...[
              RamezButton(
                label: state.isPurchasing
                    ? (isArabic ? 'جاري المعالجة والتحقق...' : 'Processing Purchase...')
                    : (isArabic
                        ? 'الاشتراك الآن (${state.selectedPlan!.formattedPrice})'
                        : 'Subscribe Now (${state.selectedPlan!.formattedPrice})'),
                isLoading: state.isPurchasing,
                onPressed: state.isPurchasing
                    ? null
                    : () {
                        context.read<SubscriptionCubit>().purchasePlan(state.selectedPlan!);
                      },
              ),
              const SizedBox(height: 12),
            ],

            // 5. Promo Code Voucher Action
            OutlinedButton.icon(
              onPressed: () => _showPromoCodeDialog(context, isArabic),
              icon: const Icon(Icons.card_giftcard),
              label: Text(
                isArabic ? 'هل لديك رمز قسيمة أو كود دعوة؟' : 'Have a Promo or Voucher Code?',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStatusHeader(
    BuildContext context,
    ThemeData theme,
    SubscriptionLoaded state,
    bool isArabic,
  ) {
    final isPremium = state.isPremium;
    final status = state.status;

    return RamezGlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPremium ? Colors.amber.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPremium ? Icons.workspace_premium : Icons.vpn_lock_outlined,
              color: isPremium ? Colors.amber.shade700 : Colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isPremium
                          ? (isArabic ? 'عضوية VIP بريميوم' : 'VIP Pro Member')
                          : (isArabic ? 'الباقة المجانية' : 'Free Tier'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPremium ? Colors.amber.shade800 : Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPremium ? 'PRO' : 'FREE',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isPremium
                      ? (status?.expiresAt != null
                          ? (isArabic
                              ? 'صالح حتى: ${status!.expiresAt!.toLocal().toString().split(' ')[0]}'
                              : 'Valid until: ${status!.expiresAt!.toLocal().toString().split(' ')[0]}')
                          : (isArabic ? 'ترقية غير محدودة' : 'Unlimited Pro Access'))
                      : (isArabic
                          ? 'حد يومي: 2 جيجابايت • سرعة قياسية'
                          : 'Daily cap: 2 GB • Standard speed'),
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required ThemeData theme,
    required SubscriptionPlan plan,
    required bool isSelected,
    required bool isCurrent,
    required bool isArabic,
    required VoidCallback onSelect,
  }) {
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : (plan.isFeatured ? Colors.amber.shade600 : theme.dividerColor.withValues(alpha: 0.2));

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected || plan.isFeatured ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
              : theme.colorScheme.surface,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? theme.colorScheme.primary : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      plan.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                if (plan.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  )
                else if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isArabic ? 'الخطة الحالية' : 'Active',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  plan.formattedPrice,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: plan.isFree ? Colors.grey : theme.colorScheme.primary,
                  ),
                ),
                if (!plan.isFree) ...[
                  const SizedBox(width: 4),
                  Text(
                    plan.durationDays >= 365
                        ? (isArabic ? '/ سنة' : '/ year')
                        : (isArabic ? '/ شهر' : '/ month'),
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ],
            ),
            if (plan.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                plan.description,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
              ),
            ],
            const Divider(height: 20),
            ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticFallback(BuildContext context, ThemeData theme, bool isArabic) {
    return Scaffold(
      appBar: const ModernAppBar(title: 'Subscription Plans', subtitle: 'Choose your premium tier'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RamezGlassCard(
            child: Text(isArabic ? 'الباقة المجانية الافتراضية' : 'Free Guest Tier'),
          ),
          const SizedBox(height: 16),
          RamezButton(
            label: isArabic ? 'ترقية الآن' : 'Upgrade Now',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
