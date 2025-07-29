import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/supabase/index.dart';

class MaxIncidentsForPlan {

  Future<int?> getTotalDailyIncidents(String userId) async {
    // get user by default number of incidents
    final response = await supabase
        .from('user_daily_incident')
        .select("n_daily_incidents")
        .eq('user_id', userId)
        .maybeSingle();
    // get user paid incidents (if not bought are 0)
    print(response?['paid_incidents']);
    return response?['n_daily_incidents'] as int?;
  }

  Future<void> insertUserInMaxIncidentTable (String userId) async {
    await supabase
        .from("user_daily_incident")
        .insert({
            "user_id": userId,
            "n_daily_incidents": 3,
            "last_update": DateTime.now()
        });
  }
  // mi occorre solo questa funzione e non una con i plan perchè a me basta aggiornare il numero di incidenti se acquista non in base al piano
  // per resettarli al numero base: 5 basta richiamare questa funzione e mettere come parametro 5
  Future<void> editUserMaxIncidentsNumber (int new_number, String userId) async {
    await supabase
          .from("user_daily_incident")
          .update(
            {
              "n_daily_incidents": new_number
            }
          ).eq("user_id", userId);
  }

  Future<void> deleteUserMaxIncidentsNumber (String userId) async {
    await supabase.from("user_daily_incident").delete().eq("user_id", userId);
  }

  Future<bool> checkIfUserExists(String userId) async {
    final response = await supabase
        .from('user_daily_incident')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();
    return response != null;
  }

  Future<DateTime?> getLastUserIncidentsUpdate (String userId) async {
    final response =  await supabase.from("user_daily_incident")
                  .select("last_update")
                  .eq("user_id", userId)
                  .maybeSingle();
    final lastUpdatedString =  response?['last_update'] as String?;
    return lastUpdatedString != null ? DateTime.parse(lastUpdatedString) : null;
  }

  Future<void> updateLastUserUpdate(String userId) async {
    final now = DateTime.now();
    return await supabase.from("user_daily_incident").update({
      "last_update": now
    }).eq("user_id", userId);
  }

  Future<void> decrementIncidents(String userId) async {
    final current = await getTotalDailyIncidents(userId);
    if (current != null && current > 0) {
      await supabase
          .from("user_daily_incident")
          .update({
        "n_daily_incidents": current - 1,
      })
          .eq("user_id", userId);
    }
  }

}

final maxIncidentsprovider = Provider<MaxIncidentsForPlan>((ref) {
  return MaxIncidentsForPlan();
});