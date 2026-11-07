import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/ramez_empty_state.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasCubit = context.findAncestorWidgetOfExactType<BlocProvider<SubscriptionCubit>>() != null;

    if (!hasCubit) {
      return _buildStaticFallback(context, isArabic);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'سجل المدفوعات والاشتراك' : 'Payment History'),
      ),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SubscriptionLoaded) {
            final history = state.paymentHistory;

            if (history.isEmpty) {
              return RamezEmptyState(
                icon: Icons.receipt_long_outlined,
                title: isArabic ? 'لا توجد فواتير سابقة' : 'No Payment Records',
                description: isArabic
                    ? 'لم يتم تسجيل أي عمليات شراء أو تفعيل اشتراكات لحسابك بعد.'
                    : 'You have not made any subscription purchases yet.',
                actionLabel: isArabic ? 'استعراض الباقات' : 'Browse Plans',
                onAction: () => Navigator.pop(context),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<SubscriptionCubit>().loadSubscriptionData(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final record = history[index];
                  final isSuccess = record.status.toLowerCase() == 'active' ||
                      record.status.toLowerCase() == 'completed' ||
                      record.status.toLowerCase() == 'paid';

                  return RamezGlassCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              record.planName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              record.formattedAmount,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: record.amountCents > 0 ? Colors.green : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${record.date} • ${record.store}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSuccess
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                record.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSuccess ? Colors.green.shade700 : Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Order ID: ${record.orderId}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStaticFallback(BuildContext context, bool isArabic) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'سجل المدفوعات والاشتراك' : 'Payment History'),
      ),
      body: RamezEmptyState(
        icon: Icons.receipt_long_outlined,
        title: isArabic ? 'لا توجد فواتير سابقة' : 'No Payment Records',
        description: isArabic
            ? 'لم يتم تسجيل أي عمليات شراء لحسابك بعد.'
            : 'You have not made any subscription purchases yet.',
        actionLabel: isArabic ? 'تحديث' : 'Refresh',
        onAction: () {},
      ),
    );
  }
}
