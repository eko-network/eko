// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeviceModel {

 String? get did; DateTime? get dat; bool get isRegistering;
/// Create a copy of DeviceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceModelCopyWith<DeviceModel> get copyWith => _$DeviceModelCopyWithImpl<DeviceModel>(this as DeviceModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceModel&&(identical(other.did, did) || other.did == did)&&(identical(other.dat, dat) || other.dat == dat)&&(identical(other.isRegistering, isRegistering) || other.isRegistering == isRegistering));
}


@override
int get hashCode => Object.hash(runtimeType,did,dat,isRegistering);

@override
String toString() {
  return 'DeviceModel(did: $did, dat: $dat, isRegistering: $isRegistering)';
}


}

/// @nodoc
abstract mixin class $DeviceModelCopyWith<$Res>  {
  factory $DeviceModelCopyWith(DeviceModel value, $Res Function(DeviceModel) _then) = _$DeviceModelCopyWithImpl;
@useResult
$Res call({
 String? did, DateTime? dat, bool isRegistering
});




}
/// @nodoc
class _$DeviceModelCopyWithImpl<$Res>
    implements $DeviceModelCopyWith<$Res> {
  _$DeviceModelCopyWithImpl(this._self, this._then);

  final DeviceModel _self;
  final $Res Function(DeviceModel) _then;

/// Create a copy of DeviceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? did = freezed,Object? dat = freezed,Object? isRegistering = null,}) {
  return _then(_self.copyWith(
did: freezed == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String?,dat: freezed == dat ? _self.dat : dat // ignore: cast_nullable_to_non_nullable
as DateTime?,isRegistering: null == isRegistering ? _self.isRegistering : isRegistering // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceModel].
extension DeviceModelPatterns on DeviceModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceModel value)  $default,){
final _that = this;
switch (_that) {
case _DeviceModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceModel value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? did,  DateTime? dat,  bool isRegistering)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceModel() when $default != null:
return $default(_that.did,_that.dat,_that.isRegistering);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? did,  DateTime? dat,  bool isRegistering)  $default,) {final _that = this;
switch (_that) {
case _DeviceModel():
return $default(_that.did,_that.dat,_that.isRegistering);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? did,  DateTime? dat,  bool isRegistering)?  $default,) {final _that = this;
switch (_that) {
case _DeviceModel() when $default != null:
return $default(_that.did,_that.dat,_that.isRegistering);case _:
  return null;

}
}

}

/// @nodoc


class _DeviceModel extends DeviceModel {
  const _DeviceModel({required this.did, required this.dat, this.isRegistering = false}): super._();
  

@override final  String? did;
@override final  DateTime? dat;
@override@JsonKey() final  bool isRegistering;

/// Create a copy of DeviceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceModelCopyWith<_DeviceModel> get copyWith => __$DeviceModelCopyWithImpl<_DeviceModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceModel&&(identical(other.did, did) || other.did == did)&&(identical(other.dat, dat) || other.dat == dat)&&(identical(other.isRegistering, isRegistering) || other.isRegistering == isRegistering));
}


@override
int get hashCode => Object.hash(runtimeType,did,dat,isRegistering);

@override
String toString() {
  return 'DeviceModel(did: $did, dat: $dat, isRegistering: $isRegistering)';
}


}

/// @nodoc
abstract mixin class _$DeviceModelCopyWith<$Res> implements $DeviceModelCopyWith<$Res> {
  factory _$DeviceModelCopyWith(_DeviceModel value, $Res Function(_DeviceModel) _then) = __$DeviceModelCopyWithImpl;
@override @useResult
$Res call({
 String? did, DateTime? dat, bool isRegistering
});




}
/// @nodoc
class __$DeviceModelCopyWithImpl<$Res>
    implements _$DeviceModelCopyWith<$Res> {
  __$DeviceModelCopyWithImpl(this._self, this._then);

  final _DeviceModel _self;
  final $Res Function(_DeviceModel) _then;

/// Create a copy of DeviceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? did = freezed,Object? dat = freezed,Object? isRegistering = null,}) {
  return _then(_DeviceModel(
did: freezed == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String?,dat: freezed == dat ? _self.dat : dat // ignore: cast_nullable_to_non_nullable
as DateTime?,isRegistering: null == isRegistering ? _self.isRegistering : isRegistering // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
