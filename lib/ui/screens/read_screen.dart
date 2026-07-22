import 'package:flutter/material.dart';

class ReadScreen extends StatelessWidget {
  const ReadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Read'),
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'Read Screen Placeholder',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
