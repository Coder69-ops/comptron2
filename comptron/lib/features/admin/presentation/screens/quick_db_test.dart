import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State, Center;

class QuickDBTest extends StatelessWidget {
  const QuickDBTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick DB Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _testConnection(context);
          },
          child: const Text('Test MongoDB Connection'),
        ),
      ),
    );
  }

  Future<void> _testConnection(BuildContext context) async {
    try {
      // Your MongoDB connection string
      const mongoUri =
          'mongodb+srv://oveisawesome_db_user:1rj2ogNr7hO7XUG0@cluster0.pkrk3ft.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';

      final db = await Db.create(mongoUri);
      await db.open();

      // Test basic operations
      final collection = db.collection('test');
      await collection.insertOne({
        'test': 'Hello from Flutter!',
        'timestamp': DateTime.now(),
      });

      final result = await collection.findOne({'test': 'Hello from Flutter!'});

      await db.close();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Connection successful! Document: ${result?['test']}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Connection failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
