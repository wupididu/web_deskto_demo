import 'package:flutter/material.dart';

PreferredSizeWidget appBar(BuildContext context, bool isNew) => AppBar(
  title: Text(isNew ? 'Create Todo' : 'Edit Todo'),
  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
);
