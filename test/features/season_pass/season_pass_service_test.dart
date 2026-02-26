import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_survivor/features/season_pass/models/season_pass.dart';
import 'package:space_survivor/features/season_pass/services/season_pass_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SeasonPassService', () {
    test('loads null when no season pass is saved', () async {
      final service = SeasonPassService();
      final result = await service.loadSeasonPass();
      expect(result, isNull);
    });

    test('saves and loads season pass', () async {
      final service = SeasonPassService();
      final pass = SeasonPass.create(seasonNumber: 1);

      await service.saveSeasonPass(pass);
      final loaded = await service.loadSeasonPass();

      expect(loaded, isNotNull);
      expect(loaded!.seasonNumber, 1);
      expect(loaded.tiers.length, 30);
    });

    test('adds XP and saves updated pass', () async {
      final service = SeasonPassService();
      final pass = SeasonPass.create(seasonNumber: 1);
      await service.saveSeasonPass(pass);

      final updated = await service.addXp(500);

      expect(updated.currentXp, 500);
    });

    test('accumulated XP advances tier correctly', () async {
      final service = SeasonPassService();
      final pass = SeasonPass.create(seasonNumber: 1);
      await service.saveSeasonPass(pass);

      // Add enough XP to reach tier 1 (1000 XP)
      final updated = await service.addXp(1000);

      expect(updated.currentTier, greaterThanOrEqualTo(1));
    });

    test('marks reward as claimed', () async {
      final service = SeasonPassService();
      final pass = SeasonPass.create(seasonNumber: 1);
      await service.saveSeasonPass(pass);

      final rewardId = pass.tiers[0].freeReward.id;
      final updated = await service.claimReward(rewardId);

      expect(updated.claimedRewards.contains(rewardId), true);
    });

    test('cannot claim same reward twice', () async {
      final service = SeasonPassService();
      final pass = SeasonPass.create(seasonNumber: 1);
      await service.saveSeasonPass(pass);

      final rewardId = pass.tiers[0].freeReward.id;
      await service.claimReward(rewardId);

      expect(
        () async => await service.claimReward(rewardId),
        throwsA(isA<RewardAlreadyClaimedException>()),
      );
    });

    test('upgrades to premium and saves', () async {
      final service = SeasonPassService();
      final pass = SeasonPass.create(seasonNumber: 1);
      await service.saveSeasonPass(pass);

      final upgraded = await service.upgradeToPremium();

      expect(upgraded.isPremium, true);

      final loaded = await service.loadSeasonPass();
      expect(loaded!.isPremium, true);
    });

    test('creates new season pass if none exists when adding XP', () async {
      final service = SeasonPassService();

      final result = await service.addXp(100);

      expect(result.currentXp, 100);
      expect(result.tiers.length, 30);
    });

    test('can check if reward is claimable for current tier', () async {
      final service = SeasonPassService();
      final pass = SeasonPass.create(seasonNumber: 1);
      await service.saveSeasonPass(pass);

      // Tier 0 reward is always available
      final tier0FreeReward = pass.tiers[0].freeReward;
      final isClaimable = service.isRewardClaimable(pass, tier0FreeReward.id);
      expect(isClaimable, true);

      // Tier 5 reward is not claimable at tier 0
      final tier5FreeReward = pass.tiers[5].freeReward;
      final isNotClaimable = service.isRewardClaimable(pass, tier5FreeReward.id);
      expect(isNotClaimable, false);
    });

    test('premium reward is only claimable when pass is premium', () async {
      final service = SeasonPassService();
      // Give enough XP to reach tier 1
      final pass = SeasonPass.create(seasonNumber: 1).addXp(1000);
      await service.saveSeasonPass(pass);

      final tier0PremiumReward = pass.tiers[0].premiumReward;
      if (tier0PremiumReward != null) {
        // Not claimable without premium
        expect(service.isRewardClaimable(pass, tier0PremiumReward.id), false);

        // Claimable after premium upgrade
        final premiumPass = pass.upgradeToPremium();
        expect(service.isRewardClaimable(premiumPass, tier0PremiumReward.id), true);
      }
    });
  });
}
