import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../styles/memo_style.dart';
import '../widgets/memo_widget.dart';

class TodoItem {
  String content;
  bool isDone;

  TodoItem({required this.content, this.isDone = false});
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<TodoItem> _todos = [];
  final TextEditingController _inputController = TextEditingController();

  void _addTodo() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _todos.add(TodoItem(content: text));
      _inputController.clear();
    });
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: MemoStyle.memoBackGroundColor,
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            // 标题 + TodoList 同一卡片
            Container(
              width: screenWidth - 30,
              height: MediaQuery.of(context).size.height * 0.68,
              margin: const EdgeInsets.only(top: 50),
              decoration: MemoStyle.cardDecoration,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 37, left: 54),
                        child: const MemoBackButton(),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 37),
                        alignment: Alignment.center,
                        child: const Text(
                          'TODO',
                          style: TextStyle(
                            fontFamily: 'SourceHanSans',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(46, 46, 46, 1),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 80,
                          left: 51,
                          right: 51,
                          bottom: 8,
                        ),
                        child: const Divider(
                          height: 1,
                          color: Color.fromRGBO(200, 200, 200, 1),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  // Todo 列表
                  Expanded(
                    child: _todos.isEmpty
                        ? const Center(
                            child: Text(
                              '暂无待办事项',
                              style: TextStyle(
                                fontFamily: 'SourceHanSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(130, 130, 130, 1),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            itemCount: _todos.length,
                            itemBuilder: (context, index) {
                              final todo = _todos[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                child: Slidable(
                                  key: ValueKey(todo),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    extentRatio: 0.25,
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) =>
                                            _deleteTodo(index),
                                        backgroundColor: const Color.fromRGBO(
                                            255, 73, 73, 1),
                                        label: '删除',
                                        borderRadius: const BorderRadius.horizontal(
                                            left: Radius.circular(12)),
                                        autoClose: false,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => _toggleTodo(index),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 16),
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: todo.isDone
                                                    ? const Color.fromRGBO(
                                                        200, 200, 200, 1)
                                                    : const Color.fromRGBO(
                                                        64, 185, 222, 1),
                                                width: 2,
                                              ),
                                              color: todo.isDone
                                                  ? const Color.fromRGBO(
                                                      200, 200, 200, 1)
                                                  : Colors.transparent,
                                            ),
                                            child: todo.isDone
                                                ? const Icon(Icons.check,
                                                    size: 14,
                                                    color: Colors.white)
                                                : null,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              todo.content,
                                              style: TextStyle(
                                                fontFamily: 'SourceHanSans',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: todo.isDone
                                                    ? const Color.fromRGBO(
                                                        180, 180, 180, 1)
                                                    : const Color.fromRGBO(
                                                        46, 46, 46, 1),
                                                decoration: todo.isDone
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 添加 TODO 输入卡片
            Container(
              width: screenWidth - 30,
              decoration: MemoStyle.cardDecoration,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        cursorColor: Colors.blueGrey,
                        style: const TextStyle(
                          fontFamily: 'SourceHanSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(46, 46, 46, 1),
                        ),
                        decoration: const InputDecoration(
                          hintText: '添加待办事项...',
                          hintStyle: TextStyle(
                            fontFamily: 'SourceHanSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(130, 130, 130, 1),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onSubmitted: (value) => _addTodo(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _addTodo,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(64, 185, 222, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}