# Lista de Tarefas

Aplicativo Flutter simples para cadastro de tarefas com CRUD local usando SQLite.

## Recursos

- Criar tarefa
- Listar tarefas
- Ver detalhes por ID
- Editar tarefa
- Excluir tarefa com confirmacao
- Persistir dados em banco SQLite local

## Dependencias principais

- sqflite
- sqflite_common_ffi
- sqlite3_flutter_libs
- path

## Como executar

Para testar com SQLite no Windows:

```bash
flutter pub get
flutter run -d windows
```

O Flutter Web/Chrome nao salva usando sqflite. Para testar persistencia local,
use Windows, Android ou iOS.
