import 'package:flutter/material.dart';
import '../../../../core/widgets/ramez_empty_state.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  final List<Map<String, dynamic>> _mockPayments = const [
    {
      'id': 'GPA.3391-4402-9912',
      'date': '2026-10-06',
      'plan': 'Premium VIP Monthly',
      'amount': '\$4.99',
      'provider': 'Google Play Billing',
      'status': 'Paid',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'سجل المدفوعات والاشتراك' : 'Payment History'),
      ),
      body: _mockPayments.isEmpty
          ? RamezEmptyState(
              icon: Icons.receipt_long_outlined,
              title: isArabic ? 'لا توجد فواتير سابقة' : 'No Payment Records',
              description: isArabic
                  ? 'لم يتم تسجيل أي عمليات شراء لحسابك بعد.'
                  : 'You have not made any subscription purchases yet.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mockPayments.length,
              itemBuilder: (context, index) {
                final payment = _mockPayments[index];
                return RamezGlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            payment['plan'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            payment['amount'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${payment['date']} • ${payment['provider']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${payment['id']}',
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
