// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../custom_widgets/controllers/pagination_controller.dart'
//     show PaginationGetterReturn;
// import 'package:firebase_auth/firebase_auth.dart';
// import '../utilities/constants.dart' as c;
//
// class Group {
//   String id;
//   String name;
//   String description;
//   String lastActivity;
//   final String createdOn;
//   String icon;
//   List<String> members;
//   List<String> notSeen;
//
//   Group({
//     this.id = '',
//     required this.createdOn,
//     required this.name,
//     required this.lastActivity,
//     required this.icon,
//     required this.members,
//     required this.notSeen,
//     required this.description,
//   });
//   Map<String, dynamic> toMap() {
//     Map<String, dynamic> map = {};
//     map['name'] = name;
//     map['lastActivity'] = lastActivity;
//
//     map['members'] = members;
//     map['description'] = description;
//     map['icon'] = icon;
//     map['createdOn'] = createdOn;
//     return map;
//   }
//
//   static Group fromJson(Map<String, dynamic> json, String id) {
//     return Group(
//         createdOn: json['createdOn'],
//         name: json['name'],
//         lastActivity: json['lastActivity'],
//         icon: json['icon'],
//         members: json['members'].cast<String>(),
//         notSeen: (json['notSeen'] ?? []).cast<String>(),
//         description: json['description'],
//         id: id);
//   }
// }
//
// class GroupHandler {
//   Future<String> createGroup(Group group) async {
//     final firestore = FirebaseFirestore.instance;
//     final snapshot = await firestore.collection('groups').add(group.toMap());
//     return snapshot.id;
//   }
//
//   Future<void> updateGroupMembers(Group group, List<String> members) async {
//     final firestore = FirebaseFirestore.instance;
//
//     // Get the first document (there should be only one)
//
//     // Update the 'members' field in the document
//     await firestore.collection('groups').doc(group.id).update({
//       'members': members,
//     });
//
//     //print('Group members updated successfully.');
//   }
//
//   Future<Group?> getGroupFromId(String id) async {
//     final data =
//         await FirebaseFirestore.instance.collection('groups').doc(id).get();
//     final postData = data.data();
//     if (postData != null) {
//       return Group.fromJson(postData, data.id);
//     }
//     return null;
//   }
//
//   Future<PaginationGetterReturn> getGroups(dynamic time) async {
//     final user = FirebaseAuth.instance.currentUser!.uid;
//     final query = FirebaseFirestore.instance
//         .collection('groups')
//         .where('members', arrayContains: user)
//         .orderBy('lastActivity', descending: true);
//     //.where("author", isEqualTo: user)
//
//     late QuerySnapshot<Map<String, dynamic>> snapshot;
//     if (time == null) {
//       //initial data
//       snapshot = await query.limit(c.postsOnRefresh).get();
//     } else {
//       snapshot = await query.startAfter([time]).limit(c.postsOnRefresh).get();
//     }
//     final postList = snapshot.docs.map<Group>((doc) {
//       var data = doc.data();
//
//       return Group.fromJson(data, doc.id);
//     }).toList();
//     return PaginationGetterReturn(
//         end: (postList.length < c.postsOnRefresh), payload: postList);
//   }
// }
