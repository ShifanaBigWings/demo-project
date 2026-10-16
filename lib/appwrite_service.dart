
import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static final Client client = Client()
    ..setEndpoint('https://tor.cloud.appwrite.io/v1')
    ..setProject('6ad0b6b2002a80a7e167');

  static final Account account = Account(client);
}
