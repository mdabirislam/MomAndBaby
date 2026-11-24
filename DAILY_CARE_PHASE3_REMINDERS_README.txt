MOM & BABY — DAILY CARE PHASE 3: REMINDERS

Included:
- Local notification service for medicine, appointments, and optional water reminders.
- Medicine reminders are scheduled for the next 14 days and refreshed when the app starts.
- Medicine notifications are cancelled/rescheduled when a medicine is edited, paused, or deleted.
- Appointment list: add, edit, complete, delete; reminders are scheduled 1 day and 2 hours before.
- Optional water reminders: 9 AM to 9 PM every 2 hours. This is not a hydration target.
- Android notification/exact-alarm/boot permissions and receivers.
- Timezone currently set to Asia/Dhaka.

IMPORTANT:
1. Extract the patch into the Flutter project root, preserving folder structure.
2. Run `flutter pub get` because timezone was added as a direct dependency.
3. Run `dart format` on the listed Dart paths.
4. Run `flutter analyze` and `flutter test`.
5. Install on an Android phone. Grant Notification permission and Exact Alarm permission when prompted.
6. In Planner > Reminder Settings, use the permission button to enable medicine/appointment reminders. Water reminders can be enabled separately.

LIMITATIONS:
- Medicine reminders are queued 14 days ahead to avoid exceeding Android's pending alarm limits. They are refreshed whenever the app is opened.
- Android battery optimization on some manufacturers can delay alarms. The app cannot override those system restrictions.
- Timezone is currently Asia/Dhaka; device-timezone auto-detection is a later improvement.
- This feature only reminds about user-entered schedules. It does not recommend medicines, doses, or treatment.
