import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class FeesPage extends StatefulWidget {
  const FeesPage({super.key});

  @override
  State<FeesPage> createState() => _FeesPageState();
}

class _FeesPageState extends State<FeesPage> {
  List<Map<String, dynamic>> installments = [];
  String nextPaymentDate = '...';
  bool isLoading = true;
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://edunova-backend-production.up.railway.app")); // Using Railway URL 
  final String studentEmail = "student@edunova.com"; // Mock email for now

  @override
  void initState() {
    super.initState();
    _fetchInstallments();
  }

  Future<void> _fetchInstallments() async {
    try {
      final response = await _dio.get("/fees/$studentEmail");
      if (response.statusCode == 200) {
        final List data = response.data;
        setState(() {
          installments = data.map((item) => {
            'id': item['id'],
            'title': item['title'],
            'amount': item['amount'],
            'status': item['status'],
            'date': item['due_date'],
          }).toList();
          
          _updateNextPaymentDate();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching fees: $e");
      setState(() => isLoading = false);
    }
  }

  void _updateNextPaymentDate() {
    if (installments.isEmpty) {
      nextPaymentDate = "None";
      return;
    }
    for (var installment in installments) {
      if (installment['status'] == 'due') {
        nextPaymentDate = installment['date'].split(',')[0];
        return;
      }
    }
    nextPaymentDate = "All Paid";
  }

  Future<void> _handlePayment(int installmentId, {File? proofFile}) async {
    setState(() => isLoading = true);
    try {
      FormData formData = FormData.fromMap({
        "student_email": studentEmail,
        "installment_id": installmentId,
      });

      if (proofFile != null) {
        formData.files.add(MapEntry(
          "proof",
          await MultipartFile.fromFile(proofFile.path, filename: "receipt.jpg"),
        ));
      }

      await _dio.post("/fees/pay", data: formData);
      await _fetchInstallments();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment processed successfully!")),
      );
    } catch (e) {
      print("Payment error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
      setState(() => isLoading = false);
    }
  }

  void _showPaymentOptions(BuildContext context, Map<String, dynamic> installment) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Pay ${installment['title']}",
              style: TextDesign.h2.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Amount: ${installment['amount']} IQD",
              style: TextDesign.body.copyWith(color: AppColors.mutedText, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            
            // FIB Option
            _buildPaymentOptionTile(
              context,
              icon: Icons.account_balance_wallet_rounded,
              title: "FIB (First Iraqi Bank)",
              subtitle: "Instant Digital Payment",
              color: const Color(0xFFFDB913),
              onTap: () => _showMethodDetails(context, 'FIB', installment),
            ),
            const SizedBox(height: 16),
            
            // Bank Option
            _buildPaymentOptionTile(
              context,
              icon: Icons.account_balance_rounded,
              title: "Bank Transfer",
              subtitle: "World University Erbil Official Account",
              color: const Color(0xFF1A237E),
              onTap: () => _showMethodDetails(context, 'Bank', installment),
            ),
            const SizedBox(height: 16),
            
            // Cash Option
            _buildPaymentOptionTile(
              context,
              icon: Icons.payments_rounded,
              title: "Cash Payment",
              subtitle: "Pay at the University Finance Office",
              color: Colors.green,
              onTap: () => _showMethodDetails(context, 'Cash', installment),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextDesign.h3.copyWith(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextDesign.body.copyWith(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _showMethodDetails(BuildContext context, String method, Map<String, dynamic> installment) {
    Navigator.pop(context); // Close selection modal
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$method - ${installment['title']}",
              style: TextDesign.h2.copyWith(
                fontSize: 20,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            
            if (method == 'FIB') ...[
              _buildInfoRow("FIB Number", "07518078669"),
              _buildInfoRow("Account Name", "Mr. Simko Kamil"),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handlePayment(installment['id']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDB913),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Pay Now (Simulated)", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ] else if (method == 'Bank') ...[
              _buildInfoRow("Bank Name", "World Bank Erbil"),
              _buildInfoRow("Account Number", "1964-0"),
              _buildInfoRow("Account Holder", "World University Erbil"),
              const SizedBox(height: 24),
              const Text(
                "Please upload the transfer receipt image below to verify your payment.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildUploadButton(context, installment['id']),
            ] else if (method == 'Cash') ...[
              const Text(
                "Visit the University Finance Office to pay in cash. Once paid, please upload the receipt image provided by the office.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              _buildUploadButton(context, installment['id']),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextDesign.h3.copyWith(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                onPressed: () {
                  // Simulate copy
                },
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, int installmentId) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // In a real app, we would use image_picker here
          // For now, we simulate the upload with the installment ID
          Navigator.pop(context);
          _handlePayment(installmentId);
        },
        icon: const Icon(Icons.cloud_upload_rounded),
        label: const Text("Upload Receipt Image"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          side: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final currency = l10n?.translate('currency') ?? 'IQD';

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
      body: isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Debt Hero
            _buildTotalDebtCard(context, currency),
            const SizedBox(height: 32),

            // Payment Method Info (Clickable)
            InkWell(
              onTap: () {
                // Find the first due installment to pay
                final dueInstallment = installments.firstWhere(
                  (i) => i['status'] == 'due',
                  orElse: () => {},
                );
                if (dueInstallment.isNotEmpty) {
                  _showPaymentOptions(context, dueInstallment);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All installments are already paid!")),
                  );
                }
              },
              borderRadius: BorderRadius.circular(24),
              child: _buildInfoSection(context),
            ),
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
                  nextPaymentDate == "All Paid" 
                      ? "All installments paid!" 
                      : "Next Payment: $nextPaymentDate",
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
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.mutedText),
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

