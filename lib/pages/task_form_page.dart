import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../repository/task_repository.dart';

class TaskFormPage extends StatefulWidget {
  final TaskModel? task;

  const TaskFormPage({super.key, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TaskRepository _repository = TaskRepository();

  bool _isDone = false;
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    final task = widget.task;
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _isDone = task.isDone;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O sqflite nao salva no Chrome/Web. Rode em Windows, Android ou iOS.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    try {
      if (_isEditing) {
        final updatedTask = widget.task!.copyWith(
          title: title,
          description: description,
          isDone: _isDone,
        );

        await _repository.updateTask(updatedTask);
      } else {
        final newTask = TaskModel(
          title: title,
          description: description,
          isDone: _isDone,
          createdAt: DateTime.now().toIso8601String(),
        );

        await _repository.insertTask(newTask);
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar tarefa: $error')),
      );
    }
  }

  String? _requiredFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar tarefa' : 'Nova tarefa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titulo',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: _requiredFieldValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descricao',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: _requiredFieldValidator,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tarefa concluida'),
                value: _isDone,
                onChanged: (value) {
                  setState(() {
                    _isDone = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveTask,
                  icon: const Icon(Icons.save),
                  label: Text(_isSaving ? 'Salvando...' : 'Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
