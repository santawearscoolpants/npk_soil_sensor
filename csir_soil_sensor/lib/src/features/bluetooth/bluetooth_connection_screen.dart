import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/bluetooth_service.dart';

class BluetoothConnectionScreen extends ConsumerWidget {
  const BluetoothConnectionScreen({super.key});

  Future<void> _handleDisconnect(
    BuildContext context,
    WidgetRef ref,
    int pendingCount,
  ) async {
    if (pendingCount > 0) {
      // Show dialog to save or discard pending readings
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Readings'),
          content: Text(
            'You have $pendingCount unsaved readings. What would you like to do?',
          ),
          actions: [
             
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: const Text('Go Back'),
            ),
            SizedBox(height: 10,),
            
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop('discard'),
              child: const Text('Discard Unsaved Readings', style: TextStyle(color: Colors.white),),
            ),
            SizedBox(height: 10,),

            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('save'),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (result == null || result == 'cancel') {
        return; // User cancelled, don't disconnect
      }

      if (result == 'save') {
        // Save the readings first
        final session = await ref
            .read(bluetoothServiceProvider.notifier)
            .savePendingReadings();
        if (context.mounted) {
          final count = session?.readingIds.length ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Saved $count readings as session #${session?.id ?? ''}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (result == 'discard') {
        // Discard the readings
        ref.read(bluetoothServiceProvider.notifier).discardPendingReadings();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Discarded unsaved readings'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }

    // Now disconnect
    ref.read(bluetoothServiceProvider.notifier).disconnect();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleState = ref.watch(bluetoothServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Connection'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status indicator
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bleState.connectionStatus == 'Connected' &&
                                  bleState.connectedDeviceName != null
                              ? Colors.green
                              : bleState.connectionStatus.startsWith('Scanning') ||
                                      bleState.connectionStatus
                                          .startsWith('Connecting')
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connection Status',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bleState.connectedDeviceName != null
                                  ? '${bleState.connectionStatus} (${bleState.connectedDeviceName})'
                                  : bleState.connectionStatus,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Scan button
              ElevatedButton.icon(
                onPressed: bleState.connectionStatus.startsWith('Scanning')
                    ? null
                    : () {
                        ref
                            .read(bluetoothServiceProvider.notifier)
                            .scanForDevices();
                      },
                icon: bleState.connectionStatus.startsWith('Scanning')
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.bluetooth_searching),
                label: Text(
                  bleState.connectionStatus.startsWith('Scanning')
                      ? 'Scanning...'
                      : 'Scan for devices',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              // Device list
              if (bleState.connectedDeviceName == null &&
                  bleState.devices.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Available Devices',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bleState.devices.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final d = bleState.devices[index];
                      return ListTile(
                        leading: const Icon(Icons.bluetooth, color: Colors.blue),
                        title: Text(
                          d.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          d.device.remoteId.str,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ref
                              .read(bluetoothServiceProvider.notifier)
                              .connectToDevice(d);
                        },
                      );
                    },
                  ),
                ),
              ],
              
              // Disconnect button
              if (bleState.connectionStatus == 'Connected' &&
                  bleState.connectedDeviceName != null) ...[
                if (bleState.pendingCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${bleState.pendingCount} unsaved reading${bleState.pendingCount == 1 ? '' : 's'}',
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade700),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    _handleDisconnect(context, ref, bleState.pendingCount);
                  },
                  icon: const Icon(Icons.link_off),
                  label: const Text('Disconnect from device'),
                ),
              ],
              
              // Empty state message - only show when disconnected and no devices
              if (bleState.connectionStatus == 'Disconnected' &&
                  bleState.connectedDeviceName == null &&
                  bleState.devices.isEmpty) ...[
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.bluetooth_disabled,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Not connected',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "Scan for devices" to search for your ESP32',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              
              // Show message after scan completes with no devices
              if (bleState.connectionStatus == 'No BLE devices found. Make sure the ESP32 is powered and advertising.' ||
                  (bleState.connectionStatus == 'Tap a device to connect' && bleState.devices.isEmpty)) ...[
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.bluetooth_searching,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        bleState.connectionStatus,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

