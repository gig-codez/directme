import '/utils/extensions/context.dart';
import '/utils/extensions/widgets.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_maps_directions/google_maps_directions.dart';

class RouteStepsView extends StatelessWidget {
  const RouteStepsView({
    super.key,
    required this.route,
  });

  final DirectionRoute route;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "${route.shortestLeg.duration.text} (${route.shortestLeg.distance.text})",
                style: const TextStyle(fontSize: 24),
              ).padVertical(10),
              Text(
                "Route la plus rapide selon l'état actuel de la circulation (${route.summary}).",
                style: const TextStyle(fontSize: 15),
              ).padBottom(20),
              const Text(
                "Étapes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ).padBottom(20),
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: context.height * 0.72,
                  child: ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.my_location, size: 27),
                        title: Text(
                          route.shortestLeg.startAddress,
                          style: const TextStyle(fontSize: 17),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Divider(color: Colors.grey, thickness: 1.5)
                          .padBottom(6),
                      ...route.shortestLeg.steps
                          .map((s) => _StepListTile(s))
                          .toList(),
                      ListTile(
                        leading: const Icon(Icons.location_on, size: 27),
                        title: Text(
                          route.shortestLeg.endAddress,
                          style: const TextStyle(fontSize: 17),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Divider(color: Colors.grey, thickness: 1.5)
                          .padBottom(6),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _StepListTile extends StatelessWidget {
  const _StepListTile(this.step);

  final DirectionLegStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: _NavigationIcon(step.maneuver ?? ""),
          // title: HtmlWidget(step.htmlInstructions),
          subtitle: step.maneuver == null
              ? null
              : Text("${step.distance.text} - ${step.duration.text}"),

          /* title: Text(
            parse(step.htmlInstructions).body!.text,
            style: const TextStyle(fontSize: 17),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ), */
        ),
        const Divider(color: Colors.grey, thickness: 1.5).padBottom(6),
      ],
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon(this.indication);

  final String indication;

  @override
  Widget build(BuildContext context) {
    if (indication.contains("turn-right")) {
      return const Icon(Icons.turn_right, size: 27);
    }

    if (indication.contains("roundabout-right")) {
      return const Icon(Icons.roundabout_right, size: 27);
    }

    if (indication.contains("turn-left")) {
      return const Icon(Icons.turn_left, size: 27);
    }

    if (indication.contains("roundabout-left")) {
      return const Icon(Icons.roundabout_left, size: 27);
    }

    return const Icon(Icons.drive_eta, size: 27);
  }
}
