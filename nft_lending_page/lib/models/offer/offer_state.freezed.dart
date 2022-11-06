// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'offer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$OffersState {
  OfferState? get currentOffer => throw _privateConstructorUsedError;
  List<OfferState> get offers => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OffersStateCopyWith<OffersState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OffersStateCopyWith<$Res> {
  factory $OffersStateCopyWith(
          OffersState value, $Res Function(OffersState) then) =
      _$OffersStateCopyWithImpl<$Res, OffersState>;
  @useResult
  $Res call({OfferState? currentOffer, List<OfferState> offers});

  $OfferStateCopyWith<$Res>? get currentOffer;
}

/// @nodoc
class _$OffersStateCopyWithImpl<$Res, $Val extends OffersState>
    implements $OffersStateCopyWith<$Res> {
  _$OffersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentOffer = freezed,
    Object? offers = null,
  }) {
    return _then(_value.copyWith(
      currentOffer: freezed == currentOffer
          ? _value.currentOffer
          : currentOffer // ignore: cast_nullable_to_non_nullable
              as OfferState?,
      offers: null == offers
          ? _value.offers
          : offers // ignore: cast_nullable_to_non_nullable
              as List<OfferState>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $OfferStateCopyWith<$Res>? get currentOffer {
    if (_value.currentOffer == null) {
      return null;
    }

    return $OfferStateCopyWith<$Res>(_value.currentOffer!, (value) {
      return _then(_value.copyWith(currentOffer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_OffersStateCopyWith<$Res>
    implements $OffersStateCopyWith<$Res> {
  factory _$$_OffersStateCopyWith(
          _$_OffersState value, $Res Function(_$_OffersState) then) =
      __$$_OffersStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({OfferState? currentOffer, List<OfferState> offers});

  @override
  $OfferStateCopyWith<$Res>? get currentOffer;
}

/// @nodoc
class __$$_OffersStateCopyWithImpl<$Res>
    extends _$OffersStateCopyWithImpl<$Res, _$_OffersState>
    implements _$$_OffersStateCopyWith<$Res> {
  __$$_OffersStateCopyWithImpl(
      _$_OffersState _value, $Res Function(_$_OffersState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentOffer = freezed,
    Object? offers = null,
  }) {
    return _then(_$_OffersState(
      currentOffer: freezed == currentOffer
          ? _value.currentOffer
          : currentOffer // ignore: cast_nullable_to_non_nullable
              as OfferState?,
      offers: null == offers
          ? _value._offers
          : offers // ignore: cast_nullable_to_non_nullable
              as List<OfferState>,
    ));
  }
}

/// @nodoc

class _$_OffersState implements _OffersState {
  const _$_OffersState(
      {this.currentOffer, final List<OfferState> offers = const []})
      : _offers = offers;

  @override
  final OfferState? currentOffer;
  final List<OfferState> _offers;
  @override
  @JsonKey()
  List<OfferState> get offers {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_offers);
  }

  @override
  String toString() {
    return 'OffersState(currentOffer: $currentOffer, offers: $offers)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_OffersState &&
            (identical(other.currentOffer, currentOffer) ||
                other.currentOffer == currentOffer) &&
            const DeepCollectionEquality().equals(other._offers, _offers));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, currentOffer, const DeepCollectionEquality().hash(_offers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_OffersStateCopyWith<_$_OffersState> get copyWith =>
      __$$_OffersStateCopyWithImpl<_$_OffersState>(this, _$identity);
}

abstract class _OffersState implements OffersState {
  const factory _OffersState(
      {final OfferState? currentOffer,
      final List<OfferState> offers}) = _$_OffersState;

  @override
  OfferState? get currentOffer;
  @override
  List<OfferState> get offers;
  @override
  @JsonKey(ignore: true)
  _$$_OffersStateCopyWith<_$_OffersState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OfferState {
  String get assetAddress => throw _privateConstructorUsedError;
  int? get tokenId => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get lenderAddress => throw _privateConstructorUsedError;
  int? get rentalPeriod => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  int? get rentalPrice => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OfferStateCopyWith<OfferState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfferStateCopyWith<$Res> {
  factory $OfferStateCopyWith(
          OfferState value, $Res Function(OfferState) then) =
      _$OfferStateCopyWithImpl<$Res, OfferState>;
  @useResult
  $Res call(
      {String assetAddress,
      int? tokenId,
      String imageUrl,
      String lenderAddress,
      int? rentalPeriod,
      DateTime? dueDate,
      int? rentalPrice});
}

/// @nodoc
class _$OfferStateCopyWithImpl<$Res, $Val extends OfferState>
    implements $OfferStateCopyWith<$Res> {
  _$OfferStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assetAddress = null,
    Object? tokenId = freezed,
    Object? imageUrl = null,
    Object? lenderAddress = null,
    Object? rentalPeriod = freezed,
    Object? dueDate = freezed,
    Object? rentalPrice = freezed,
  }) {
    return _then(_value.copyWith(
      assetAddress: null == assetAddress
          ? _value.assetAddress
          : assetAddress // ignore: cast_nullable_to_non_nullable
              as String,
      tokenId: freezed == tokenId
          ? _value.tokenId
          : tokenId // ignore: cast_nullable_to_non_nullable
              as int?,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      lenderAddress: null == lenderAddress
          ? _value.lenderAddress
          : lenderAddress // ignore: cast_nullable_to_non_nullable
              as String,
      rentalPeriod: freezed == rentalPeriod
          ? _value.rentalPeriod
          : rentalPeriod // ignore: cast_nullable_to_non_nullable
              as int?,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rentalPrice: freezed == rentalPrice
          ? _value.rentalPrice
          : rentalPrice // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_OfferStateCopyWith<$Res>
    implements $OfferStateCopyWith<$Res> {
  factory _$$_OfferStateCopyWith(
          _$_OfferState value, $Res Function(_$_OfferState) then) =
      __$$_OfferStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String assetAddress,
      int? tokenId,
      String imageUrl,
      String lenderAddress,
      int? rentalPeriod,
      DateTime? dueDate,
      int? rentalPrice});
}

/// @nodoc
class __$$_OfferStateCopyWithImpl<$Res>
    extends _$OfferStateCopyWithImpl<$Res, _$_OfferState>
    implements _$$_OfferStateCopyWith<$Res> {
  __$$_OfferStateCopyWithImpl(
      _$_OfferState _value, $Res Function(_$_OfferState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assetAddress = null,
    Object? tokenId = freezed,
    Object? imageUrl = null,
    Object? lenderAddress = null,
    Object? rentalPeriod = freezed,
    Object? dueDate = freezed,
    Object? rentalPrice = freezed,
  }) {
    return _then(_$_OfferState(
      assetAddress: null == assetAddress
          ? _value.assetAddress
          : assetAddress // ignore: cast_nullable_to_non_nullable
              as String,
      tokenId: freezed == tokenId
          ? _value.tokenId
          : tokenId // ignore: cast_nullable_to_non_nullable
              as int?,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      lenderAddress: null == lenderAddress
          ? _value.lenderAddress
          : lenderAddress // ignore: cast_nullable_to_non_nullable
              as String,
      rentalPeriod: freezed == rentalPeriod
          ? _value.rentalPeriod
          : rentalPeriod // ignore: cast_nullable_to_non_nullable
              as int?,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rentalPrice: freezed == rentalPrice
          ? _value.rentalPrice
          : rentalPrice // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$_OfferState implements _OfferState {
  const _$_OfferState(
      {this.assetAddress = "",
      this.tokenId,
      this.imageUrl = "",
      this.lenderAddress = "",
      this.rentalPeriod,
      this.dueDate,
      this.rentalPrice});

  @override
  @JsonKey()
  final String assetAddress;
  @override
  final int? tokenId;
  @override
  @JsonKey()
  final String imageUrl;
  @override
  @JsonKey()
  final String lenderAddress;
  @override
  final int? rentalPeriod;
  @override
  final DateTime? dueDate;
  @override
  final int? rentalPrice;

  @override
  String toString() {
    return 'OfferState(assetAddress: $assetAddress, tokenId: $tokenId, imageUrl: $imageUrl, lenderAddress: $lenderAddress, rentalPeriod: $rentalPeriod, dueDate: $dueDate, rentalPrice: $rentalPrice)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_OfferState &&
            (identical(other.assetAddress, assetAddress) ||
                other.assetAddress == assetAddress) &&
            (identical(other.tokenId, tokenId) || other.tokenId == tokenId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.lenderAddress, lenderAddress) ||
                other.lenderAddress == lenderAddress) &&
            (identical(other.rentalPeriod, rentalPeriod) ||
                other.rentalPeriod == rentalPeriod) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.rentalPrice, rentalPrice) ||
                other.rentalPrice == rentalPrice));
  }

  @override
  int get hashCode => Object.hash(runtimeType, assetAddress, tokenId, imageUrl,
      lenderAddress, rentalPeriod, dueDate, rentalPrice);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_OfferStateCopyWith<_$_OfferState> get copyWith =>
      __$$_OfferStateCopyWithImpl<_$_OfferState>(this, _$identity);
}

abstract class _OfferState implements OfferState {
  const factory _OfferState(
      {final String assetAddress,
      final int? tokenId,
      final String imageUrl,
      final String lenderAddress,
      final int? rentalPeriod,
      final DateTime? dueDate,
      final int? rentalPrice}) = _$_OfferState;

  @override
  String get assetAddress;
  @override
  int? get tokenId;
  @override
  String get imageUrl;
  @override
  String get lenderAddress;
  @override
  int? get rentalPeriod;
  @override
  DateTime? get dueDate;
  @override
  int? get rentalPrice;
  @override
  @JsonKey(ignore: true)
  _$$_OfferStateCopyWith<_$_OfferState> get copyWith =>
      throw _privateConstructorUsedError;
}
