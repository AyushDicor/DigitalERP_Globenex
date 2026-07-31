import 'package:flutter/material.dart';

class AccountMenu {
  Color color1, color2;
  String name;
  String pageName;

  /// Backend menu id for this tile (from Userwisemenu/usermenu). Used to
  /// decide whether the logged-in user is actually allowed to see the tile,
  /// and to route the tap — deliberately NOT the list index, because the list
  /// is filtered by access and indexes would otherwise shift and misroute.
  ///
  /// Optional because this model is shared with the MIS module grid, which is
  /// not access-filtered yet. Tiles with a null menuId are treated as
  /// "not access-controlled" and are never hidden.
  final int? menuId;

  /// Icon shown on the card. Lives on the model rather than a parallel
  /// index-keyed list, for the same reason.
  final IconData? icon;

  AccountMenu({
    required this.color1,
    required this.color2,
    required this.name,
    required this.pageName,
    this.menuId,
    this.icon,
  });
}
