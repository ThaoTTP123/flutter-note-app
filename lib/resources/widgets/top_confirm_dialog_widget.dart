import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

typedef ConfirmCallback = Future<void> Function();

class TopConfirmDialog extends StatelessWidget {
  final String message;
  final String confirmText;
  final String cancelText;
  final ConfirmCallback? onConfirm;
  final VoidCallback? onCancel;

  const TopConfirmDialog({
    super.key,
    this.message = "Are you sure?",
    this.confirmText = "Delete",
    this.cancelText = "Cancel",
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 67, 65, 65)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.9),
        //     blurRadius: 8,
        //     offset: const Offset(0, 4),
        //   )
        // ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  onCancel?.call();
                },
                child: Text(
                  cancelText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 12,
                color: Colors.grey, // divider color
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  await onConfirm?.call();
                },
                child: Text(
                  confirmText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
