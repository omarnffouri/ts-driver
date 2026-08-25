import 'package:flutter/material.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/reaction_components/model/reactions_menu_item.dart';

class ReactionsData {
// default list of five reactions to be displayed from emojis and a plus icon at the end
// the plus icon will be used to add more reactions
  static const List<String> reactions = [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '😠',
    '➕',
  ];
  // The default list of menuItems
  static const List<ReactionsMenuItem> menuItems = [
    reply,
    copy,
    edit,
    forward,
    delete,
  ];

  // defaul reply menu item
  static const ReactionsMenuItem reply = ReactionsMenuItem(
    id: 1,
    label: 'Reply',
    icon: Icons.reply,
  );

  // default copy menu item
  static const ReactionsMenuItem copy = ReactionsMenuItem(
    id: 2,
    label: 'Copy',
    icon: Icons.copy_rounded,
  );

  // default delete menu item
  static const ReactionsMenuItem delete = ReactionsMenuItem(
    id: 3,
    label: 'Delete',
    icon: Icons.delete_forever_rounded,
    isDestuctive: true,
  );

  // default edit menu item
  static const ReactionsMenuItem edit = ReactionsMenuItem(
    id: 4,
    label: 'Edit',
    icon: Icons.edit_rounded,
  );

  // default forward menu item
  static const ReactionsMenuItem forward = ReactionsMenuItem(
    id: 5,
    label: 'Forward',
    icon: Icons.forward_rounded,
  );
}
