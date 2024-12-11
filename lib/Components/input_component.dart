import 'package:flutter/material.dart';

class InputComponent extends StatefulWidget {
  final String hint;
  final bool isPassword;
  const InputComponent(
      {super.key, required this.hint, required this.isPassword});

  @override
  State<InputComponent> createState() => _InputComponentState();
}

class _InputComponentState extends State<InputComponent> {
  late TextEditingController textEditingController;
  bool _obscureText = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: TextFormField(
        obscureText: _obscureText,
        controller: textEditingController,
        cursorColor: Colors.black,
        decoration: InputDecoration(
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => {
                      setState(() {
                        _obscureText = !_obscureText;
                      })
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(50),
            ),
            contentPadding: const EdgeInsets.all(20),
            alignLabelWithHint: true,
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
            hintText: widget.hint),
      ),
    );
  }
}
