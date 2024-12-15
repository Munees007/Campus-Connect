import 'package:flutter/material.dart';

class InputComponent extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final String preficIconPath;
  const InputComponent(
      {super.key,
      required this.hint,
      required this.isPassword,
      required this.controller,
      required this.preficIconPath});

  @override
  State<InputComponent> createState() => _InputComponentState();
}

class _InputComponentState extends State<InputComponent> {
  late bool _obscureText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _obscureText = widget.isPassword;
    //textEditingController = widget.controller;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: TextFormField(
        obscureText: _obscureText,
        controller: widget.controller,
        cursorColor: Colors.black,
        decoration: InputDecoration(
            prefixIcon: Image.asset(
              widget.preficIconPath,
            ),
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
            contentPadding: const EdgeInsets.all(15),
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
