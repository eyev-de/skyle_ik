//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';

import '../../../widgets/app_page.dart';
import '../routes.dart';
import 'page_wrapper.dart';

class UnknownPage {
  static Page page() {
    return PageWrapper(child: widget());
  }

  static Widget widget() {
    return AppPage(
      route: Routes.currentRoute,
      title: 'Unknown Route',
      child: const Text('Unknown Route'),
    );
  }
}
