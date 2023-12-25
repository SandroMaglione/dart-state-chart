import 'package:example/machine_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_machine/flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Machine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: MachineProvider(
          create: (_) => SemaphoreMachine(),
          child: MachineBuilder<SemaphoreMachine, int, SemaphoreState>(
            builder: (context, ctx, state) => Column(
              children: [
                Text("State: $state"),
                Text("Context: $ctx"),
                ElevatedButton(
                  onPressed: () => context
                      .read<SemaphoreMachine>()
                      .add(SemaphoreEvent.green),
                  child: const Text("To Green"),
                ),
                ElevatedButton(
                  onPressed: () => context
                      .read<SemaphoreMachine>()
                      .add(SemaphoreEvent.yellow),
                  child: const Text("To Yellow"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      context.read<SemaphoreMachine>().add(SemaphoreEvent.red),
                  child: const Text("To Red"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
