import 'package:firebase_database/firebase_database.dart';

class GetUser {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('users');

  Future<bool> loginUser(String role, String id, String password) async {
    try {
      // Determine the query field based on role
      String queryField = role == "student" ? "rollNo" : "staffId";

      // Query the users node to find the user by rollNo or staffId
      DataSnapshot snapshot =
          await _dbRef.orderByChild(queryField).equalTo(id).get();

      if (snapshot.exists) {
        // Extract the user data
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;

        // Iterate over the returned users (should be one in this case)
        for (var user in userData.values) {
          if (user["password"] == password) {
            print("$role logged in successfully!");
            return true;
          } else {
            print("Incorrect password!");
            return false;
          }
        }
      } else {
        print("$role with ID $id not found!");
        return false;
      }
    } catch (e) {
      print("Error logging in: $e");
      return false;
    }
    return false;
  }
}
