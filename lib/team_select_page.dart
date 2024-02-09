import 'package:biden_blast/teams_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeamSelectPage extends StatelessWidget {
  final Function(int id) onTeamSelect;
  TeamSelectPage({super.key, required this.onTeamSelect});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
      padding: EdgeInsets.all(20),
      child: Consumer<TeamsModel> (
      builder: (context, teams, _) => ListView(
        children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Select a team.'),
        ),
        for (var team in teams.teams)
          ListTile(
            title: ElevatedButton(
              child: Text('${team.name} (${team.id})'),
              onPressed: () => onTeamSelect(team.id),
            ),
          ),
        ],
      ))),
    );
  }
}