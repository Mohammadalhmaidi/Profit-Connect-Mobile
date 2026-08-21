import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  bool _isLoading = true;
  String _direction = 'all';
  List<Map<String, dynamic>> _payments = [];
  final Set<String> _releasing = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await sl<ApiService>().getMyPayments(
        direction: _direction == 'all' ? null : _direction,
      );
      if (!mounted) return;
      setState(() {
        _payments = (res.data['data'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _release(String paymentId) async {
    setState(() => _releasing.add(paymentId));
    try {
      await sl<ApiService>().releasePayment(paymentId);
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('payments.released'),
        isError: false,
      );
      _load();
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('payments.release_failed'),
      );
    } finally {
      if (mounted) setState(() => _releasing.remove(paymentId));
    }
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
        context.tr('payments.title'),
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: Column(
      children: [
        Container(
          color: context.colors.surface,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterChip(context.tr('common.all'), 'all'),
              SizedBox(width: 8.w),
              _buildFilterChip(context.tr('payments.received'), 'received'),
              SizedBox(width: 8.w),
              _buildFilterChip(context.tr('payments.sent'), 'sent'),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80.sp,
                        color: context.colors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        context.tr('payments.none'),
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    itemCount: _payments.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) =>
                        _buildPaymentRow(_payments[index]),
                  ),
                ),
        ),
      ],
    ),
  );

  Widget _buildFilterChip(String label, String value) => GestureDetector(
    onTap: () {
      setState(() => _direction = value);
      _load();
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _direction == value
            ? Theme.of(context).colorScheme.primary
            : context.colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _direction == value
              ? Theme.of(context).colorScheme.primary
              : context.colors.inputBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _direction == value
              ? Colors.white
              : context.colors.textPrimary,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  Widget _buildPaymentRow(Map<String, dynamic> p) {
    final status = p['status']?.toString() ?? 'held';
    final amount = (p['amount'] as num?) ?? 0;
    final project = p['project'] as Map<String, dynamic>?;
    final projectTitle =
        project?['title']?.toString() ?? context.tr('payments.project_payment');
    final id = p['_id']?.toString() ?? '';
    final payer = p['payer'] is Map
        ? Map<String, dynamic>.from(p['payer'] as Map)
        : <String, dynamic>{};
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthSuccess ? authState.user.id : null;
    final isPayer = userId != null && payer['_id']?.toString() == userId;
    final isReleasing = _releasing.contains(id);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.payments_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20.sp,
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
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.accentCyan,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
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
                  ],
                ),
              ],
            ),
          ),
          if (status == 'held' && isPayer)
            TextButton(
              onPressed: isReleasing ? null : () => _release(id),
              child: isReleasing
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.tr('payments.release')),
            ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'released':
        return AppColors.successGreen;
      case 'refunded':
        return AppColors.logoutRed;
      default:
        return Colors.orange;
    }
  }
}
