import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/top_confirm_dialog_widget.dart';

Future<void> showTopConfirmDialog(
  BuildContext context, {
  String title = "Confirm",
  String message = "Are you sure?",
  String confirmText = "Delete",
  String cancelText = "Cancel",
  required ConfirmCallback onConfirm,
}) async {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  late OverlayEntry entry;

  final animationController = AnimationController(
    vsync: Navigator.of(context),
    duration: const Duration(milliseconds: 300),
  );

  final animation = Tween<Offset>(
    begin: const Offset(0, -1), // start above the screen
    end: Offset.zero, // final position
  ).animate(CurvedAnimation(
    parent: animationController,
    curve: Curves.easeOut,
  ));

  entry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        // Semi-transparent dark overlay
        GestureDetector(
          onTap: () async {
            await animationController.reverse();
            entry.remove();
            animationController.dispose();
          },
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),

        // Sliding top dialog
        Positioned(
          top: 50,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: animation,
              child: TopConfirmDialog(
                message: message,
                confirmText: confirmText,
                cancelText: cancelText,
                onConfirm: () async {
                  await onConfirm();
                  await animationController.reverse();
                  entry.remove();
                  animationController.dispose();
                },
                onCancel: () async {
                  await animationController.reverse();
                  entry.remove();
                  animationController.dispose();
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(entry);
  await animationController.forward(); // animate in
}
