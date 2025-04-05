import 'package:flutter/material.dart';

class EditForm extends StatelessWidget {
  final bool isNew;
  final bool isCompleted;
  final ValueChanged<bool?> toggle;
  final void Function() onSave;
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const EditForm({
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FocusTraversalOrder(
              order: NumericFocusOrder(0),
              child: TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton(onPressed: () {}, child: Text('test')),
            FocusTraversalOrder(
              order: NumericFocusOrder(1),
              child: TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16.0),
            if (!isNew)
              FocusTraversalOrder(
                order: NumericFocusOrder(2),
                child: Row(
                  children: [
                    Checkbox(value: isCompleted, onChanged: toggle),
                    const Text('Completed'),
                  ],
                ),
              ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: FocusTraversalOrder(
                order: NumericFocusOrder(3),
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(isNew ? 'Create' : 'Update'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
