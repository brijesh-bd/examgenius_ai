import 'package:flutter/material.dart';

import '../../core/utils/l10n_ext.dart';
import '../../core/widgets/app_widgets.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, this.title});
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(title ?? l10n.comingSoon)),
      body: Center(
        child: StateMessage(
          icon: Icons.construction_rounded,
          title: l10n.comingSoon,
          body: l10n.comingSoonBody,
        ),
      ),
    );
  }
}
