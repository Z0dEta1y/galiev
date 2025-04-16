import 'package:flutter/material.dart';

class ServicesBubbleSmall extends StatefulWidget {
  final IconData icon;
  final String text;
  final Function() onClicked;
  const ServicesBubbleSmall({
    required this.icon,
    required this.text,
    required this.onClicked,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ServicesBubbleSmall();
}

class _ServicesBubbleSmall extends State<ServicesBubbleSmall> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 6, right: 6),
          child: ElevatedButton(
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              surfaceTintColor:
                  const WidgetStatePropertyAll(Colors.transparent),
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            onPressed: () {
              widget.onClicked();
            },
            child: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    widget.text,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
