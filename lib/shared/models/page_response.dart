class PageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool isFirst;
  final bool isLast;

  const PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.isFirst,
    required this.isLast,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic raw) fromJsonT,
  ) {
    final rawContent = json['content'] as List? ?? [];
    final content = rawContent.map((e) => fromJsonT(e)).toList();

    final page = json['page'] is int
        ? json['page'] as int
        : (json['number'] is int ? json['number'] as int : 0);
    final size = json['size'] is int ? json['size'] as int : 20;
    final totalElements = json['totalElements'] is int
        ? json['totalElements'] as int
        : (json['total'] is int ? json['total'] as int : content.length);
    final totalPages = json['totalPages'] is int
        ? json['totalPages'] as int
        : ((totalElements / (size > 0 ? size : 20)).ceil());

    final isFirst = json['first'] is bool ? json['first'] as bool : (page == 0);
    final isLast = json['last'] is bool
        ? json['last'] as bool
        : (page >= totalPages - 1 || totalPages == 0);

    return PageResponse<T>(
      content: content,
      page: page,
      size: size,
      totalElements: totalElements,
      totalPages: totalPages,
      isFirst: isFirst,
      isLast: isLast,
    );
  }

  PageResponse<T> copyWith({
    List<T>? content,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
    bool? isFirst,
    bool? isLast,
  }) {
    return PageResponse<T>(
      content: content ?? this.content,
      page: page ?? this.page,
      size: size ?? this.size,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      isFirst: isFirst ?? this.isFirst,
      isLast: isLast ?? this.isLast,
    );
  }

  bool get hasPrevious => page > 0;
  bool get hasNext => page < totalPages - 1;
}
