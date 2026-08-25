import 'dart:convert';

import 'package:ts_driver/app/modules/chat/data/models/presence_data_model.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/presence_added_entity.dart';

PresenceUserAddedModel presenceUserAddedModelFromJson(String str) =>
    PresenceUserAddedModel.fromJson(json.decode(str));

String presenceUserAddedModelToJson(PresenceUserAddedModel data) =>
    json.encode(data.toJson());

class PresenceUserAddedModel extends PresenceUserAddedEntity {
  const PresenceUserAddedModel({
    super.userId,
    super.user,
  });

  factory PresenceUserAddedModel.fromJson(Map<String, dynamic> json) =>
      PresenceUserAddedModel(
        userId: json["user_id"],
        user: json["user_info"] == null
            ? null
            : PresenceUserModel.fromJson(json["user_info"]),
      );

  @override
  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "user_info": user?.toJson(),
      };
}
