import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/season_pass.dart';
import '../models/season_reward.dart';
import '../models/season_tier.dart';
import '../providers/season_pass_provider.dart';

class SeasonPassScreen extends StatelessWidget {
  const SeasonPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Consumer<SeasonPassProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7B68EE)),
            );
          }
          if (provider.error != null) {
            return Center(
              child: Text(
                'Error: ${provider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final pass = provider.seasonPass!;
          return _SeasonPassContent(pass: pass, provider: provider);
        },
      ),
    );
  }
}

class _SeasonPassContent extends StatelessWidget {
  final SeasonPass pass;
  final SeasonPassProvider provider;

  const _SeasonPassContent({required this.pass, required this.provider});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(child: _buildSeasonHeader()),
        SliverToBoxAdapter(child: _buildXpProgress()),
        if (!pass.isPremium) SliverToBoxAdapter(child: _buildPremiumBanner(context)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _TierRow(
              tier: pass.tiers[index],
              pass: pass,
              provider: provider,
            ),
            childCount: pass.tiers.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0A0A1A),
      expandedHeight: 0,
      pinned: true,
      title: const Text(
        'Season Pass',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildSeasonHeader() {
    final daysLeft = pass.endDate.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A3A), Color(0xFF2A1A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7B68EE).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Color(0xFFFFD700), size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Season ${pass.seasonNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$daysLeft days remaining',
                  style: const TextStyle(color: Color(0xFF7B68EE), fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Tier ${pass.currentTier}',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '/ ${SeasonPass.totalTiers}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXpProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Season XP', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                '${pass.currentXp} XP',
                style: const TextStyle(
                  color: Color(0xFF7B68EE),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: provider.currentTierProgress,
              backgroundColor: const Color(0xFF1A1A3A),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7B68EE)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPremiumPurchaseDialog(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFF0A0A1A), size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlock Premium Pass',
                    style: TextStyle(
                      color: Color(0xFF0A0A1A),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Exclusive skins, effects, frames & colors + No Ads',
                    style: TextStyle(color: Color(0xFF0A0A1A), fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '\$4.99',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _PremiumPurchaseDialog(provider: provider),
    );
  }
}

class _TierRow extends StatelessWidget {
  final SeasonTier tier;
  final SeasonPass pass;
  final SeasonPassProvider provider;

  const _TierRow({
    required this.tier,
    required this.pass,
    required this.provider,
  });

  bool get _isUnlocked => tier.tierNumber - 1 <= pass.currentTier;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _TierLabel(
            tierNumber: tier.tierNumber,
            isUnlocked: _isUnlocked,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RewardCard(
              reward: tier.freeReward,
              isClaimed: pass.claimedRewards.contains(tier.freeReward.id),
              isUnlocked: _isUnlocked,
              onClaim: () => provider.claimReward(tier.freeReward.id),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: tier.premiumReward != null
                ? _RewardCard(
                    reward: tier.premiumReward!,
                    isClaimed: pass.claimedRewards.contains(tier.premiumReward!.id),
                    isUnlocked: _isUnlocked && pass.isPremium,
                    isPremiumLocked: _isUnlocked && !pass.isPremium,
                    onClaim: pass.isPremium
                        ? () => provider.claimReward(tier.premiumReward!.id)
                        : null,
                  )
                : const _EmptyRewardSlot(),
          ),
        ],
      ),
    );
  }
}

class _TierLabel extends StatelessWidget {
  final int tierNumber;
  final bool isUnlocked;

  const _TierLabel({required this.tierNumber, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? const Color(0xFF7B68EE) : const Color(0xFF1A1A3A),
              border: Border.all(
                color: isUnlocked
                    ? const Color(0xFF7B68EE)
                    : const Color(0xFF2A2A4A),
              ),
            ),
            child: Center(
              child: Text(
                '$tierNumber',
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final SeasonReward reward;
  final bool isClaimed;
  final bool isUnlocked;
  final bool isPremiumLocked;
  final VoidCallback? onClaim;

  const _RewardCard({
    required this.reward,
    required this.isClaimed,
    required this.isUnlocked,
    this.isPremiumLocked = false,
    this.onClaim,
  });

  Color get _borderColor {
    if (reward.isPremium) return const Color(0xFFFFD700);
    return const Color(0xFF7B68EE);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked && !isClaimed ? onClaim : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isClaimed
              ? const Color(0xFF1A3A1A)
              : isUnlocked
                  ? const Color(0xFF1A1A3A)
                  : const Color(0xFF0F0F1F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isClaimed
                ? Colors.green.withValues(alpha: 0.6)
                : isUnlocked
                    ? _borderColor.withValues(alpha: 0.7)
                    : const Color(0xFF1A1A3A),
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                _RewardIcon(type: reward.type, isUnlocked: isUnlocked),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    reward.name,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.white38,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isClaimed)
              const Positioned(
                right: 0,
                top: 0,
                child: Icon(Icons.check_circle, color: Colors.green, size: 14),
              ),
            if (isPremiumLocked)
              Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  Icons.lock,
                  color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RewardIcon extends StatelessWidget {
  final RewardType type;
  final bool isUnlocked;

  const _RewardIcon({required this.type, required this.isUnlocked});

  IconData get _icon {
    return switch (type) {
      RewardType.stardust => Icons.auto_awesome,
      RewardType.box => Icons.card_giftcard,
      RewardType.emote => Icons.emoji_emotions,
      RewardType.skin => Icons.face,
      RewardType.effect => Icons.blur_on,
      RewardType.frame => Icons.crop_square,
      RewardType.nicknameColor => Icons.color_lens,
    };
  }

  Color get _color {
    if (!isUnlocked) return Colors.white24;
    return switch (type) {
      RewardType.stardust => const Color(0xFFFFD700),
      RewardType.box => const Color(0xFF4FC3F7),
      RewardType.emote => const Color(0xFFFF8A65),
      RewardType.skin => const Color(0xFFCE93D8),
      RewardType.effect => const Color(0xFF80CBC4),
      RewardType.frame => const Color(0xFFFFD700),
      RewardType.nicknameColor => const Color(0xFFF48FB1),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Icon(_icon, color: _color, size: 20);
  }
}

class _EmptyRewardSlot extends StatelessWidget {
  const _EmptyRewardSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1A1A2A)),
      ),
      child: const Center(
        child: Icon(Icons.remove, color: Colors.white12, size: 16),
      ),
    );
  }
}

class _PremiumPurchaseDialog extends StatelessWidget {
  final SeasonPassProvider provider;

  const _PremiumPurchaseDialog({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 56),
            const SizedBox(height: 16),
            const Text(
              'Premium Season Pass',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBenefitRow(Icons.face, 'Exclusive skins (4 total)'),
            _buildBenefitRow(Icons.blur_on, 'Limited effects (2 total)'),
            _buildBenefitRow(Icons.crop_square, 'Unique frames (3 total)'),
            _buildBenefitRow(Icons.color_lens, 'Nickname colors (3 total)'),
            _buildBenefitRow(Icons.block, 'Remove all ads'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF0A0A1A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  // Placeholder for IAP integration
                  await provider.upgradeToPremium();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text(
                  'Unlock for \$4.99',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe later', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 18),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
