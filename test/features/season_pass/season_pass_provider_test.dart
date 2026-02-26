import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_survivor/features/season_pass/models/season_pass.dart';
import 'package:space_survivor/features/season_pass/providers/season_pass_provider.dart';
import 'package:space_survivor/features/season_pass/services/season_pass_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SeasonPassProvider', () {
    test('starts in loading state', () {
      final provider = SeasonPassProvider(SeasonPassService());
      expect(provider.isLoading, true);
      expect(provider.seasonPass, isNull);
    });

    test('loads season pass on init', () async {
      final service = SeasonPassService();
      final pass = SeasonPass.create(seasonNumber: 1);
      await service.saveSeasonPass(pass);

      final provider = SeasonPassProvider(service);
      await provider.init();

      expect(provider.isLoading, false);
      expect(provider.seasonPass, isNotNull);
      expect(provider.seasonPass!.seasonNumber, 1);
    });

    test('creates new season pass if none exists', () async {
      final provider = SeasonPassProvider(SeasonPassService());
      await provider.init();

      expect(provider.seasonPass, isNotNull);
      expect(provider.seasonPass!.tiers.length, 30);
    });

    test('addXp updates provider state', () async {
      final provider = SeasonPassProvider(SeasonPassService());
      await provider.init();

      await provider.addXp(500);

      expect(provider.seasonPass!.currentXp, 500);
    });

    test('upgradeToPremium updates provider state', () async {
      final provider = SeasonPassProvider(SeasonPassService());
      await provider.init();

      expect(provider.seasonPass!.isPremium, false);
      await provider.upgradeToPremium();
      expect(provider.seasonPass!.isPremium, true);
    });

    test('claimReward updates claimed rewards set', () async {
      final provider = SeasonPassProvider(SeasonPassService());
      await provider.init();

      final rewardId = provider.seasonPass!.tiers[0].freeReward.id;
      await provider.claimReward(rewardId);

      expect(provider.seasonPass!.claimedRewards.contains(rewardId), true);
    });

    test('isRewardClaimed returns correct state', () async {
      final provider = SeasonPassProvider(SeasonPassService());
      await provider.init();

      final rewardId = provider.seasonPass!.tiers[0].freeReward.id;
      expect(provider.isRewardClaimed(rewardId), false);

      await provider.claimReward(rewardId);
      expect(provider.isRewardClaimed(rewardId), true);
    });

    test('currentTierProgress returns XP fraction within current tier', () async {
      final provider = SeasonPassProvider(SeasonPassService());
      await provider.init();

      expect(provider.currentTierProgress, 0.0);

      await provider.addXp(500);
      expect(provider.currentTierProgress, closeTo(0.5, 0.01));
    });

    test('error state is set when service throws', () async {
      final provider = SeasonPassProvider(_FailingSeasonPassService());
      await provider.init();

      expect(provider.error, isNotNull);
      expect(provider.isLoading, false);
    });
  });
}

class _FailingSeasonPassService extends SeasonPassService {
  @override
  Future<SeasonPass?> loadSeasonPass() async {
    throw Exception('Storage failure');
  }
}
