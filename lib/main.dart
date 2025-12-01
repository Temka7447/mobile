import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color? selectedColor;

  final List<DropdownMenuEntry<Color>> colorItems = [
    DropdownMenuEntry(value: Colors.red, label: 'Red'),
    DropdownMenuEntry(value: Colors.blue, label: 'Blue'),
    DropdownMenuEntry(value: Colors.purple, label: 'Purple'),
    DropdownMenuEntry(value: Colors.green, label: 'Green'),
    DropdownMenuEntry(value: Colors.brown, label: 'Brown'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DropdownMenu Color Example")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Өнгө сонгох:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            DropdownMenu<Color>(
              width: 300,
              label: const Text("Өнгө сонгох"),
              initialSelection: selectedColor,
              dropdownMenuEntries: colorItems,
              enableSearch: true,
              enableFilter: true,
              onSelected: (Color? color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Text("Сонгосон өнгө: ", style: TextStyle(fontSize: 16)),
                Container(
                  width: 24,
                  height: 24,
                  color: selectedColor ?? Colors.transparent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
