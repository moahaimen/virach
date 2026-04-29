import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/core/providers/data.dart';
import 'package:racheeta/di/dependency_ingection.dart';

class ExamplesTesting extends StatefulWidget {
  const ExamplesTesting({super.key});

  @override
  State<ExamplesTesting> createState() => _ExamplesTestingState();
}

class _ExamplesTestingState extends State<ExamplesTesting> {
  @override
  void initState() {
    locator<ProviderTesing>().getAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<ProviderTesing>(builder: (_, data, __) {
      return data.data_come == false
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.data.length,
              itemBuilder: (context, index) {
                return Text(data.data[index].body!);
              });
    }));
  }
}
