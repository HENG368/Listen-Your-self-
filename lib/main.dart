import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const ListenYourSelfApp());
}

class ListenYourSelfApp extends StatelessWidget {
  const ListenYourSelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listen Yourself',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
    );
  }
}

enum OrderMode { normal, reverse, shuffle }

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<String> _songs = <String>[
    'Blooming Day',
    'Lunar Echoes',
    'Night Drive',
    'Soft Horizon',
    'Silver Rain',
  ];

  OrderMode _currentMode = OrderMode.normal;

  List<String> get _orderedSongs {
    final List<String> ordered = List<String>.from(_songs);

    switch (_currentMode) {
      case OrderMode.normal:
        return ordered;
      case OrderMode.reverse:
        return ordered.reversed.toList();
      case OrderMode.shuffle:
        final Random random = Random(7);
        ordered.shuffle(random);
        return ordered;
    }
  }

  String get _modeLabel {
    switch (_currentMode) {
      case OrderMode.normal:
        return 'Normal';
      case OrderMode.reverse:
        return 'Reverse';
      case OrderMode.shuffle:
        return 'Shuffle';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> visibleSongs = _orderedSongs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listen Yourself'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Music Queue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order Mode: $_modeLabel',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<OrderMode>(
                      showSelectedIcon: false,
                      selected: <OrderMode>{_currentMode},
                      onSelectionChanged: (Set<OrderMode> value) {
                        setState(() {
                          _currentMode = value.first;
                        });
                      },
                      segments: const <ButtonSegment<OrderMode>>[
                        ButtonSegment<OrderMode>(
                          value: OrderMode.normal,
                          label: Text('Normal'),
                        ),
                        ButtonSegment<OrderMode>(
                          value: OrderMode.reverse,
                          label: Text('Reverse'),
                        ),
                        ButtonSegment<OrderMode>(
                          value: OrderMode.shuffle,
                          label: Text('Shuffle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: visibleSongs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final String song = visibleSongs[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(song),
                        subtitle: Text('Tap to play'),
                        trailing: const Icon(Icons.play_arrow_rounded),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
