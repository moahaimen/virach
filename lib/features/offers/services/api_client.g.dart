// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations

class _ApiClient implements ApiClient {
  _ApiClient(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'https://racheeta.pythonanywhere.com/';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<OffersModel> createOffer(dynamic offerData) async {
    // *** 1. اطبع محتوى FormData قبل الإرسال ***
    if (offerData is FormData) {
      print('>>> [createOffer] -------------- REQUEST --------------');
      print('⚡️ FormData fields:');
      for (var field in offerData.fields) {
        print('   • ${field.key}: ${field.value}');
      }
      print('⚡️ FormData files:');
      for (var file in offerData.files) {
        print('   • ${file.key}: filename=${file.value.filename}');
      }
    } else {
      print('>>> [createOffer] Body (not FormData): $offerData');
    }

    // *** 2. إبناء خيارات الطلب ***
    final queryParameters = <String, dynamic>{};
    final _extra = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _options = _setStreamType<OffersModel>(
      Options(method: 'POST', headers: _headers, extra: _extra).compose(
        _dio.options,
        '/offers/',
        queryParameters: queryParameters,
        data: offerData,
      ).copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );

    print('🌐 URL : ${_options.baseUrl}${_options.path}');
    print('🌐 HEADERS : ${_options.headers}');

    // *** 3. أرسل الطلب ***
    late Response<Map<String, dynamic>> _result;
    try {
      _result = await _dio.fetch<Map<String, dynamic>>(_options);
    } on DioException catch (e) {
      // اطبع الاستجابة التي تسببت في الخطأ (400, 500…)
      print('❗️ DIO ERROR status: ${e.response?.statusCode}');
      print('❗️ RESPONSE DATA: ${e.response?.data}');
      rethrow; // أعد رميه كي يصل للطبقة العلوية كما كان
    }

    print('✅ STATUS: ${_result.statusCode}');
    print('✅ RESPONSE RAW: ${_result.data}');

    // *** 4. حوّل JSON إلى نموذج ***
    late OffersModel _value;
    try {
      _value = OffersModel.fromJson(_result.data!);
    } catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }


  @override
  Future<List<OffersModel>> getOffers() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<List<OffersModel>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/offers/',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<OffersModel> _value;
    try {
      _value = _result.data!
          .map(
            (dynamic i) => OffersModel.fromJson(i as Map<String, dynamic>),
          )
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<OffersModel> updateOffer(String id, FormData offerData) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = offerData;
    final _options = _setStreamType<OffersModel>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/offers/${id}/',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late OffersModel _value;
    try {
      _value = OffersModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> deleteOffer(String id) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<void>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/offers/${id}/',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    await _dio.fetch<void>(_options);
  }

  @override
  Future<List<OffersModel>> getOffersbyServiceProviderID(
    String? serviceProviderId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'service_provider_id': serviceProviderId,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<List<OffersModel>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/offers/',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<OffersModel> _value;
    try {
      _value = _result.data!
          .map(
            (dynamic i) => OffersModel.fromJson(i as Map<String, dynamic>),
          )
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
