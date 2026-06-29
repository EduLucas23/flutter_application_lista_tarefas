import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../repository/task_repository.dart';
import 'task_form_page.dart';

class TaskDetailPage extends StatefulWidget {
  final int taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TaskRepository _repository = TaskRepository();
  TaskModel? _task;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    try {
      final task = await _repository.getTaskById(widget.taskId);

      if (!mounted) {
        return;
      }

      setState(() {
        _task = task;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _task = null;
        _isLoading = false;
        _errorMessage = 'Erro ao carregar tarefa: $error';
      });
    }
  }

  Future<void> _editTask() async {
    final task = _task;
    if (task == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormPage(task: task),
      ),
    );

    await _loadTask();
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir tarefa'),
          content: const Text('Tem certeza que deseja excluir esta tarefa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await _repository.deleteTask(widget.taskId);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  String _statusText(TaskModel task) {
    return task.isDone ? 'Concluida' : 'Pendente';
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da tarefa'),
        actions: [
          if (task != null)
            IconButton(
              onPressed: _editTask,
              icon: const Icon(Icons.edit),
              tooltip: 'Editar',
            ),
        ],
      ),
      body: _buildBody(task),
    );
  }

  Widget _buildBody(TaskModel? task) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (task == null) {
      if (_errorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      return const Center(
        child: Text('Tarefa nao encontrada.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          task.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _InfoRow(label: 'Descricao', value: task.description),
        _InfoRow(label: 'Status', value: _statusText(task)),
        _InfoRow(label: 'Criada em', value: _formatDate(task.createdAt)),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _editTask,
          icon: const Icon(Icons.edit),
          label: const Text('Editar'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _confirmDelete,
          icon: const Icon(Icons.delete),
          label: const Text('Excluir'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
