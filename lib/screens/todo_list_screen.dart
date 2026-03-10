import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../widgets/todo_item_widget.dart';

enum TodoFilter { all, incomplete, completed }

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [];
  TodoFilter _currentFilter = TodoFilter.all;

  List<Todo> get _filteredTodos {
    switch (_currentFilter) {
      case TodoFilter.incomplete:
        return _todos.where((t) => !t.isCompleted).toList();
      case TodoFilter.completed:
        return _todos.where((t) => t.isCompleted).toList();
      case TodoFilter.all:
        return _todos;
    }
  }

  void _addTodo(String title) {
    setState(() {
      _todos.insert(0, Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
      ));
    });
  }

  void _editTodo(String id, String newTitle) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index].title = newTitle;
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
  }

  void _toggleTodoStatus(String id, bool? status) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index].isCompleted = status ?? false;
      }
    });
  }

  void _showTodoDialog({Todo? todoToEdit}) {
    final TextEditingController controller = TextEditingController(
      text: todoToEdit?.title ?? '',
    );

    void submit() {
      final text = controller.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Nội dung không được rỗng!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (todoToEdit == null) {
        _addTodo(text);
      } else {
        _editTodo(todoToEdit.id, text);
      }
      Navigator.pop(context);
      
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(todoToEdit == null ? '✓ Thêm công việc thành công!' : '✓ Cập nhật công việc thành công!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(todoToEdit == null ? 'Thêm công việc' : 'Sửa công việc'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung công việc...',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.task_alt),
                ),
                autofocus: true,
                maxLines: null,
                onSubmitted: (value) {
                  submit();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: submit,
              child: Text(todoToEdit == null ? 'Thêm' : 'Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _deleteTodo(todo.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App Hoàn Chỉnh'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SegmentedButton<TodoFilter>(
              segments: const [
                ButtonSegment(
                  value: TodoFilter.all,
                  label: Text('Tất cả'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment(
                  value: TodoFilter.incomplete,
                  label: Text('Chưa xong'),
                  icon: Icon(Icons.radio_button_unchecked),
                ),
                ButtonSegment(
                  value: TodoFilter.completed,
                  label: Text('Đã xong'),
                  icon: Icon(Icons.check_circle_outline),
                ),
              ],
              selected: {_currentFilter},
              onSelectionChanged: (Set<TodoFilter> newSelection) {
                setState(() {
                  _currentFilter = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
      body: _filteredTodos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có công việc nào!\nHãy nhấn + để thêm.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: _filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = _filteredTodos[index];
                return TodoItemWidget(
                  todo: todo,
                  onChanged: (val) => _toggleTodoStatus(todo.id, val),
                  onEdit: () => _showTodoDialog(todoToEdit: todo),
                  onDelete: () => _confirmDelete(todo),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTodoDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm Task'),
      ),
    );
  }
}
