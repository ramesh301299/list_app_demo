

// lib/list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:list_app/api_providers.dart';
import 'package:list_app/searchable_dropdown.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicInfoProvider);
    final notifier = ref.read(basicInfoProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Info'),
        actions: [
          if (state.error != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (state.selectedType != null) {
                  notifier.setTypeAndFetch(state.selectedType!);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SearchableDropdown(),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: notifier.clearAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Clear All'),
            ),

            const SizedBox(height: 20),

            if (state.isLoading && state.data.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading data...'),
                    ],
                  ),
                ),
              )
            else if (state.error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (state.selectedType != null) {
                            notifier.setTypeAndFetch(state.selectedType!);
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: state.data.length,
                  itemBuilder: (context, index) {
                    final item = state.data[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.id.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(item.status),

                      // Add more fields as necessary
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}