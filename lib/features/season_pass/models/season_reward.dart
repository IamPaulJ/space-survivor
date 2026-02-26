enum RewardType {
  stardust,
  box,
  emote,
  skin,
  effect,
  frame,
  nicknameColor,
}

class SeasonReward {
  final String id;
  final String name;
  final RewardType type;
  final int quantity;
  final bool isPremium;

  const SeasonReward({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.isPremium,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'quantity': quantity,
        'isPremium': isPremium,
      };

  factory SeasonReward.fromJson(Map<String, dynamic> json) => SeasonReward(
        id: json['id'] as String,
        name: json['name'] as String,
        type: RewardType.values.byName(json['type'] as String),
        quantity: json['quantity'] as int,
        isPremium: json['isPremium'] as bool,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SeasonReward && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
