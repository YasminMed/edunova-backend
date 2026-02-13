import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class FeesPage extends StatelessWidget {
  const FeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final currency = l10n?.translate('currency') ?? 'IQD';

    final List<Map<String, dynamic>> installments = [
      {
        'title': l10n?.translate('first_fee') ?? '1st Installment',
        'amount': '750,000',
        'status': 'paid',
        'date': 'Sep 15, 2025',
      },
      {
        'title': l10n?.translate('second_fee') ?? '2nd Installment',
        'amount': '750,000',
        'status': 'paid',
        'date': 'Nov 01, 2025',
      },
      {
        'title': l10n?.translate('third_fee') ?? '3rd Installment',
        'amount': '750,000',
        'status': 'due',
        'date': 'Jan 15, 2026',
      },
      {
        'title': l10n?.translate('fourth_fee') ?? '4th Installment',
        'amount': '750,000',
        'status': 'due',
        'date': 'Mar 15, 2026',
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.translate('fees_page') ?? 'Academic Fees',
          style: TextDesign.h2.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Debt Hero
            _buildTotalDebtCard(context, currency),
            const SizedBox(height: 32),

            // Payment Method Info
            _buildInfoSection(context),
            const SizedBox(height: 32),

            // Timeline Header
            Text(
              l10n?.translate('installment_timeline') ?? 'Payment Timeline',
              style: TextDesign.h3.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Vertical Timeline
            ...List.generate(installments.length, (index) {
              return _buildTimelineItem(
                context,
                installments[index],
                index == installments.length - 1,
                currency,
              );
            }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalDebtCard(BuildContext context, String currency) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BFA5), Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BFA5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.translate('total_debt') ?? 'Total Debt',
            style: TextDesign.body.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "3,000,000",
                style: TextDesign.h1.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currency,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "Next Payment: Jan 15",
                  style: TextDesign.body.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.translate('payment_method') ?? 'How to Pay',
                  style: TextDesign.h3.copyWith(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Pay via University Bank or Online Portal",
                  style: TextDesign.body.copyWith(
                    color: AppColors.mutedText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    Map<String, dynamic> item,
    bool isLast,
    String currency,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPaid = item['status'] == 'paid';
    final l10n = AppLocalizations.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPaid
                        ? Colors.green
                        : AppColors.mutedText.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: isPaid
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isPaid
                        ? Colors.green.withOpacity(0.5)
                        : AppColors.mutedText.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isPaid
                        ? Colors.green.withOpacity(0.1)
                        : Theme.of(context).dividerColor.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: TextDesign.h3.copyWith(
                              fontSize: 15,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['date'],
                            style: TextDesign.body.copyWith(
                              color: AppColors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${item['amount']} $currency",
                          style: TextDesign.h3.copyWith(
                            fontSize: 14,
                            color: isPaid
                                ? Colors.green
                                : (isDark ? Colors.white : AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n?.translate(item['status']) ??
                              item['status'].toUpperCase(),
                          style: TextStyle(
                            color: isPaid ? Colors.green : AppColors.mutedText,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
