import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hyper_customer/app/core/base/base_controller.dart';
import 'package:hyper_customer/app/core/utils/animated_map_utils.dart';
import 'package:hyper_customer/app/core/utils/map_utils.dart';
import 'package:hyper_customer/app/core/utils/utils.dart';
import 'package:hyper_customer/app/core/values/app_assets.dart';
import 'package:hyper_customer/app/core/values/app_colors.dart';
import 'package:hyper_customer/app/data/models/rent_stations_model.dart';
import 'package:hyper_customer/app/data/repository/mapbox_repository.dart';
import 'package:hyper_customer/app/data/repository/repository.dart';
import 'package:hyper_customer/app/modules/renting/models/renting_state.dart';

import 'package:latlong2/latlong.dart';

class RentingController extends BaseController
    with GetTickerProviderStateMixin {
  double zoomLevel = 10.8;
  double zoomInLevel = 13.7;
  double navigationZoomLevel = 17;

  final Repository _repository = Get.find(tag: (Repository).toString());
  final MapboxRepository _mapboxRepository =
      Get.find(tag: (MapboxRepository).toString());

  RentStations? rentStations;
  MapController mapController = MapController();

  List<Widget> searchItems = [];
  Map<String, Items> rentStationsData = {};

  List<Marker> markers = [];

  late AnimatedMap _animatedMap;

  late LatLng currentLocation;
  LatLngBounds? currentBounds;

  String? selectedStationId;
  Items? get selectedStation => rentStationsData[selectedStationId];

  var rentingState = RentingState.normal.obs;

  // Region Init
  @override
  void onInit() async {
    init();
    super.onInit();
  }

  Future<void> init() async {
    _animatedMap = AnimatedMap(controller: mapController, vsync: this);

    await _getCurrentLocation();
    await _fetchRentStations();
    _goToCurrentLocationWithZoomDelay();
  }
  // End Region

  // Region Fetch Rent Stations
  Future<void> _fetchRentStations() async {
    var rentStationsService = _repository.getRentStations();

    await callDataService(
      rentStationsService,
      onSuccess: (RentStations? response) {
        rentStations = response;
      },
      onError: (DioError dioError) {
        Utils.showToast('Kết nối thất bại');
      },
    );

    _updateMarker();
  }

  void _updateMarker() {
    markers.clear();

    rentStationsData.clear();
    var items = rentStations?.body?.items ?? [];
    for (Items item in items) {
      double lat = item.latitude ?? 0;
      double lng = item.longitude ?? 0;

      var itemId = item.id ?? '';
      var location = LatLng(lat, lng);

      rentStationsData[itemId] = item;

      markers.add(
        Marker(
          width: 80.r,
          height: 80.r,
          point: location,
          builder: (context) {
            Widget result = Container(
              padding: EdgeInsets.all(20.r),
              child: GestureDetector(
                onTap: () {
                  _selectStatiton(itemId);
                  _moveToPosition(location);
                  update();
                },
                child: Container(
                  color: AppColors.white.withOpacity(0),
                  padding: EdgeInsets.all(10.r),
                  child: SvgPicture.asset(
                    AppAssets.rentingMapIcon,
                  ),
                ),
              ),
            );
            if (selectedStationId == itemId) {
              result = Container(
                padding: EdgeInsets.only(bottom: 40.r),
                child: GestureDetector(
                  onTap: () {
                    _selectStatiton(itemId);
                    _moveToPosition(location);
                    update();
                  },
                  child: rentingState.value == RentingState.navigation
                      ? SvgPicture.asset(AppAssets.locationOnPurpleIcon)
                      : SvgPicture.asset(
                          AppAssets.locationOnIcon,
                        ),
                ),
              );
            }
            return result;
          },
        ),
      );
    }

    update();
  }

  // End Region

  // Region Fetch Route
  List<LatLng> routePoints = [];
  var isFindingRoute = false.obs;

  void findRoute() async {
    isFindingRoute.value = true;

    routePoints.clear();

    await _getCurrentLocation();
    LatLng from = currentLocation;
    LatLng to = LatLng(
      selectedStation?.latitude ?? 0,
      selectedStation?.longitude ?? 0,
    );
    var loginService = _mapboxRepository.findRoute(from, to);

    await callDataService(
      loginService,
      onSuccess: (List<LatLng> response) {
        routePoints = response;
      },
      onError: (DioError dioError) {
        Utils.showToast('Kết nối thất bại');
      },
    );

    currentBounds = LatLngBounds();
    for (LatLng point in routePoints) {
      currentBounds?.extend(point);
    }
    currentBounds?.pad(0.48);
    _centerZoomFitBounds(currentBounds!);

    isFindingRoute.value = false;
    _changeRentingState(RentingState.route);
  }

  void clearRoute() {
    _changeRentingState(RentingState.select);
    routePoints.clear();
    moveToSelectedStation();
    update();
  }
  // End Region

  // Region Get Current Location

  Future<void> _getCurrentLocation() async {
    var currentPosition = await MapUtils.determinePosition();
    currentLocation =
        LatLng(currentPosition.latitude, currentPosition.longitude);
  }

  void _goToCurrentLocationWithZoomDelay({double? zoom}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _moveToPosition(currentLocation, zoom: zoom ?? zoomInLevel);
  }

  void _goToCurrentLocation({double? zoom}) async {
    await _getCurrentLocation();
    _moveToPosition(currentLocation, zoom: zoom ?? mapController.zoom);
  }

  void goToCurrentLocation() {
    if (rentingState.value == RentingState.navigation) {
      _goToCurrentLocation(zoom: navigationZoomLevel);
    } else {
      _goToCurrentLocation();
    }
  }

  void _moveToPosition(LatLng position, {double? zoom}) {
    var zoomLevel = zoom ?? mapController.zoom;
    _animatedMap.move(position, zoomLevel);
  }
  // End Region

  // Region Navigation
  void goToNavigation() async {
    _changeRentingState(RentingState.navigation);
    // urlTemplate.value = BuildConfig.instance.config.mapboxNavigationUrlTemplate;
    await _getCurrentLocation();
    _goToCurrentLocation(zoom: navigationZoomLevel);
    update();
  }

  void goBackFromNavigation() {
    _changeRentingState(RentingState.route);
    // urlTemplate.value = BuildConfig.instance.config.mapboxUrlTemplate;
    _centerZoomFitBounds(currentBounds!);
    update();
  }

  void _centerZoomFitBounds(LatLngBounds bounds) {
    var centerZoom = mapController.centerZoomFitBounds(bounds);
    _animatedMap.move(centerZoom.center, centerZoom.zoom);
  }
  // End Region

  void _selectStatiton(String stationId) {
    _changeRentingState(RentingState.select);
    selectedStationId = stationId;
  }

  void unfocus() {
    _changeRentingState(RentingState.normal);
    selectedStationId = null;
    update();
  }

  void moveToSelectedStation() {
    if (selectedStation == null) return;

    double lat = selectedStation?.latitude ?? 0;
    double lng = selectedStation?.longitude ?? 0;

    var location = LatLng(lat, lng);
    _moveToPosition(location);
  }

  void _changeRentingState(RentingState state) {
    _updateMarker();
    rentingState.value = state;
  }
}
