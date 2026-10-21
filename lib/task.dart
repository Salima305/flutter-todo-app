class Task{
  String title;
  bool isCompleted;
  String category;
  Task({
    required this.title,
    this.isCompleted=false,
this.category='Personal'
  });

  Map<String,dynamic> toJson(){
    return{
      'title': title,
      'isCompleted': isCompleted,
      'category': category,
    };
  }
  factory Task.fromJson(Map<String, dynamic> json) {
  return Task(
    title: json['title'] as String,
    isCompleted: json['isCompleted'] as bool,
     category: json['category'] as String? ?? 'Personal',
  );
}
}
