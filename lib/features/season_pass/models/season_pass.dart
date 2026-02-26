import 'season_tier.dart';
import 'season_reward.dart';

class SeasonPass {
  final int seasonNumber;
  final List<SeasonTier> tiers;
  final int currentXp;
  final int currentTier;
  final bool isPremium;
  final DateTime startDate;
  final DateTime endDate;
  final Set<String> claimedRewards;

  static const int totalTiers = 30;
  static const int xpPerTier = 1000;
  static const Duration seasonDuration = Duration(days: 28);

  const SeasonPass({
    required this.seasonNumber,
    required this.tiers,
    required this.currentXp,
    required this.currentTier,
    required this.isPremium,
    required this.startDate,
    required this.endDate,
    required this.claimedRewards,
  });

  factory SeasonPass.create({required int seasonNumber}) {
    final now = DateTime.now();
    return SeasonPass(
      seasonNumber: seasonNumber,
      tiers: buildDefaultTiers(),
      currentXp: 0,
      currentTier: 0,
      isPremium: false,
      startDate: now,
      endDate: now.add(seasonDuration),
      claimedRewards: {},
    );
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  SeasonPass addXp(int amount) {
    final newXp = currentXp + amount;
    final newTier = _calculateTier(newXp);
    return _copyWith(currentXp: newXp, currentTier: newTier);
  }

  SeasonPass upgradeToPremium() => _copyWith(isPremium: true);

  SeasonPass claimReward(String rewardId) {
    final updated = Set<String>.from(claimedRewards)..add(rewardId);
    return _copyWith(claimedRewards: updated);
  }

  int _calculateTier(int xp) {
    int tier = 0;
    int accumulated = 0;
    for (final t in tiers) {
      accumulated += t.xpRequired;
      if (xp >= accumulated) {
        tier = t.tierNumber;
      } else {
        break;
      }
    }
    return tier;
  }

  SeasonPass _copyWith({
    int? currentXp,
    int? currentTier,
    bool? isPremium,
    Set<String>? claimedRewards,
  }) {
    return SeasonPass(
      seasonNumber: seasonNumber,
      tiers: tiers,
      currentXp: currentXp ?? this.currentXp,
      currentTier: currentTier ?? this.currentTier,
      isPremium: isPremium ?? this.isPremium,
      startDate: startDate,
      endDate: endDate,
      claimedRewards: claimedRewards ?? this.claimedRewards,
    );
  }

  Map<String, dynamic> toJson() => {
        'seasonNumber': seasonNumber,
        'tiers': tiers.map((t) => t.toJson()).toList(),
        'currentXp': currentXp,
        'currentTier': currentTier,
        'isPremium': isPremium,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'claimedRewards': claimedRewards.toList(),
      };

  factory SeasonPass.fromJson(Map<String, dynamic> json) => SeasonPass(
        seasonNumber: json['seasonNumber'] as int,
        tiers: (json['tiers'] as List)
            .map((t) => SeasonTier.fromJson(t as Map<String, dynamic>))
            .toList(),
        currentXp: json['currentXp'] as int,
        currentTier: json['currentTier'] as int,
        isPremium: json['isPremium'] as bool,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        claimedRewards: Set<String>.from(json['claimedRewards'] as List),
      );

  static List<SeasonTier> buildDefaultTiers() {
    final tiers = <SeasonTier>[];
    for (int i = 1; i <= totalTiers; i++) {
      tiers.add(SeasonTier(
        tierNumber: i,
        xpRequired: xpPerTier,
        freeReward: _buildFreeReward(i),
        premiumReward: _buildPremiumReward(i),
      ));
    }
    return tiers;
  }

  static SeasonReward _buildFreeReward(int tier) {
    if (tier == 15) {
      return SeasonReward(
        id: 'free_emote_$tier',
        name: 'Star Burst Emote',
        type: RewardType.emote,
        quantity: 1,
        isPremium: false,
      );
    }
    if (tier % 5 == 0 && tier != 15) {
      return SeasonReward(
        id: 'free_box_$tier',
        name: 'Star Box',
        type: RewardType.box,
        quantity: 1,
        isPremium: false,
      );
    }
    final amount = 50 + (tier * 10);
    return SeasonReward(
      id: 'free_stardust_$tier',
      name: 'Stardust x$amount',
      type: RewardType.stardust,
      quantity: amount,
      isPremium: false,
    );
  }

  static SeasonReward? _buildPremiumReward(int tier) {
    if (tier == 5 || tier == 15 || tier == 25 || tier == 30) {
      return SeasonReward(
        id: 'prem_skin_$tier',
        name: 'Cosmic Skin ${tier ~/ 5}',
        type: RewardType.skin,
        quantity: 1,
        isPremium: true,
      );
    }
    if (tier == 10 || tier == 20) {
      return SeasonReward(
        id: 'prem_effect_$tier',
        name: 'Nebula Effect ${tier ~/ 10}',
        type: RewardType.effect,
        quantity: 1,
        isPremium: true,
      );
    }
    if (tier == 7 || tier == 17 || tier == 27) {
      return SeasonReward(
        id: 'prem_frame_$tier',
        name: 'Star Frame ${(tier ~/ 10) + 1}',
        type: RewardType.frame,
        quantity: 1,
        isPremium: true,
      );
    }
    if (tier == 3 || tier == 13 || tier == 23) {
      return SeasonReward(
        id: 'prem_color_$tier',
        name: 'Galaxy Color ${(tier ~/ 10) + 1}',
        type: RewardType.nicknameColor,
        quantity: 1,
        isPremium: true,
      );
    }
    return null;
  }
}
