// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:untitled_app/localization/generated/app_localizations.dart';
// import 'package:untitled_app/providers/group_provider.dart';
// import 'package:untitled_app/views/create_group_page.dart';
// import 'package:untitled_app/widgets/loading_spinner.dart';
//
// class AddPeoplePage extends ConsumerWidget {
//   final String id;
//   const AddPeoplePage({super.key, required this.id});
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final asyncGroup = ref.watch(groupProvider(id));
//     return asyncGroup.when(
//       data: (group) {
//         final members = ListenableSet(group.members);
//         return Scaffold(
//             appBar: PreferredSize(
//               preferredSize: Size.fromHeight(50),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextButton(
//                       onPressed: () {
//                         context.pop();
//                       },
//                       child: Text(AppLocalizations.of(context)!.cancel)),
//                   TextButton(
//                       onPressed: () async {
//                         ref
//                             .read(groupProvider(id).notifier)
//                             .updateGroupMembers([...members.set]);
//                         context.pop();
//                       },
//                       child: Text(AppLocalizations.of(context)!.done)),
//                 ],
//               ),
//             ),
//             body: AddPeople(
//               selectedPeople: members,
//             ));
//       },
//       loading: () => Center(
//         child: LoadingSpinner(),
//       ),
//       error: (_, __) => SizedBox(),
//     );
//   }
// }
