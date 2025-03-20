import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/recent_activity_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../custom_widgets/pagination.dart';
import '../custom_widgets/recent_activity_card.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => RecentActivtiyController(context: context),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => context.pop("poped"),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              AppLocalizations.of(context)!.recentActivity,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          body: PaginationPage(
              getter:
                  Provider.of<RecentActivtiyController>(context, listen: false)
                      .getActivity,
              card: recentActivityCardBuilder,
              startAfterQuery:
                  Provider.of<RecentActivtiyController>(context, listen: false)
                      .getNextQueryStart),
        );
      },
    );
  }
}
