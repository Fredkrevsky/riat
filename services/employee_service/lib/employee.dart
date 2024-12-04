class Employee {
  final String employeeId;
  final String name;
  final String position;
  final double salary;

  const Employee(this.employeeId, this.name, this.position, this.salary);

  Map<String, Object?> toJson() => <String, Object?>{
        'employeeId': employeeId,
        'name': name,
        'position': position,
        'salary': salary,
      };
}

final Map<String, Employee> employeeById = <String, Employee>{};

