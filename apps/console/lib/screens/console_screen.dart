import 'package:flutter/material.dart';

import '../widgets/call_view.dart';
import '../widgets/history_list.dart';
import '../widgets/scenario_panel.dart';

class ConsoleScreen extends StatelessWidget {
  const ConsoleScreen({super.key, required this.server, required this.localCommands});

  final Uri server;
  final bool localCommands;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 340,
            child: ScenarioPanel(server: server, localCommands: localCommands),
          ),
          const VerticalDivider(width: 1),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: CallView()),
                Divider(height: 1),
                SizedBox(height: 180, child: HistoryList()),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
