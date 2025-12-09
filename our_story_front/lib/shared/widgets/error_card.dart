import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget {
  final VoidCallback onPressed; 
  final Object error;

  const ErrorCard({
    super.key,
    required this.onPressed,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $error'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPressed,
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}


