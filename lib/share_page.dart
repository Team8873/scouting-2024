import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:biden_blast/team.dart';
import 'package:biden_blast/teams_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';

List<Team> _parseTeams(String data) {
  final List json = jsonDecode(data);

  return json.map((j) => Team.fromJson(j)).toList();
}

Future<void> _receiveTeams(_SharePageState state) async {
  final teamsModel = Provider.of<TeamsModel>(state.context, listen: false);

  // Exit the receive state even if binding the socket fails
  Timer(Duration(seconds: 12), () => state._endRecv());

  var server = await ServerSocket.bind('0.0.0.0', 8873);
  state._startRecv();

  server.listen((socket) {
    socket.listen((List<int> data) async {
      final teamsList = await compute(_parseTeams, String.fromCharCodes(data));
      final (added, updated) = teamsModel.addTeams(teamsList);
      state.message('$added teams received, $updated updated from ${socket.remoteAddress.host}.');
    });
  });

  Timer(Duration(seconds: 10), () => server.close());
}

Future<void> _shareTeams(_SharePageState state, InternetAddress? target) async {
  if (target == null) {
    state.message('IP Address was null.');
  }

  final teamsJson = jsonEncode(Provider.of<TeamsModel>(state.context, listen: false).teams.map((t) => t.toJson()).toList());

  var sock = await Socket.connect(target, 8873).onError((error, stackTrace) {
    state.message(error.toString());
    print(stackTrace);
    return Future.error(error ?? 'error', stackTrace);
  },);

  sock.add(utf8.encode(teamsJson));
  await sock.flush();
  sock.close();

  state.message('Teams shared');
}

class SharePage extends StatefulWidget {
  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final _sendKey = GlobalKey<FormState>();

  InternetAddress? targetAddress;
  String myAddress = 'Getting IP';
  bool _receiving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final idStyle = theme.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))
              ),
              child: _makeSendTile(),
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.0), bottomRight: Radius.circular(16.0))
              ),
              child: _makeReceiveTile(idStyle),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getIP() async {
    String addr = (await NetworkInfo().getWifiIP()) ?? 'Not connected to WiFi';

    setState(() => myAddress = addr);
  }

  @override
  void initState() {
    super.initState();
    getIP();
  }

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _endRecv() {
    setState(() => _receiving = false);
  }


  ExpansionTile _makeReceiveTile(TextStyle idStyle) {
    return ExpansionTile(
      title: Text('Receive'),
      shape: const Border(),
      initiallyExpanded: true,
      children: [
        Text('ID: $myAddress', style: idStyle),
        SizedBox(height: 16.0),
        ElevatedButton.icon(
          icon: Icon(_receiving ? Icons.circle_outlined : Icons.file_download_outlined),
          label: Text(_receiving ? 'Waiting for data...' : 'Receive'),
          onPressed: () { if (!_receiving) { _receiveTeams(this); }},
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  ExpansionTile _makeSendTile() {
    return ExpansionTile(
      title: Text('Send'),
      shape: const Border(),
      initiallyExpanded: true,
      children: [
        Form(
          key: _sendKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  decoration: const InputDecoration(hintText: 'Target IP', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (s) => s != null && InternetAddress.tryParse(s) == null ? 'Enter a valid IP Adress' : null,
                  onSaved: (String? val) => setState(() => targetAddress = InternetAddress(val!)),
                ),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.file_upload_outlined),
                label: const Text('Share'),
                onPressed: () { if (!_sendKey.currentState!.validate()) return; _sendKey.currentState?.save(); _shareTeams(this, targetAddress); } ,
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ],
    );
  }

  void _startRecv() {
    setState(() => _receiving = true);
  }
}
