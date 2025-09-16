// widgets/command_input.dart
import 'package:flutter/material.dart';

class CommandInput extends StatefulWidget {
  final Function(List<String>) onExecute;
  final bool isExecuting;

  CommandInput({required this.onExecute, required this.isExecuting});

  @override
  _CommandInputState createState() => _CommandInputState();
}

class _CommandInputState extends State<CommandInput> {
  final TextEditingController _singleController = TextEditingController();
  final TextEditingController _multiController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commands:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'forward • backward • turn left • turn right',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontFamily: 'Courier',
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _singleController,
                    decoration: InputDecoration(
                      hintText: 'Enter command (e.g., forward)',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontFamily: 'Courier'),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty && !widget.isExecuting) {
                        widget.onExecute([value.trim()]);
                        _singleController.clear();
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: widget.isExecuting
                      ? null
                      : () {
                          String command = _singleController.text.trim();
                          if (command.isNotEmpty) {
                            widget.onExecute([command]);
                            _singleController.clear();
                          }
                        },
                  color: Colors.blue.shade800,
                  iconSize: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
