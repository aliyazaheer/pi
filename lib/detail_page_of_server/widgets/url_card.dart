import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/server_details.dart';

class urlCard extends StatelessWidget {
  const urlCard({
    super.key,
    required this.serverDetails,
  });

  final ServerDetails? serverDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF222832)
          : const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.link),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    serverDetails?.serverUrl ?? 'N/A',
                    style: const TextStyle(color: Color(0xFF41A3FF)),
                  ),
                ),
                // const Spacer(),
                IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                              text:
                                  'https://${serverDetails!.serverUrl}/rms/v1/serverHealth'))
                          .then((_) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                            'Copied to Clipboard',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Color(0xFF41A3FF),
                        ));
                      });
                    },
                    icon: const Icon(Icons.copy))
              ],
            )
          ],
        ),
      ),
    );
  }
}
