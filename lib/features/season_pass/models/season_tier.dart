import 'season_reward.dart';

class SeasonTier {
  final int tierNumber;
  final int xpRequired;
  final SeasonReward freeReward;
  final SeasonReward? premiumReward;

  const SeasonTier({
    required this.tierNumber,
    required this.xpRequired,
    required this.freeReward,
    this.premiumReward,
  });

  Map<String, dynamic> toJson() => {
        'tierNumber': tierNumber,
        'xpRequired': xpRequired,
        'freeReward': freeReward.toJson(),
        'premiumReward': premiumReward?.toJson(),
      };

  factory SeasonTier.fromJson(Map<String, dynamic> json) => SeasonTier(
        tierNumber: json['tierNumber'] as int,
        xpRequired: json['xpRequired'] as int,
        freeReward: SeasonReward.fromJson(json['freeReward'] as Map<String, dynamic>),
        premiumReward: json['premiumReward'] != null
            ? SeasonReward.fromJson(json['premiumReward'] as Map<String, dynamic>)
            : null,
      );
}
