# impaxt_alert

An app to notify your contacts in case of an emergency.
How the app works: If an accident is detected via the phone's accelerometers and gyroscopes, a full-screen notification is sent asking the user (both verbally for the hearing impaired and through text on the app) if everyone present is OK. If the answer is "yes," the app saves the accident information and adds it to the history (which can be saved on Supabase if the user is logged in). Otherwise, if the user presses "no" or there is no response within 30 seconds, the app sends a WhatsApp message to all contacts added to the contact list.
