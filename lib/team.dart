enum Drivetrain {
  trank,
  swerve,
  mecanum,
}

extension DrivetrainFriendly on Drivetrain {
  String toFriendly() {
    return switch (this) {
      Drivetrain.trank => "Trank",
      Drivetrain.swerve => "Swerve",
      Drivetrain.mecanum => "Mecanum",
    };
  }

  static Drivetrain fromFriendly(String friendly) {
    return switch (friendly) {
      "Trank" => Drivetrain.trank,
      "Swerve" => Drivetrain.swerve,
      "Mecanum" => Drivetrain.mecanum,
      _ => Drivetrain.trank,
    };
  }
}

enum Pickup {
  defenseBot,
  floor,
  substation,
  both,
}

extension PickupFriendly on Pickup {
  String toFriendly() {
    return switch (this) {
      Pickup.defenseBot => "None",
      Pickup.floor => "Floor",
      Pickup.substation => "Substation",
      Pickup.both => "Both",
    };
  }

  static Pickup fromFriendly(String friendly) {
    return switch (friendly) {
      "None" => Pickup.defenseBot,
      "Floor" => Pickup.floor,
      "Substation" => Pickup.substation,
      "Both" => Pickup.both,
      _ => Pickup.defenseBot,
    };
  }
}

class MatchAverage {
  int id;
  String name;
  double ampAuto = 0;
  double speakerAuto = 0;
  double leaves = 0.0;

  double ampTele = 0;
  double speakerTele = 0;

  double hangs = 0;
  double trap = 0;
  double harmony = 0;

  double offenseScore = 5.0;
  double defenseScore = 5.0;
  double overallScore = 5.0;
  double cycleTime = 5.0;

  double overallWeight = 5.0;
  double teleWeight = 5.0;
  double autonWeight = 5.0;

  MatchAverage.fromMatches(this.id, this.name, List<Match> matches) {
    for (var match in matches) {
        ampAuto += match.ampAuto;
        speakerAuto += match.speakerAuto;
        leaves += match.leaves ? 1 : 0;

        ampTele += match.ampTele;
        speakerTele += match.speakerTele;

        hangs += match.hangs ? 1 : 0;
        trap += match.trap ? 1 : 0;
        harmony += match.harmony ? 1 : 0;

        offenseScore += match.offenseScore;
        defenseScore += match.defenseScore;
        overallScore += match.overallScore;
        cycleTime += match.cycleTime;
    }

    ampAuto /= matches.length;
    speakerAuto /= matches.length;
    leaves /= matches.length;

    ampTele /= matches.length;
    speakerTele /= matches.length;

    hangs /= matches.length;
    trap /= matches.length;
    harmony /= matches.length;

    offenseScore /= matches.length;
    defenseScore /= matches.length;
    overallScore /= matches.length;
    cycleTime /= matches.length;

    overallWeight = ampAuto + ampTele + speakerAuto + speakerTele + hangs;
    teleWeight = ampTele + speakerTele + hangs;
    autonWeight = ampAuto + speakerAuto;
  }
}

class Match {
  final int number;
  int ampAuto = 0;
  int speakerAuto = 0;
  bool leaves = false;

  int ampTele = 0;
  int speakerTele = 0;
  Pickup pickup = Pickup.defenseBot;

  bool hangs = false;
  bool trap = false;
  bool harmony = false;

  double offenseScore = 5.0;
  double defenseScore = 5.0;
  double overallScore = 5.0;
  double cycleTime = 5.0;

  Match({required this.number});

  Map<String, dynamic> toJson() =>
  {
    'amp_auto': ampAuto,
    'speaker_auto': speakerAuto,
    'amp_tele': ampTele,
    'speaker_tele': speakerTele,
    'offense': offenseScore,
    'defense': defenseScore,
    'overall': overallScore,
    'leaves': leaves,
    'hangs': hangs,
    'trap': trap,
    'harmony': harmony,
    'pickup': pickup.toFriendly(),
    'cycle_time': cycleTime,
    'number': number,
  };

  Match.fromJson(Map<String, dynamic> json) : number = json['number'] {
    ampAuto = json['amp_auto'];
    speakerAuto = json['speaker_auto'];
    ampTele = json['amp_tele'];
    speakerTele = json['speaker_tele'];
    offenseScore = json['offense'];
    defenseScore = json['defense'];
    overallScore = json['overall'];
    leaves = json['leaves'];
    hangs = json['hangs'];
    trap = json['trap'];
    harmony = json['harmony'];
    pickup = PickupFriendly.fromFriendly(json['pickup']);
    cycleTime = json['cycle_time'];
  }
}

class Team {
  late final int id;
  late final String name;

  double weight = 80.0;
  bool underStage = false;
  Drivetrain drivetrain = Drivetrain.trank;
  double width = 20.0;
  double length = 20.0;
  double height = 20.0;

  List<Match> matches = [];

  Team({required this.id, required this.name});

  Map<String, dynamic> toJson() =>
  {
    'id': id,
    'name': name,
    'weight': weight,
    'under_stage': underStage,
    'drivetrain': drivetrain.toFriendly(),
    'width': width,
    'length': length,
    'height': height,
    'matches': matches.map((m) => m.toJson()).toList(),
  };

  Team.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    weight = json['weight'];
    underStage = json['under_stage'];
    drivetrain = DrivetrainFriendly.fromFriendly(json['drivetrain']);
    width = json['width'];
    length = json['length'];
    height = json['height'];
    matches = (json['matches'] as List<dynamic>).map((j) => Match.fromJson(j as Map<String, dynamic>)).toList();
  }
}
