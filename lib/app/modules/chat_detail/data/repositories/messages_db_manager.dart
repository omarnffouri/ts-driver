import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ts_driver/app/modules/chat_detail/data/models/conversation_details_model.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';

class MessagesDatabase {
  static Database? _database;
  final String _messagesDatabaseName = 'messages_database.db';
  final String _messagesTableName = 'messages';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _messagesDatabaseName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_messagesTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversation_id INTEGER,
            message TEXT,
            message_id INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertMessage(ConversationMessageEntity message) async {
    final db = await database;

    return await db.insert(_messagesTableName, {
      'conversation_id': message.conversationId,
      'message_id': message.id,
      'message': jsonEncode(message.toJson())
    });
  }

  Future<void> insertMessages(List<ConversationMessageEntity> messages) async {
    if (messages.isEmpty) {
      return;
    }
    final db = await database;
    final batch = db.batch();
    for (final message in messages) {
      batch.insert(_messagesTableName, {
        'conversation_id': message.conversationId,
        'message_id': message.id,
        'message': jsonEncode(message.toJson())
      });
    }

    await batch.commit();
  }

  Future<List<ConversationMessageEntity>> getAllMessages(
      int conversationId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_messagesTableName,
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
        orderBy: 'id DESC');

    final messages = List.generate(maps.length, (i) {
      return ConversationMessageModel.fromJson(jsonDecode(maps[i]['message']));
    });

    return messages;
  }

  Future<ConversationMessageEntity?> getMessage(int messageId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_messagesTableName,
        where: 'message_id = ?', whereArgs: [messageId], orderBy: 'id DESC');

    final messages = List.generate(maps.length, (i) {
      return ConversationMessageModel.fromJson(jsonDecode(maps[i]['message']));
    });

    return messages.isNotEmpty ? messages[0] : null;
  }

  Future<int> updateMessage(int conversationId, int messageId,
      ConversationMessageEntity message) async {
    final db = await database;
    return await db.update(
        _messagesTableName,
        {
          "message": jsonEncode(message.toJson()),
        },
        where: 'conversation_id = ? AND message_id = ?',
        whereArgs: [conversationId, messageId]);
  }

  Future<int> deleteConversation(int conversationId) async {
    final db = await database;
    return await db.delete(
      _messagesTableName,
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }

  Future<int> deleteMessage(int conversationId, int messageId) async {
    final db = await database;
    return await db.delete(
      _messagesTableName,
      where: 'conversation_id = ? AND message_id = ?',
      whereArgs: [conversationId, messageId],
    );
  }

  Future<int> deleteAllMessages() async {
    final db = await database;
    return await db.delete(
      _messagesTableName,
    );
  }
}
