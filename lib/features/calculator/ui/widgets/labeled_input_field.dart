import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/tokens.dart';
import '../../../../core/validation.dart';
import '../../../../core/validation_l10n.dart';

class LabeledInputField extends StatefulWidget {
  final String label;
  final String unit;
  final String initialValue;
  // Accepts a typed ValidationError? — localized to a string inside build().
  final ValidationError? error;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;

  const LabeledInputField({
    super.key,
    required this.label,
    required this.unit,
    required this.initialValue,
    required this.onChanged,
    this.error,
    this.keyboardType =
        const TextInputType.numberWithOptions(decimal: true, signed: true),
  });

  @override
  State<LabeledInputField> createState() => _LabeledInputFieldState();
}

class _LabeledInputFieldState extends State<LabeledInputField> {
  late TextEditingController _ctrl;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl  = TextEditingController(text: widget.initialValue);
    _focus = FocusNode();
  }

  @override
  void didUpdateWidget(covariant LabeledInputField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && _ctrl.text != widget.initialValue) {
      _ctrl.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError  = widget.error != null;
    final errorText = hasError ? widget.error!.localize(context) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.fieldGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: AppText.inputLabel),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode:  _focus,
                  keyboardType: widget.keyboardType,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^-?\d*[.,]?\d*$'),
                    ),
                  ],
                  onChanged: widget.onChanged,
                  style: AppText.inputValue,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical:   AppSpacing.inputPadV,
                    ),
                    filled:    true,
                    fillColor: AppColors.surface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadii.mdAll,
                      borderSide: BorderSide(
                        color: hasError ? AppColors.danger : AppColors.border,
                        width: 0.75,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadii.mdAll,
                      borderSide: BorderSide(
                        color: AppColors.borderFocus,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderRadius: AppRadii.mdAll,
                      borderSide: BorderSide(
                        color: AppColors.danger,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderRadius: AppRadii.mdAll,
                      borderSide: BorderSide(
                        color: AppColors.danger,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 48,
                child: Text(
                  widget.unit,
                  style: AppText.inputUnit,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          if (hasError) ...[
            const SizedBox(height: 3),
            Text(
              errorText!,
              style: AppText.sectionLabel.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }
}
