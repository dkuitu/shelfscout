import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/validation.dart';
import '../../providers/validation_provider.dart';

class ValidationQueueScreen extends StatefulWidget {
  const ValidationQueueScreen({super.key});

  @override
  State<ValidationQueueScreen> createState() => _ValidationQueueScreenState();
}

class _ValidationQueueScreenState extends State<ValidationQueueScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ValidationProvider>().loadQueue());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ValidationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validate Prices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ValidationProvider>().loadQueue(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<ValidationProvider>().loadQueue(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (provider.queue.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No submissions to validate right now.'),
                  SizedBox(height: 8),
                  Text('Check back later!',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.queue.length,
            itemBuilder: (context, index) {
              final item = provider.queue[index];
              return _ValidationCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  final ValidationItem item;

  const _ValidationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Item: ${item.itemId}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Store: ${item.storeId}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (item.photoUrl != null && item.photoUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.photoUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _vote(context, ValidationVote.flag),
                    icon: const Icon(Icons.flag, color: Colors.red),
                    label: const Text('Flag'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _vote(context, ValidationVote.confirm),
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _vote(BuildContext context, ValidationVote vote) async {
    final provider = context.read<ValidationProvider>();
    final success = await provider.submitVote(item.id, vote);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? (vote == ValidationVote.confirm
                ? 'Confirmed!'
                : 'Flagged!')
            : (provider.error ?? 'Vote failed')),
      ),
    );
  }
}
