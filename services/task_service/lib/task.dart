class TaskList {
  final List<TaskItem> items;

  const TaskList(this.items);

  TaskList.empty() : items = <TaskItem>[];
}

class TaskItem {
  final String taskId;
  final String description;

  const TaskItem(this.taskId, this.description);

  Map<String, Object?> toJson() => <String, Object?>{
        'taskId': taskId,
        'description': description,
      };
}

final Map<String, TaskList> tasksByUserId = <String, TaskList>{};

