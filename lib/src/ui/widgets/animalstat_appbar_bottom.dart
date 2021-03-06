import 'package:flutter/material.dart';

import '../theming.dart';

class AnimalstatAppBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget child;

  const AnimalstatAppBarBottom({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 79.0,
      width: MediaQuery.of(context).size.width,
      color: kAccentColor,
      child: child,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(79.0);
}
