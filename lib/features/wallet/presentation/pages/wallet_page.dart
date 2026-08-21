import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _wallet;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _withdrawals = [];
  List<Map<String, dynamic>> _heldPayments = [];
  bool _isWithdrawing = false;
  bool _isReleasing = false;
  bool _hasError = false;
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final api = sl<ApiService>();
      final walletRes = await api.getWallet();
      final data = walletRes.data['data'] as Map<String, dynamic>? ?? {};
      var withdrawals = <Map<String, dynamic>>[];
      var heldPayments = <Map<String, dynamic>>[];
      try {
        final wRes = await api.getMyWithdrawals();
        withdrawals = (wRes.data['data'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {}
      try {
        final pRes = await api.getMyPayments(status: 'held');
        heldPayments = (pRes.data['data'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {}
      if (!mounted) return;
      try {
        _myUserId = await api.getCurrentUserId();
      } catch (_) {
        _myUserId = null;
      }
      if (!mounted) return;
      setState(() {
        _wallet = data['wallet'] as Map<String, dynamic>? ?? {};
        _transactions = (data['transactions'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _withdrawals = withdrawals;
        _heldPayments = heldPayments;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _showWithdrawDialog() async {
    final amountController = TextEditingController();
    final bankController = TextEditingController();
    final holderController = TextEditingController();
    var method = 'bank_transfer';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.tr('wallet.withdraw_title')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: context.tr('wallet.amount_label'),
                    labelStyle: TextStyle(color: context.colors.textSecondary),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.tr('wallet.method'),
                    labelStyle: TextStyle(color: context.colors.textSecondary),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'bank_transfer',
                      child: Text(context.tr('wallet.bank_transfer')),
                    ),
                    DropdownMenuItem(
                      value: 'cash',
                      child: Text(context.tr('wallet.cash')),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text(context.tr('wallet.other')),
                    ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => method = v ?? 'bank_transfer'),
                ),
                if (method == 'bank_transfer') ...[
                  SizedBox(height: 12.h),
                  TextField(
                    controller: bankController,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      labelText: context.tr('wallet.bank_name'),
                      labelStyle: TextStyle(
                        color: context.colors.textSecondary,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: holderController,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      labelText: context.tr('wallet.account_holder'),
                      labelStyle: TextStyle(
                        color: context.colors.textSecondary,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.tr('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.tr('wallet.request_withdraw')),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('wallet.invalid_amount'),
      );
      return;
    }
    setState(() => _isWithdrawing = true);
    try {
      await sl<ApiService>().requestWithdrawal(
        amount: amount,
        method: method,
        accountDetails: method == 'bank_transfer'
            ? {
                'bankName': bankController.text.trim(),
                'holderName': holderController.text.trim(),
              }
            : null,
      );
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('wallet.withdraw_requested'),
        isError: false,
      );
      _load();
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('wallet.withdraw_failed'),
      );
    } finally {
      if (mounted) setState(() => _isWithdrawing = false);
    }
  }

  Future<void> _cancelWithdrawal(String id) async {
    try {
      await sl<ApiService>().cancelWithdrawal(id);
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('wallet.withdraw_cancelled'),
        isError: false,
      );
      _load();
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('wallet.cancel_failed'),
      );
    }
  }

  Future<void> _releasePayment(String paymentId) async {
    if (_isReleasing) return;
    setState(() => _isReleasing = true);
    try {
      await sl<ApiService>().releasePayment(paymentId);
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('wallet.released'),
        isError: false,
      );
      _load();
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('wallet.release_failed'),
      );
    } finally {
      if (mounted) setState(() => _isReleasing = false);
    }
  }

  Widget _buildEscrowRow(Map<String, dynamic> p) {
    final amount = (p['amount'] as num?) ?? 0;
    final method = p['method']?.toString() ?? '';
    final project = p['project'] is Map ? p['project'] as Map : null;
    final projectTitle = project?['title']?.toString() ?? context.tr('wallet.project');
    final isPayer =
        p['payer'] is Map && (p['payer']['_id']?.toString() == _myUserId);
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.orange.withValues(alpha: 0.15),
            child: Icon(
              Icons.lock_clock_outlined,
              size: 18.sp,
              color: Colors.orange.shade800,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  method.isEmpty ? context.tr('wallet.in_escrow') : method,
                  style: TextStyle(
                    color: context.colors.textHint,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.orange.shade800,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isPayer) ...[
            SizedBox(width: 8.w),
            IconButton(
              onPressed: _isReleasing
                  ? null
                  : () => _releasePayment(p['_id'] as String? ?? ''),
              icon: _isReleasing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.lock_open_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.sp,
                    ),
              tooltip: context.tr('wallet.release'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.tr('wallet.title'),
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _hasError
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('error'),
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                SizedBox(height: 12.h),
                FilledButton(
                  onPressed: _load,
                  child: Text(context.tr('retry')),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              children: [
                _buildBalanceCard(),
                SizedBox(height: 16.h),
                _buildWithdrawButton(),
                SizedBox(height: 24.h),
                _buildSectionTitle(context.tr('wallet.escrow')),
                if (_heldPayments.isEmpty)
                  _buildEmptyRow(context.tr('wallet.no_escrow'))
                else
                  ..._heldPayments.map(_buildEscrowRow),
                SizedBox(height: 16.h),
                _buildSectionTitle(context.tr('wallet.recent_transactions')),
                if (_transactions.isEmpty)
                  _buildEmptyRow(context.tr('wallet.no_transactions'))
                else
                  ..._transactions.take(10).map(_buildTransactionRow),
                if (_withdrawals.isNotEmpty) ...[
                  SizedBox(height: 24.h),
                  _buildSectionTitle(context.tr('wallet.withdrawals')),
                  ..._withdrawals.map(_buildWithdrawalRow),
                ],
              ],
            ),
          ),
  );

  Widget _buildBalanceCard() {
    final balance = (_wallet?['balance'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final holding = (_wallet?['holding'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final earned =
        (_wallet?['totalEarned'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final withdrawn =
        (_wallet?['totalWithdrawn'] as num?)?.toStringAsFixed(2) ?? '0.00';
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.vibrantPurple],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('wallet.available_balance'),
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            '\$$balance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildMiniStat(
                  context.tr('wallet.in_escrow'),
                  '\$$holding',
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  context.tr('wallet.total_earned'),
                  '\$$earned',
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  context.tr('wallet.withdrawn'),
                  '\$$withdrawn',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 4.h),
      Text(
        label,
        style: TextStyle(color: Colors.white70, fontSize: 11.sp),
      ),
    ],
  );

  Widget _buildWithdrawButton() => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: _isWithdrawing ? null : _showWithdrawDialog,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 14.h),
      ),
      icon: _isWithdrawing
          ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : const Icon(Icons.currency_exchange),
      label: Text(
        context.tr('wallet.withdraw_btn'),
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
      ),
    ),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: Text(
      title,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildEmptyRow(String text) => Padding(
    padding: EdgeInsets.all(16.w),
    child: Text(
      text,
      style: TextStyle(color: context.colors.textSecondary, fontSize: 14.sp),
    ),
  );

  Widget _buildTransactionRow(Map<String, dynamic> tx) {
    final type = tx['type']?.toString() ?? 'manual';
    final amount = (tx['amount'] as num?) ?? 0;
    final isCredit = amount >= 0;
    final description = tx['description']?.toString() ?? type;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor:
                (isCredit ? AppColors.successGreen : AppColors.logoutRed)
                    .withValues(alpha: 0.12),
            child: Icon(
              isCredit ? Icons.south_west : Icons.north_east,
              size: 16.sp,
              color: isCredit ? AppColors.successGreen : AppColors.logoutRed,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatDate(tx['createdAt']?.toString()),
                  style: TextStyle(
                    color: context.colors.textHint,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: isCredit ? AppColors.successGreen : AppColors.logoutRed,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalRow(Map<String, dynamic> w) {
    final status = w['status']?.toString() ?? 'pending';
    final amount = (w['amount'] as num?) ?? 0;
    final canCancel = status == 'pending';
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payments_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 22.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('wallet.withdrawal_row', {
                    'amount': amount.toStringAsFixed(2),
                  }),
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatDate(w['createdAt']?.toString()),
                  style: TextStyle(
                    color: context.colors.textHint,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _statusColor(status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: _statusColor(status),
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (canCancel) ...[
            SizedBox(width: 8.w),
            IconButton(
              onPressed: () => _cancelWithdrawal(w['_id'] as String? ?? ''),
              icon: Icon(Icons.close, color: AppColors.logoutRed, size: 18.sp),
              tooltip: context.tr('cancel'),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'processed':
        return AppColors.successGreen;
      case 'rejected':
        return AppColors.logoutRed;
      case 'cancelled':
        return context.colors.textSecondary;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final date = DateTime.parse(iso).toLocal();
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}
