// // function to show bottom sheet with map events
// import 'package:care_taker/exports/exports.dart';

// void mapEvents(BuildContext context){
//   showModalBottomSheet(context: context, builder:(context){
//     return     BottomSheet(
//                 onClosing: () {},
//                 builder: (context) {
//                   return Container(
//                     padding: const EdgeInsets.all(12),
//                     color: Colors.white,
//                     height: 150,
//                     width: context.width,
//                     child: _directions == null
//                         ? const Center(child: CircularProgressIndicator())
//                         : Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "${shortestRoute.shortestLeg.duration.text} (${shortestRoute.shortestLeg.distance.text})",
//                                 style: const TextStyle(fontSize: 24),
//                               ),
//                               Text(
//                                 "Route la plus rapide selon l'état actuel de la circulation (${shortestRoute.summary}).",
//                                 style: const TextStyle(fontSize: 15),
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   OutlinedButton(
//                                     style: OutlinedButton.styleFrom(
//                                       backgroundColor: Colors.black45,
//                                       elevation: 6,
//                                       shape: const StadiumBorder(),
//                                     ),
//                                     onPressed: null,
//                                     child: const Row(
//                                       children: [
//                                         Icon(
//                                           Icons
//                                               .keyboard_double_arrow_right_outlined,
//                                           size: 15,
//                                           color: Colors.white,
//                                         ),
//                                         Text(
//                                           "Apercu",
//                                           style: TextStyle(
//                                             fontSize: 15,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   OutlinedButton(
//                                     style: OutlinedButton.styleFrom(
//                                       backgroundColor: Colors.green[900],
//                                       elevation: 6,
//                                       shape: const StadiumBorder(),
//                                     ),
//                                     onPressed: () => pushTo(
//                                       context,
//                                       RouteStepsView(route: shortestRoute),
//                                     ),
//                                     child: const Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceAround,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.list,
//                                           color: Colors.white,
//                                         ),
//                                         Text(
//                                           "Étapes",
//                                           style: TextStyle(
//                                             fontSize: 15,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   OutlinedButton(
//                                     style: OutlinedButton.styleFrom(
//                                       backgroundColor: Colors.black45,
//                                       elevation: 6,
//                                       shape: const StadiumBorder(),
//                                     ),
//                                     onPressed: null,
//                                     child: const Row(
//                                       children: [
//                                         Icon(
//                                           CupertinoIcons.pin,
//                                           size: 15,
//                                           color: Colors.white,
//                                         ),
//                                         Text(
//                                           "Épinglé",
//                                           style: TextStyle(
//                                             fontSize: 15,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                   );
//                 },
//               );
      
//   })
// }