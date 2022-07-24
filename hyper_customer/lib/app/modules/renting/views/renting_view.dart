import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:hyper_customer/app/core/values/app_colors.dart';
import 'package:hyper_customer/app/core/values/box_decorations.dart';
import 'package:hyper_customer/app/core/values/button_styles.dart';
import 'package:hyper_customer/app/core/values/input_styles.dart';
import 'package:hyper_customer/app/core/values/shadow_styles.dart';
import 'package:hyper_customer/app/core/values/text_styles.dart';
import 'package:hyper_customer/app/core/widgets/hyper_button.dart';
import 'package:hyper_customer/app/core/widgets/hyper_stack.dart';
import 'package:hyper_customer/app/core/widgets/status_bar.dart';

import 'package:latlong2/latlong.dart';

import '../controllers/renting_controller.dart';

class RentingView extends GetView<RentingController> {
  const RentingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatusBar(
      brightness: Brightness.dark,
      child: Scaffold(
        body: Stack(children: [
          _map(),
          _search(),
          _bottom(),
        ]),
      ),
    );
  }

  Widget _bottom() {
    return Container(
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _goToCurrentLocation(),
          GetBuilder<RentingController>(
            builder: (_) {
              if (controller.isSelectedStation) {
                return _rentStationDetail();
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }

  Container _rentStationDetail() {
    return Container(
      padding: EdgeInsets.only(bottom: 10.h, left: 10.w, right: 10.w),
      child: Container(
        decoration: BoxDecorations.map(),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.selectedStation?.title ?? '',
              style: subtitle1.copyWith(
                fontSize: 18.sp,
                color: AppColors.softBlack,
              ),
            ),
            Text(
              controller.selectedStation?.address ?? '',
              style: body2.copyWith(
                color: AppColors.description,
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(
                  () => SizedBox(
                    height: 36.h,
                    width: 124.w,
                    child: ElevatedButton(
                      style: ButtonStyles.primarySmall(),
                      onPressed: controller.isFindingRoute
                          ? null
                          : () {
                              controller.findRoute();
                            },
                      child: HyperButton.child(
                        status: controller.isFindingRoute,
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_outlined,
                              size: 20.r,
                            ),
                            SizedBox(
                              width: 6.w,
                            ),
                            Text(
                              'Đường đi',
                              style: buttonBold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _goToCurrentLocation() {
    return Container(
      padding: EdgeInsets.only(bottom: 20.h, right: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              controller.goToCurrentLocation();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              primary: AppColors.white,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.all(0),
              minimumSize: Size(40.r, 40.r),
            ),
            child: SizedBox(
              height: 40.r,
              width: 40.r,
              child: Icon(
                Icons.gps_fixed,
                size: 18.r,
                color: AppColors.gray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SafeArea _search() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          top: 10.h,
          left: 10.w,
          right: 10.w,
        ),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                primary: AppColors.white,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.all(0),
                minimumSize: Size(40.r, 40.r),
              ),
              child: SizedBox(
                height: 40.r,
                width: 40.r,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18.r,
                  color: AppColors.gray,
                ),
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.toNamed('/renting/search');
                },
                child: Container(
                  height: 42.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    color: AppColors.surface,
                    boxShadow: ShadowStyles.map,
                  ),
                  child: TextFormField(
                    enabled: false,
                    decoration: InputStyles.mapSearch(
                      prefixIcon: Icon(
                        Icons.search,
                        size: 22.r,
                        color: AppColors.lightBlack,
                      ),
                      hintText: 'Tìm kiếm trạm',
                    ),
                    validator: (value) {
                      if (value.toString().isEmpty) {
                        return 'Vui lòng nhập mã PIN để tiếp tục';
                      }
                      return null;
                    },
                    // onSaved: (value) => controller.password = value,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlutterMap _map() {
    return FlutterMap(
      mapController: controller.mapController,
      options: MapOptions(
        interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        center: LatLng(10.212884, 103.964889),
        zoom: 10.8,
        minZoom: 10.8,
        maxZoom: 18.4,
        swPanBoundary: LatLng(9.866505, 103.785063),
        nePanBoundary: LatLng(10.508632, 104.112881),
        slideOnBoundaries: true,
        onPositionChanged: controller.onPositionChanged,
        onMapCreated: controller.onMapCreated,
      ),
      children: [
        TileLayerWidget(
          options: TileLayerOptions(
            urlTemplate: controller.urlTemplate,
            additionalOptions: {
              'accessToken': controller.accessToken,
              'id': controller.mapId,
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.clearSelectedMarker();
          },
          child: Container(
            color: AppColors.white.withOpacity(0),
          ),
        ),
        HyperStack(
          children: [
            GetBuilder<RentingController>(
              builder: (_) {
                return controller.hasRoute
                    ? PolylineLayerWidget(
                        options: PolylineLayerOptions(
                          polylineCulling: false,
                          polylines: [
                            Polyline(
                              strokeWidth: 4.r,
                              color: AppColors.blue,
                              borderStrokeWidth: 3.r,
                              borderColor: AppColors.darkBlue,
                              points: controller.routePoints,
                            ),
                          ],
                        ),
                      )
                    : Container();
              },
            ),
            GetBuilder<RentingController>(
              builder: (_) {
                return MarkerLayerWidget(
                  options: MarkerLayerOptions(
                    markers: controller.markers,
                  ),
                );
              },
            ),
          ],
        ),
        IgnorePointer(
          child: LocationMarkerLayerWidget(
            options: LocationMarkerLayerOptions(
              showHeadingSector: false,
              marker: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: ShadowStyles.locationMarker,
                ),
                child: DefaultLocationMarker(
                  child: Container(
                    padding: EdgeInsets.only(bottom: 2.r),
                    child: Center(
                      child: Icon(
                        Icons.navigation,
                        color: Colors.white,
                        size: 16.r,
                      ),
                    ),
                  ),
                ),
              ),
              markerSize: Size(26.r, 26.r),
              markerDirection: MarkerDirection.heading,
            ),
          ),
        ),
      ],
    );
  }
}
