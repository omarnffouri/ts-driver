import 'dart:convert';

import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:ts_driver/app/modules/chat/data/models/conversation_model.dart';
import 'package:ts_driver/app/modules/chat/data/models/group_conversation_model.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/group_conversation_entity.dart';

class ConversationsDatabase {
  static Database? _database;
  final String _conversationsDatabaseName = 'conversations_database.db';
  final String _conversationsTableName = 'conversations';
  final String _groupConversationsTableName = 'group_conversations';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _conversationsDatabaseName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // creating conversations table
        await db.execute('''
          CREATE TABLE $_conversationsTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversation_id INTEGER,
            conversation TEXT
          )
        ''');

        // creating group conversations table
        await db.execute('''
          CREATE TABLE $_groupConversationsTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            group_name TEXT,
            conversation TEXT
          )
        ''');
      },
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  ///////////////////  Conversations List Methods //////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Future<void> insertConversations(
      List<ConversationEntity> conversations) async {
    if (conversations.isEmpty) {
      return;
    }
    final db = await database;
    final batch = db.batch();
    for (final conversation in conversations) {
      batch.insert(_conversationsTableName, {
        'conversation_id': conversation.id,
        'conversation': jsonEncode(conversation.toJson())
      });
    }

    await batch.commit();
  }

  Future<List<ConversationEntity>> getAllConversations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(_conversationsTableName, orderBy: 'id ASC');

    final conversations = List.generate(maps.length, (i) {
      return ConversationModel.fromJson(jsonDecode(maps[i]['conversation']));
    });

    return conversations;
  }

  Future<int> deleteAllConversation() async {
    final db = await database;
    return await db.delete(
      _conversationsTableName,
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  ///////////////////  Group Conversations List Methods ////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Future<void> insertGroupConversations(
      List<GroupConversationEntity> groupConversations) async {
    if (groupConversations.isEmpty) {
      return;
    }
    final db = await database;
    final batch = db.batch();
    for (final conversation in groupConversations) {
      batch.insert(_groupConversationsTableName, {
        'group_name': conversation.name,
        'conversation': jsonEncode(conversation.toJson())
      });
    }

    await batch.commit();
  }

  Future<List<GroupConversationEntity>> getAllGroupConversations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(_groupConversationsTableName, orderBy: 'id ASC');

    final groupConversations = List.generate(maps.length, (i) {
      return GroupConversationModel.fromJson(
          jsonDecode(maps[i]['conversation']));
    });

    return groupConversations;
  }

  Future<int> deleteAllGroupConversation() async {
    final db = await database;
    return await db.delete(
      _groupConversationsTableName,
    );
  }
}
