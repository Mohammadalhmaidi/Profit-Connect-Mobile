import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../theme/app_colors.dart';

class CurrentUserAvatar extends StatelessWidget {
  final double radius;
  final IconData fallbackIcon;

  const CurrentUserAvatar({
    super.key,
    this.radius = 20,
    this.fallbackIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, UserEntity?>(
      (bloc) => bloc.state is AuthSuccess ? (bloc.state as AuthSuccess).user : null,
    );
    final avatarUrl = user?.avatar;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.chipUnselected,
      child: Icon(
        fallbackIcon,
        color: AppColors.primaryDark,
        size: radius,
      ),
    );
  }
}
