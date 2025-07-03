import 'package:flutter/material.dart';

class SearchBarA extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final bool isLoading;
  final Color accentColor;

  const SearchBarA({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.isLoading,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search phone number',
                hintStyle: const TextStyle(fontFamily: 'Poppins'),
                suffixIcon: isLoading
                    ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                )
                    : const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontFamily: 'Poppins'),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isLoading ? null : onSearch,
            child: const Text('Search', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}