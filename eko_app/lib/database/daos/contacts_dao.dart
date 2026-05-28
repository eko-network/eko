import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:eko_app/database/tables/contacts.dart';

import '../database.dart';

part '../../generated/database/daos/contacts_dao.g.dart';

@DriftAccessor(tables: [Contacts])
class ContactsDao extends DatabaseAccessor<AppDatabase>
    with _$ContactsDaoMixin {
  ContactsDao(super.db);

  // Future<void> insertNewContact(Person contact) async {
  //   final companion = ContactsCompanion(
  //     id: Value(contact.id),
  //     preferredUsername: Value(contact.preferredUsername),
  //     inbox: Value(contact.inbox),
  //     outbox: Value(contact.outbox),
  //     devicesEndpoint: Value(contact.devicesEndpoint),
  //     profilePicture: Value(contact.profilePicture),
  //   );
  //   await into(contacts).insert(companion);
  // }

  Future<List<Person>> getContacts() async {
    return select(contacts).get();
  }

  Future<Person?> getContactById(Uri id) {
    return (select(
      contacts,
    )..where((c) => c.id.equals(id.toString())))
        .getSingleOrNull();
  }
}
