import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A Counter example implemented with riverpod

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier(this.ref) : super(0);

  final Ref ref;

  Future<void> increment() async {
    state++;
  }

  Future<void> decrement() async {
    state--;
  }
}

final counterStateProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier(ref);
});

void main() {
  runApp(
    // Adding ProviderScope enables Riverpod for the entire project
    const ProviderScope(child: RiverpodCounterApp()),
  );
}

class RiverpodCounterApp extends StatelessWidget {
  const RiverpodCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CounterScreen());
  }
}

class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Counter example')),
      body: Center(
        child: Text(
          '$count',
          style: const TextStyle(fontSize: 32.0),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            key: const Key('counterView_increment_floatingActionButton'),
            child: const Icon(Icons.add),
            onPressed: () =>
                ref.read(counterStateProvider.notifier).increment(),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            key: const Key('counterView_decrement_floatingActionButton'),
            child: const Icon(Icons.remove),
            onPressed: () =>
                ref.read(counterStateProvider.notifier).decrement(),
          ),
        ],
      ),
    );
  }
}
