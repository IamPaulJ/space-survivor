import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/season_pass.dart';

class RewardAlreadyClaimedException implements Exception {
  final String rewardId;
  const RewardAlreadyClaimedException(this.rewardId);

  @override
  String toString() => 'Reward $rewardId has already been claimed';
}

class RewardNotClaimableException implements Exception {
  final String rewardId;
  const RewardNotClaimableException(this.rewardId);

  @override
  String toString() => 'Reward $rewardId is not yet claimable';
}

class SeasonPassService {
  static const String _storageKey = 'season_pass_data';

  Future<SeasonPass?> loadSeasonPass() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    if (json == null) return null;
    return SeasonPass.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveSeasonPass(SeasonPass pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(pass.toJson()));
  }

  Future<SeasonPass> addXp(int amount) async {
    var pass = await loadSeasonPass() ?? SeasonPass.create(seasonNumber: 1);
    final updated = pass.addXp(amount);
    await saveSeasonPass(updated);
    return updated;
  }

  Future<SeasonPass> claimReward(String rewardId) async {
    final pass = await loadSeasonPass() ?? SeasonPass.create(seasonNumber: 1);

    if (pass.claimedRewards.contains(rewardId)) {
      throw RewardAlreadyClaimedException(rewardId);
    }

    if (!isRewardClaimable(pass, rewardId)) {
      throw RewardNotClaimableException(rewardId);
    }

    final updated = pass.claimReward(rewardId);
    await saveSeasonPass(updated);
    return updated;
  }

  Future<SeasonPass> upgradeToPremium() async {
    var pass = await loadSeasonPass() ?? SeasonPass.create(seasonNumber: 1);
    final updated = pass.upgradeToPremium();
    await saveSeasonPass(updated);
    return updated;
  }

  bool isRewardClaimable(SeasonPass pass, String rewardId) {
    for (final tier in pass.tiers) {
      if (tier.freeReward.id == rewardId) {
        return tier.tierNumber - 1 <= pass.currentTier;
      }
      if (tier.premiumReward?.id == rewardId) {
        return pass.isPremium && tier.tierNumber - 1 <= pass.currentTier;
      }
    }
    return false;
  }
}
