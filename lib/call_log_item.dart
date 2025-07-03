import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';

class CallLogItem extends StatelessWidget {
  final CallLogEntry log;
  final VoidCallback onTap;
  final bool isSearching;
  final Color accentColor;

  const CallLogItem({
    super.key,
    required this.log,
    required this.onTap,
    required this.isSearching,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = log.name?.isNotEmpty == true ? log.name : log.number ?? 'Unknown';
    final number = log.number ?? 'Unknown';
    final date = log.timestamp != null
        ? DateFormat('MMM d, h:mm a').format(DateTime.fromMillisecondsSinceEpoch(log.timestamp!))
        : 'Unknown';
    final type = log.callType == CallType.incoming
        ? 'Incoming'
        : log.callType == CallType.outgoing
        ? 'Outgoing'
        : 'Missed';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: type == 'Incoming'
              ? Colors.green
              : type == 'Outgoing'
              ? accentColor
              : Colors.red,
          child: Icon(
            type == 'Incoming'
                ? Icons.call_received
                : type == 'Outgoing'
                ? Icons.call_made
                : Icons.call_missed,
            color: Colors.white,
            size: 18,
          ),
        ),
        title: Text(displayName!, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text('$date • $type', style: Theme.of(context).textTheme.bodyMedium),
        trailing: isSearching
            ? CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
        )
            : ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Check', style: TextStyle(fontFamily: 'Poppins')),
        ),
        onTap: onTap,
      ),
    );
  }
}