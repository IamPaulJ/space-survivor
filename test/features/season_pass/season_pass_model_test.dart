import 'package:flutter_test/flutter_test.dart';
import 'package:space_survivor/features/season_pass/models/season_pass.dart';
import 'package:space_survivor/features/season_pass/models/season_tier.dart';
import 'package:space_survivor/features/season_pass/models/season_reward.dart';

void main() {
  group('SeasonReward', () {
    test('creates free reward with stardust type', () {
      const reward = SeasonReward(
        id: 'reward_1',
        name: 'Stardust x100',
        type: RewardType.stardust,
        quantity: 100,
        isPremium: false,
      );

      expect(reward.id, 'reward_1');
      expect(reward.type, RewardType.stardust);
      expect(reward.quantity, 100);
      expect(reward.isPremium, false);
    });

    test('creates premium reward with skin type', () {
      const reward = SeasonReward(
        id: 'reward_skin_1',
        name: 'Galaxy Warrior Skin',
        type: RewardType.skin,
        quantity: 1,
        isPremium: true,
      );

      expect(reward.isPremium, true);
      expect(reward.type, RewardType.skin);
    });

    test('serializes to and from JSON', () {
      const reward = SeasonReward(
        id: 'reward_1',
        name: 'Stardust x100',
        type: RewardType.stardust,
        quantity: 100,
        isPremium: false,
      );

      final json = reward.toJson();
      final restored = SeasonReward.fromJson(json);

      expect(restored.id, reward.id);
      expect(restored.type, reward.type);
      expect(restored.quantity, reward.quantity);
      expect(restored.isPremium, reward.isPremium);
    });
  });

  group('SeasonTier', () {
    test('has tier number from 1 to 30', () {
      const tier = SeasonTier(
        tierNumber: 1,
        xpRequired: 1000,
        freeReward: SeasonReward(
          id: 'free_1',
          name: 'Stardust x50',
          type: RewardType.stardust,
          quantity: 50,
          isPremium: false,
        ),
        premiumReward: SeasonReward(
          id: 'prem_1',
          name: 'Nebula Skin',
          type: RewardType.skin,
          quantity: 1,
          isPremium: true,
        ),
      );

      expect(tier.tierNumber, 1);
      expect(tier.xpRequired, 1000);
      expect(tier.freeReward.type, RewardType.stardust);
      expect(tier.premiumReward?.isPremium, true);
    });

    test('some tiers have no premium reward', () {
      const tier = SeasonTier(
        tierNumber: 5,
        xpRequired: 5000,
        freeReward: SeasonReward(
          id: 'free_5',
          name: 'Basic Box',
          type: RewardType.box,
          quantity: 1,
          isPremium: false,
        ),
        premiumReward: null,
      );

      expect(tier.premiumReward, isNull);
    });

    test('serializes to and from JSON', () {
      const tier = SeasonTier(
        tierNumber: 10,
        xpRequired: 10000,
        freeReward: SeasonReward(
          id: 'free_10',
          name: 'Stardust x200',
          type: RewardType.stardust,
          quantity: 200,
          isPremium: false,
        ),
        premiumReward: null,
      );

      final json = tier.toJson();
      final restored = SeasonTier.fromJson(json);

      expect(restored.tierNumber, tier.tierNumber);
      expect(restored.xpRequired, tier.xpRequired);
    });
  });

  group('SeasonPass', () {
    test('has exactly 30 tiers', () {
      final pass = SeasonPass.create(seasonNumber: 1);
      expect(pass.tiers.length, 30);
    });

    test('tier numbers are 1 through 30', () {
      final pass = SeasonPass.create(seasonNumber: 1);
      for (int i = 0; i < 30; i++) {
        expect(pass.tiers[i].tierNumber, i + 1);
      }
    });

    test('starts at tier 0 XP with no premium by default', () {
      final pass = SeasonPass.create(seasonNumber: 1);
      expect(pass.currentXp, 0);
      expect(pass.currentTier, 0);
      expect(pass.isPremium, false);
    });

    test('season duration is 4 weeks (28 days)', () {
      final pass = SeasonPass.create(seasonNumber: 1);
      final duration = pass.endDate.difference(pass.startDate);
      expect(duration.inDays, 28);
    });

    test('season is active when current date is within range', () {
      final now = DateTime.now();
      final pass = SeasonPass(
        seasonNumber: 1,
        tiers: SeasonPass.buildDefaultTiers(),
        currentXp: 0,
        currentTier: 0,
        isPremium: false,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 21)),
        claimedRewards: {},
      );
      expect(pass.isActive, true);
    });

    test('season is inactive when past end date', () {
      final now = DateTime.now();
      final pass = SeasonPass(
        seasonNumber: 1,
        tiers: SeasonPass.buildDefaultTiers(),
        currentXp: 0,
        currentTier: 0,
        isPremium: false,
        startDate: now.subtract(const Duration(days: 35)),
        endDate: now.subtract(const Duration(days: 7)),
        claimedRewards: {},
      );
      expect(pass.isActive, false);
    });

    test('free track has stardust, boxes, and 1 emote', () {
      final pass = SeasonPass.create(seasonNumber: 1);
      final freeRewards = pass.tiers.map((t) => t.freeReward).toList();

      final stardustRewards = freeRewards.where((r) => r.type == RewardType.stardust);
      final boxRewards = freeRewards.where((r) => r.type == RewardType.box);
      final emoteRewards = freeRewards.where((r) => r.type == RewardType.emote);

      expect(stardustRewards, isNotEmpty);
      expect(boxRewards, isNotEmpty);
      expect(emoteRewards.length, 1);
    });

    test('premium track has skins, effects, frames, and nickname colors', () {
      final pass = SeasonPass.create(seasonNumber: 1);
      final premiumRewards = pass.tiers
          .map((t) => t.premiumReward)
          .where((r) => r != null)
          .cast<SeasonReward>()
          .toList();

      final skinRewards = premiumRewards.where((r) => r.type == RewardType.skin);
      final effectRewards = premiumRewards.where((r) => r.type == RewardType.effect);
      final frameRewards = premiumRewards.where((r) => r.type == RewardType.frame);
      final nicknameColors = premiumRewards.where((r) => r.type == RewardType.nicknameColor);

      expect(skinRewards, isNotEmpty);
      expect(effectRewards, isNotEmpty);
      expect(frameRewards, isNotEmpty);
      expect(nicknameColors, isNotEmpty);
    });

    test('XP addition advances tier', () {
      final pass = SeasonPass.create(seasonNumber: 1);
      final tier1XpRequired = pass.tiers[0].xpRequired;

      final updated = pass.addXp(tier1XpRequired);

      expect(updated.currentTier, greaterThanOrEqualTo(1));
      expect(updated.currentXp, tier1XpRequired);
    });

    test('premium upgrade sets isPremium to true', () {
      final pass = SeasonPass.create(seasonNumber: 1);
      expect(pass.isPremium, false);

      final upgraded = pass.upgradeToPremium();
      expect(upgraded.isPremium, true);
    });

    test('serializes to and from JSON', () {
      final pass = SeasonPass.create(seasonNumber: 1);
      final json = pass.toJson();
      final restored = SeasonPass.fromJson(json);

      expect(restored.seasonNumber, pass.seasonNumber);
      expect(restored.tiers.length, pass.tiers.length);
      expect(restored.isPremium, pass.isPremium);
      expect(restored.currentTier, pass.currentTier);
    });
  });
}
