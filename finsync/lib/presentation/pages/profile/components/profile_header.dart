import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/profile/components/profile_stat_card.dart';

class ProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final String userName;
  final String balance;
  final String expensesCount;
  final String desiresCount;
  final String savedAmount;
  final VoidCallback? onEditAvatar;

  const ProfileHeader({
    super.key,
    this.avatarUrl,
    required this.name,
    required this.userName,
    this.balance = '',
    this.expensesCount = '0',
    this.desiresCount = '0',
    this.savedAmount = '0',
    this.onEditAvatar,
  });

  bool get _hasRemoteAvatar =>
      avatarUrl != null &&
      (avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        children: [
          GestureDetector(
            onTap: onEditAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: _hasRemoteAvatar
                        ? Image.network(
                            avatarUrl!,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildInitials(),
                          )
                        : _buildInitials(),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(7),

                    decoration: BoxDecoration(
                      color: AppColors.secondary,

                      shape: BoxShape.circle,

                      border: Border.all(color: Colors.white, width: 2),
                    ),

                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text(
            name,
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ),

          const SizedBox(height: 6),

          Text(
            userName,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),

          const SizedBox(height: 22),

          if (balance.isNotEmpty)
            Column(
              children: [
                Text(
                  "Saldo",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  balance,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ProfileStatCard(title: "Despesas", value: expensesCount),
              ProfileStatCard(title: "Desejos", value: desiresCount),
              ProfileStatCard(title: "Poupado", value: savedAmount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      color: AppColors.secondary.withValues(alpha: .12),
      child: Text(
        _initials(name),
        style: TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase());
    return letters.isEmpty ? "?" : letters.join();
  }
}
