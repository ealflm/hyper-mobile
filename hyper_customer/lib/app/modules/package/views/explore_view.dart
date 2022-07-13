import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:hyper_customer/app/core/values/app_assets.dart';
import 'package:hyper_customer/app/core/values/app_colors.dart';
import 'package:hyper_customer/app/core/values/app_values.dart';
import 'package:hyper_customer/app/core/values/button_styles.dart';
import 'package:hyper_customer/app/core/values/font_weights.dart';
import 'package:hyper_customer/app/core/values/shadow_styles.dart';
import 'package:hyper_customer/app/core/values/text_styles.dart';
import 'package:hyper_customer/app/core/widgets/hyper_button.dart';
import 'package:hyper_customer/app/modules/package/widget/package_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../controllers/package_controller.dart';

class ExploreView extends GetView<PackageController> {
  const ExploreView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    RefreshController refreshController =
        RefreshController(initialRefresh: false);
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Center(
      child: SizedBox(
        height: 1.sh - AppValues.bottomAppBarHeight - statusBarHeight - 115.h,
        width: double.infinity,
        child: SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            refreshController.refreshCompleted();
          },
          header: WaterDropMaterialHeader(
            distance: 50.h,
            backgroundColor: AppColors.softRed,
          ),
          child: ListView(
            children: [
              SizedBox(height: 20.h),
              const PackageCard(),
              SizedBox(height: 24.h),
              const PackageCard(),
              SizedBox(height: 24.h),
              const PackageCard(),
              SizedBox(height: 24.h),
              const PackageCard(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
