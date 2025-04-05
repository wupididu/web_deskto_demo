import 'package:flutter/material.dart';
import 'package:web_desktop_demo/presentation/screens/todo_edit/widgets/app_bar.dart';
import 'package:web_desktop_demo/presentation/screens/todo_edit/widgets/edit_form.dart';

import '../../home/widgets/stats_widget.dart';

class DesktopTodoEditScreen extends StatelessWidget {
  final bool isNew;
  final bool isCompleted;
  final ValueChanged<bool?> toggle;
  final void Function() onSave;
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const DesktopTodoEditScreen({
    super.key,
    required this.isNew,
    required this.isCompleted,
    required this.toggle,
    required this.onSave,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, isNew),
      body: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(flex: 1, child: StatsWidget()),
          Flexible(
            flex: 2,
            child: EditForm(
              isNew: isNew,
              isCompleted: isCompleted,
              toggle: toggle,
              onSave: onSave,
              formKey: formKey,
              titleController: titleController,
              descriptionController: descriptionController,
            ),
          ),
        ],
      ),
    );
  }
}
