import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/todo_controller.dart';
import '../../models/todo_model.dart';
import 'package:intl/intl.dart';

class AddEditTodoScreen extends StatefulWidget {
  final TodoModel? existingTodo;
  const AddEditTodoScreen({super.key, this.existingTodo});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final TodoController _todoController = Get.find<TodoController>();

  int _selectedPriority = 2; // শুরুতে মাঝারি priority
  String? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingTodo != null) {
      _titleController.text = widget.existingTodo!.title;
      _descController.text = widget.existingTodo!.description;
      _selectedPriority = widget.existingTodo!.priority;
      _selectedDueDate = widget.existingTodo!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Date picker দেখাও
  Future<void> _pickDate() async {
    // showDatePicker — Flutter এর built-in date picker dialog
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // আজকের আগে select করা যাবে না
      lastDate: DateTime(2099),
    );

    if (picked != null) {
      setState(() {
        // DateFormat দিয়ে সুন্দরভাবে format করো
        _selectedDueDate = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.existingTodo == null) {
      await _todoController.addTodo(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
    } else {
      await _todoController.updateTodo(
        todo: widget.existingTodo!,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingTodo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Task সম্পাদনা' : 'নতুন Task'),
        actions: [
          IconButton(icon: const Icon(Icons.save_outlined), onPressed: _saveTodo),
        ],
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task এর শিরোনাম',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.task_alt),
                ),
                validator: (v) => v!.trim().isEmpty ? 'শিরোনাম দিন' : null,
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'বিবরণ (ঐচ্ছিক)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              // Priority selection
              const Text('গুরুত্ব:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              // SegmentedButton — Flutter এর built-in grouped button
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('জরুরি'), icon: Icon(Icons.priority_high)),
                  ButtonSegment(value: 2, label: Text('মাঝারি'), icon: Icon(Icons.remove)),
                  ButtonSegment(value: 3, label: Text('কম'), icon: Icon(Icons.low_priority)),
                ],
                selected: {_selectedPriority}, // Set এ রাখতে হয়
                onSelectionChanged: (newSet) {
                  setState(() => _selectedPriority = newSet.first);
                },
              ),

              const SizedBox(height: 20),

              // Due date picker
              const Text('শেষ তারিখ:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_selectedDueDate ?? 'তারিখ বেছে নিন'),
                    ),
                  ),
                  if (_selectedDueDate != null)
                    IconButton(
                      // X বাটন — date সরাও
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _selectedDueDate = null),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveTodo,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'আপডেট করুন' : 'সংরক্ষণ করুন'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}