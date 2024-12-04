class PerformanceReview {
  final String employeeId;
  final int rating;
  final String comment;

  const PerformanceReview(this.employeeId, this.rating, this.comment);

  Map<String, Object?> toJson() => <String, Object?>{
        'employeeId': employeeId,
        'rating': rating,
        'comment': comment,
      };
}

final Map<String, List<PerformanceReview>> reviewsByEmployeeId = <String, List<PerformanceReview>>{};
