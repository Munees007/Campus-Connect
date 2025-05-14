import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final List<String> options;
  final String hintText;
  final IconData icon;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
    this.hintText = "Select an option",
    this.icon = Icons.arrow_drop_down, // Default icon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: DropdownButtonFormField(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(50),
          ),
          contentPadding: const EdgeInsets.all(5),
          focusedBorder: OutlineInputBorder(
            gapPadding: 10,
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(50),
          ),
          enabledBorder: OutlineInputBorder(
            gapPadding: 10,
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        hint: Text(hintText),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }
}
