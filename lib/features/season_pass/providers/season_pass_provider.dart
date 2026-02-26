import 'package:flutter/foundation.dart';
import '../models/season_pass.dart';
import '../services/season_pass_service.dart';

class SeasonPassProvider extends ChangeNotifier {
  final SeasonPassService _service;

  SeasonPass? _seasonPass;
  bool _isLoading = true;
  String? _error;

  SeasonPassProvider(this._service);

  SeasonPass? get seasonPass => _seasonPass;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isRewardClaimed(String rewardId) =>
      _seasonPass?.claimedRewards.contains(rewardId) ?? false;

  double get currentTierProgress {
    if (_seasonPass == null) return 0.0;
    final pass = _seasonPass!;
    final tierIndex = pass.currentTier;
    if (tierIndex >= SeasonPass.totalTiers) return 1.0;

    // Calculate XP accumulated up to current tier
    int xpForCompletedTiers = 0;
    for (int i = 0; i < tierIndex; i++) {
      xpForCompletedTiers += pass.tiers[i].xpRequired;
    }

    final xpInCurrentTier = pass.currentXp - xpForCompletedTiers;
    final xpNeededForNextTier = pass.tiers[tierIndex].xpRequired;

    if (xpNeededForNextTier == 0) return 0.0;
    return (xpInCurrentTier / xpNeededForNextTier).clamp(0.0, 1.0);
  }

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _seasonPass = await _service.loadSeasonPass() ?? SeasonPass.create(seasonNumber: 1);
      if (_seasonPass != null) {
        await _service.saveSeasonPass(_seasonPass!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addXp(int amount) async {
    try {
      _seasonPass = await _service.addXp(amount);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> upgradeToPremium() async {
    try {
      _seasonPass = await _service.upgradeToPremium();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> claimReward(String rewardId) async {
    try {
      _seasonPass = await _service.claimReward(rewardId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
