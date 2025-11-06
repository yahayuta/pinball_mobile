import 'package:flutter/material.dart';

class TableEditorScreen extends StatelessWidget {
  const TableEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Table Editor'),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Custom table editor is not yet implemented.',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
