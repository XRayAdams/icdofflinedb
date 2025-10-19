import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../about_dialog.dart';

class AboutButton extends StatefulWidget {
  const AboutButton({super.key});

  @override
  State<AboutButton> createState() => _AboutButtonState();
}

class _AboutButtonState extends State<AboutButton> {
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      // Define the menu content within menuChildren
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            showDialog(context: context, builder: (context) => const CustomAboutDialog());
          },
          child: const Text('About...'),
        ),
      ],
      // Use a Builder to get the correct context for the MenuController
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return YaruOptionButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: const Icon(YaruIcons.menu),
        );
      },
    );
    return YaruOptionButton(
      child: const Icon(YaruIcons.menu),
      onPressed: () {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx + renderBox.size.width,
            offset.dy + 40,
            offset.dx + renderBox.size.width,
            offset.dy,
          ),
          items: [const PopupMenuItem(value: "about", child: Text("About..."))],
        ).then((value) {
          if (value == "about") {
            showDialog(context: context, builder: (context) => const CustomAboutDialog());
          }
        });
      },
    );
  }
}
