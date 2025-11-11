import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/table_config_manager.dart';
import 'package:pinball_mobile/game/game_provider.dart';
import 'dart:convert'; // For json.decode and json.encode
import 'package:pinball_mobile/menu/widgets/menu_button.dart'; // Import MenuButton
import 'package:pinball_mobile/menu/widgets/styled_text_field.dart'; // Import StyledTextField

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
            StyledTextField(
              controller: _tableNameController,
              labelText: 'Table Name',
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StyledTextField(
                controller: _jsonController,
                labelText: 'Table JSON Configuration',
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
            MenuButton(
              text: 'Save Custom Table',
              onPressed: _saveTable,
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: MenuButton(
                            text: table.name,
                            onPressed: () {
                              // For now, just populate the editor with its JSON
                              _tableNameController.text = table.name;
                              _jsonController.text = json.encode(table.toJson());
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTable(table.name),
                        ),
                      ],
                    ),
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
