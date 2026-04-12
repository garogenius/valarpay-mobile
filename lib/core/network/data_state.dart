class DataState<T> {
  final bool isOverlayHidden;
  final bool isInitialLoading;
  final bool isPaginating;
  final bool isDataAvailable;
  final int currentPage;
  final int totalPages;
  final String? message;
  final List<T>? data;
  final T? singleData;
  final String? error;

  const DataState({
    this.isOverlayHidden = false,
    this.isInitialLoading = false,
    this.isPaginating = false,
    this.isDataAvailable = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.message,
    this.data,
    this.singleData,
    this.error,
  });

  factory DataState.initial() => DataState<T>(
    isOverlayHidden: false,
    isInitialLoading: false,
    isPaginating: false,
    isDataAvailable: false,
    currentPage: 1,
    totalPages: 1,
    message: null,
    data: const [],
    singleData: null,
    error: null,
  );

  DataState<T> copyWith({
    bool? isOverlayHidden,
    bool? isInitialLoading,
    bool? isPaginating,
    bool? isDataAvailable,
    int? currentPage,
    int? totalPages,
    Object? message = _sentinel,
    List<T>? data,
    T? singleData,
    Object? error = _sentinel,
  }) {
    return DataState<T>(
      isOverlayHidden: isOverlayHidden ?? this.isOverlayHidden,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      isDataAvailable: isDataAvailable ?? this.isDataAvailable,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      message: message == _sentinel ? this.message : (message as String?),
      data: data ?? this.data,
      singleData: singleData ?? this.singleData,
      error: error == _sentinel ? this.error : (error as String?),
    );
  }

  static const _sentinel = Object();

  DataState<T> toLoading() => copyWith(
        isInitialLoading: true,
        message: null,
        error: null,
        isDataAvailable: false,
      );

  DataState<T> toDataAvailable(List<T> data) => copyWith(
        isInitialLoading: false,
        data: data,
        isDataAvailable: true,
        message: null,
        error: null,
      );

  DataState<T> toSingleDataAvailable(T data) => copyWith(
        isInitialLoading: false,
        singleData: data,
        isDataAvailable: true,
        message: null,
        error: null,
      );

  DataState<T> toError(String message) => copyWith(
        isInitialLoading: false,
        message: message,
        error: message,
        isDataAvailable: false,
      );
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess({super.data, super.singleData}) : super(isDataAvailable: true);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(String error) : super(error: error, isDataAvailable: false);
}
