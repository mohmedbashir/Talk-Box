import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Shimmer.fromColors(
          enabled: true,
          direction: ShimmerDirection.rtl,
          baseColor: Colors.black38,
          highlightColor: Colors.white,
          child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Row(
                    children: [
                      const Spacer(flex: 2),
                      Container(
                        color: Colors.black26,
                        width: 80.w,
                        height: 25.h,
                      ),
                      const Spacer(flex: 1),
                      const CircleAvatar(
                        backgroundColor: Colors.black26,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: double.infinity,
                      height: 57.68.h,
                      color: Colors.black26,
                    ),
                  ),
                ),
                _myStories(),
                _othersStory(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        color: Colors.black26,
                        height: 123.6.h,
                      )),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                    ),
                    child: Container(
                      height: 90.64.h,
                      width: double.infinity,
                      color: Colors.black26,
                    ),
                  ),
                )
              ]),
        ),
      ),
    );
  }

  Column _othersStory() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15, right: 15),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 100.w,
                  height: 41.2.h,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 15,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 137.2.w,
                    height: 173.04.h,
                    color: Colors.black26,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 141.12.w,
                    height: 173.04.h,
                    color: Colors.black26,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 15),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  child: Container(
                    width: 53.704.w,
                    height: 173.04.h,
                    color: Colors.black26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column _myStories() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15, right: 15),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 100,
                  height: 41.2.h,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 15,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 86.24.w,
                    height: 107.12.h,
                    color: Colors.black26,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 86.24.w,
                    height: 107.12.h,
                    color: Colors.black26,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 86.24.w,
                    height: 107.12.h,
                    color: Colors.black26,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                child: Container(
                  width: 70.56.w,
                  height: 107.12.h,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShimmerEffect1 extends StatelessWidget {
  const ShimmerEffect1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Shimmer.fromColors(
          enabled: true,
          direction: ShimmerDirection.rtl,
          baseColor: Colors.black38,
          highlightColor: Colors.white,
          child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: double.infinity,
                      height: 57.68.h,
                      color: Colors.black26,
                    ),
                  ),
                ),
                _myStories(),
                _othersStory(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        color: Colors.black26,
                        height: 123.6.h,
                      )),
                ),
                /* Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                    ),
                    child: Container(
                      height: 90.64.h,
                      width: double.infinity,
                      color: Colors.black26,
                    ),
                  ),
                ) */
              ]),
        ),
      ),
    );
  }

  Column _othersStory() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15, right: 15),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 100.w,
                  height: 41.2.h,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 15,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 137.2.w,
                    height: 173.04.h,
                    color: Colors.black26,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 141.12.w,
                    height: 173.04.h,
                    color: Colors.black26,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 15),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  child: Container(
                    width: 53.704.w,
                    height: 173.04.h,
                    color: Colors.black26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column _myStories() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15, right: 15),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 100,
                  height: 41.2.h,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 15,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 86.24.w,
                    height: 107.12.h,
                    color: Colors.black26,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 86.24.w,
                    height: 107.12.h,
                    color: Colors.black26,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 86.24.w,
                    height: 107.12.h,
                    color: Colors.black26,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                child: Container(
                  width: 70.56.w,
                  height: 107.12.h,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
