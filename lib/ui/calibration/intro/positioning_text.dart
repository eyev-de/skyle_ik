// //  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
// //

// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:skyle_api/api.dart';

// import '../../../config/routes/main_routes.dart';
// import '../../../config/routes/routes.dart';
// import '../../../config/app_state.dart';
// import '../../../util/responsive.dart';
// import '../../main/theme.dart';

// class CalibrationIntroPositioningText extends ConsumerStatefulWidget {
//   const CalibrationIntroPositioningText({Key? key}) : super(key: key);

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _CalibrationIntroPositioningTextState();
// }

// class _CalibrationIntroPositioningTextState extends ConsumerState<CalibrationIntroPositioningText> {
//   String _text = '';
//   int _validatedCounter = 0;
//   int _negativeValidatedCounter = 0;
//   static const int countermax = 300;

//   @override
//   Widget build(BuildContext context) {
//     final position = ref.watch(AppState().positioningStreamProvider);

//     return position.when(
//       data: (value) {
//         if (value is DataFailed) return Container();
//         if (_validate(value.data!)) {
//           _text = 'Your position seems correct, please try not to move.';
//           _validatedCounter++;
//         } else {
//           _text = 'Your positioning seems off, please try to move into the center.';
//           _negativeValidatedCounter++;
//         }
//         if (_negativeValidatedCounter > 3) {
//           _negativeValidatedCounter = 0;
//           _validatedCounter = 0;
//         } else if (_validatedCounter > countermax) {
//           _validatedCounter = 0;
//           _negativeValidatedCounter = 0;
//           SchedulerBinding.instance.addPostFrameCallback((_) async {
//             if (Routes.currentRoute == MainRoutes.home.path) Routes.route(MainRoutes.capture.path);
//           });
//         } else if (value.data! is PositioningDistance && value.data!.distance == PositioningDistance.none) {
//           _text = 'Your positioning seems off, please try to move into the center.';
//           _negativeValidatedCounter = 0;
//           _validatedCounter = 0;
//         }

//         return Flexible(
//           child: AnimatedContainer(
//             padding: Responsive.padding(context, const EdgeInsets.fromLTRB(0, 40, 0, 0)),
//             duration: const Duration(milliseconds: 300),
//             child: Text(
//               _text,
//               style: SkyleTheme.of(context).primaryTextTheme.headline1,
//             ),
//           ),
//         );
//       },
//       loading: () => Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               CircularProgressIndicator(),
//             ],
//           ),
//         ],
//       ),
//       error: (e, _) => Center(
//         child: Text(
//           e.toString(),
//           style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.red),
//         ),
//       ),
//     );
//   }

//   bool _validate(PositioningMessage positioning) {
//     if (positioning.quality.depth > -10 &&
//         positioning.quality.depth < 30 &&
//         positioning.quality.horizontal > -20 &&
//         positioning.quality.horizontal < 20 &&
//         positioning.quality.vertical > -20 &&
//         positioning.quality.vertical < 20) {
//       return true;
//     }
//     return false;
//   }
// }
