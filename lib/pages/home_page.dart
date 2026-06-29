import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../repository/task_repository.dart';
import 'task_detail_page.dart';
import 'task_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskRepository _repository = TaskRepository();
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (kIsWeb) {
      setState(() {
        _tasks = [];
        _isLoading = false;
        _errorMessage =
            'Este app usa SQLite com sqflite. Para salvar e listar tarefas, '
            'rode em Windows, Android ou iOS. No Chrome/Web o sqflite nao '
            'abre banco local.';
      });
      return;
    }

    try {
      final tasks = await _repository.getAllTasks();

      if (!mounted) {
        return;
      }

      setState(() {
        _tasks = tasks;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _tasks = [];
        _isLoading = false;
        _errorMessage = 'Erro ao carregar tarefas: $error';
      });
    }
  }

  Future<void> _openFormPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TaskFormPage()),
    );

    await _loadTasks();
  }

  Future<void> _openDetailPage(TaskModel task) async {
    if (task.id == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(taskId: task.id!),
      ),
    );

    await _loadTasks();
  }

  String _statusText(TaskModel task) {
    return task.isDone ? 'Concluida' : 'Pendente';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Tarefas')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFormPage,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tasks.isEmpty) {
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
        child: Text('Nenhuma tarefa cadastrada.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final task = _tasks[index];

          return Card(
            child: ListTile(
              leading: Icon(
                task.isDone ? Icons.check_circle : Icons.pending_actions,
                color: task.isDone ? Colors.green : Colors.orange,
              ),
              title: Text(task.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('Status: ${_statusText(task)}'),
                ],
              ),
              onTap: () => _openDetailPage(task),
            ),
          );
        },
      ),
    );
  }
}
