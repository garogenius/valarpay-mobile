class DataState<T> {
  final bool isInitialLoading;
  final bool isPaginating;
  final bool isDataAvailable;
  final int currentPage;
  final int totalPages;
  final String? message;
  final List<T>? data;
  final T? singleData;

  const DataState({
    this.isInitialLoading = false,
    this.isPaginating = false,
    this.isDataAvailable = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.message,
    this.data,
    this.singleData,
  });

  factory DataState.initial() => DataState<T>(
        isInitialLoading: false,
        isPaginating: false,
        isDataAvailable: false,
        currentPage: 1,
        totalPages: 1,
        message: null,
        data: const [],
        singleData: null
      );

  DataState<T> copyWith({
    bool? isInitialLoading,
    bool? isPaginating,
    bool? isDataAvailable,
    int? currentPage,
    int? totalPages,
    String? message,
    List<T>? data,
    T? singleData
  }) {
    return DataState<T>(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      isDataAvailable: isDataAvailable ?? this.isDataAvailable,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      message: message ?? this.message,
      data: data ?? this.data,
      singleData: singleData ?? this.singleData
    );
  }
}
