import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/table_config_manager.dart';
import 'package:pinball_mobile/game/game_provider.dart';
import 'dart:convert'; // For json.decode and json.encode

class TableEditorScreen extends StatefulWidget {
  const TableEditorScreen({super.key});

  @override
  State<TableEditorScreen> createState() => _TableEditorScreenState();
}

class _TableEditorScreenState extends State<TableEditorScreen> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _tableNameController = TextEditingController();
  String? _errorMessage;
  List<TableConfig> _customTables = [];

  @override
  void initState() {
    super.initState();
    _loadCustomTables();
  }

  Future<void> _loadCustomTables() async {
    final tableConfigManager = Provider.of<GameProvider>(context, listen: false).tableConfigManager;
    _customTables = tableConfigManager.getCustomTables();
    setState(() {});
  }

  Future<void> _saveTable() async {
    setState(() {
      _errorMessage = null;
    });
    if (_tableNameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Table name cannot be empty.';
      });
      return;
    }
    try {
      final jsonMap = json.decode(_jsonController.text) as Map<String, dynamic>;
      final tableConfig = TableConfig(
        name: _tableNameController.text,
        components: (jsonMap['components'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );
      final tableConfigManager = Provider.of<GameProvider>(context, listen: false).tableConfigManager;
      await tableConfigManager.saveCustomTable(tableConfig);
      _jsonController.clear();
      _tableNameController.clear();
      _loadCustomTables();
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid JSON format: $e';
      });
    }
  }

  Future<void> _deleteTable(String tableName) async {
    final tableConfigManager = Provider.of<GameProvider>(context, listen: false).tableConfigManager;
    await tableConfigManager.deleteCustomTable(tableName);
    _loadCustomTables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Table Editor'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tableNameController,
              decoration: const InputDecoration(
                labelText: 'Table Name',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _jsonController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: 'Table JSON Configuration',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveTable,
              child: const Text('Save Custom Table'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Saved Custom Tables:',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _customTables.length,
                itemBuilder: (context, index) {
                  final table = _customTables[index];
                  return ListTile(
                    title: Text(
                      table.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTable(table.name),
                    ),
                    onTap: () {
                      // TODO: Implement loading this table into the game
                      // For now, just populate the editor with its JSON
                      _tableNameController.text = table.name;
                      _jsonController.text = json.encode(table.toJson());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
