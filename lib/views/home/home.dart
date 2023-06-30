import '/exports/exports.dart';

import 'pages/map.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

// pages
  // List<Widget> pages = [
  //    const ,
  //     Notifications(),
  //   const GeolocatorWidget(),
  // ];
  // // controller
  // page index

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DistanceBetweenTwoPoints(),
    );
  }
}
