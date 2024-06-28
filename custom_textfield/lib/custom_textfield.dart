library custom_textfield;

import 'dart:async';

import 'package:flutter/material.dart';

import 'view_model.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.obs,
    this.maxLines,
    this.canDelete,
    this.initValue,
    this.readOnly,
    this.hintText,
    this.sufWidget,
    this.prefWidget,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.textInputType,
    this.onTapClearButton,
    this.controller,
    this.contentPadding,
    this.validator,
    this.onChanged,
    this.isDebounce,
    this.debounceTime,
    this.border,
    this.disabledBorder,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
  });
  final bool? obs;
  final bool? isDebounce;
  final int? maxLines;
  final bool? canDelete;
  final Duration? debounceTime;
  final String? initValue;
  final bool? readOnly;
  final String? hintText;
  final Widget? sufWidget;
  final Widget? prefWidget;
  final Function()? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final TextInputType? textInputType;
  final Function()? onTapClearButton;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? contentPadding;
  final String? Function(String?)? validator;
  final Function(String? onChaned)? onChanged;
  final InputBorder? border;
  final InputBorder? disabledBorder;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool hasValue = false;
  Timer? timer;
  final _viewModel = TextFieldViewModel();
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    if (widget.initValue != null) {
      _controller.text = widget.initValue!;
    }
    _controller.addListener(() {
      if (_controller.text.isNotEmpty && !hasValue) {
        _viewModel.changedHasValue(true);
      }
      if (_controller.text.isEmpty && hasValue) {
        _viewModel.changedHasValue(false);
      }
    });
    super.initState();
  }

  void _onChanged(String? val) {
    timer?.cancel();
    timer = Timer(widget.debounceTime ?? const Duration(milliseconds: 500),
        () => widget.onChanged?.call(val));
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _viewModel.disposeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines ?? 1,
      obscureText: widget.obs ?? false,
      onTap: widget.onTap,
      onChanged: widget.isDebounce == true ? _onChanged : widget.onChanged,
      controller: _controller,
      validator: widget.validator,
      readOnly: widget.readOnly ?? false,
      keyboardType: widget.textInputType,
      onTapOutside: (event) {
        FocusScope.of(context).hasFocus
            ? FocusScope.of(context).unfocus()
            : null;
      },
      decoration: TextFieldProperties.getInputDecoration(
        hintText: widget.hintText,
        prefWidget: widget.prefWidget,
        borderColor: widget.borderColor,
        contentPadding: widget.contentPadding,
        backgroundColor: widget.backgroundColor,
        border: widget.border,
        focusedBorder: widget.focusedBorder,
        disabledBorder: widget.disabledBorder,
        errorBorder: widget.errorBorder,
        enabledBorder: widget.enabledBorder,
        sufWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder(
                stream: _viewModel.controllerHasValueStream,
                builder: (_, data) {
                  if (data.hasData == true && widget.canDelete == true) {
                    return _closeButton();
                  }
                  return const SizedBox();
                }),
            if (widget.sufWidget != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: widget.sufWidget!,
              ),
          ],
        ),
      ),
    );
  }

  GestureDetector _closeButton() {
    void onTapClearButton() {
      _controller.clear();
      widget.onTapClearButton?.call();
    }

    return GestureDetector(
      onTap: onTapClearButton,
      child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.black,
            size: 15,
          )),
    );
  }
}

class TextFieldProperties {
  static InputDecoration getInputDecoration({
    String? hintText,
    Color? borderColor,
    Color? backgroundColor,
    Widget? sufWidget,
    Widget? prefWidget,
    TextStyle? hintStyle,
    EdgeInsetsGeometry? contentPadding,
    InputBorder? border,
    InputBorder? disabledBorder,
    InputBorder? enabledBorder,
    InputBorder? focusedBorder,
    InputBorder? errorBorder,
  }) {
    return InputDecoration(
      filled: true,
      isDense: true,
      hintText: hintText,
      suffixIcon: sufWidget,
      prefixIcon: prefWidget,
      border: border ?? getBorder(borderColor),
      disabledBorder: disabledBorder ?? getBorder(null),
      contentPadding: contentPadding ?? const EdgeInsets.all(12),
      enabledBorder: enabledBorder ?? getBorder(borderColor),
      fillColor: backgroundColor ?? Colors.grey.shade200,
      errorBorder: errorBorder ?? getBorder(borderColor ?? Colors.red),
      focusedBorder: focusedBorder ?? getBorder(borderColor ?? Colors.black),
      hintStyle: hintStyle,
    );
  }

  static OutlineInputBorder getBorder(Color? color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 0.8, color: color ?? Colors.grey.shade300),
    );
  }
}
