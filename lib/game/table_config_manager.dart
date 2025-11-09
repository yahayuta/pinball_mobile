import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TableConfig {
  final String name;
  final List<Map<String, dynamic>> components;

  TableConfig({required this.name, required this.components});

  Map<String, dynamic> toJson() => {
        'name': name,
        'components': components,
      };

  factory TableConfig.fromJson(Map<String, dynamic> json) => TableConfig(
        name: json['name'] as String,
        components: (json['components'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );
}

class TableConfigManager {
  static const String _customTablesKey = 'custom_tables';

  final SharedPreferences _prefs;

  TableConfigManager(this._prefs);

  List<TableConfig> getCustomTables() {
    final String? tablesJson = _prefs.getString(_customTablesKey);
    if (tablesJson == null) {
      return [];
    }
    final List<dynamic> tablesDynamic = json.decode(tablesJson) as List<dynamic>;
    return tablesDynamic
        .map((e) => TableConfig.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustomTable(TableConfig config) async {
    List<TableConfig> currentTables = getCustomTables();
    // Remove existing table with the same name if it exists
    currentTables.removeWhere((table) => table.name == config.name);
    currentTables.add(config);
    final String tablesJson = json.encode(currentTables.map((e) => e.toJson()).toList());
    await _prefs.setString(_customTablesKey, tablesJson);
  }

  Future<void> deleteCustomTable(String tableName) async {
    List<TableConfig> currentTables = getCustomTables();
    currentTables.removeWhere((table) => table.name == tableName);
    final String tablesJson = json.encode(currentTables.map((e) => e.toJson()).toList());
    await _prefs.setString(_customTablesKey, tablesJson);
  }
}
