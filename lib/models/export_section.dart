class ExportSection {
  final String title;
  final int count;
  final bool selected;

  ExportSection({
    required this.title,
    required this.count,
    this.selected = true,
  });

  ExportSection copyWith({
    String? title,
    int? count,
    bool? selected,
  }) {
    return ExportSection(
      title: title ?? this.title,
      count: count ?? this.count,
      selected: selected ?? this.selected,
    );
  }
}