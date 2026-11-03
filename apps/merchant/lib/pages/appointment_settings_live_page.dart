import 'package:flutter/material.dart';

import 'appointment_settings_template.dart';
import 'booking_resources_page.dart';

class AppointmentSettingsLivePage extends StatelessWidget {
  const AppointmentSettingsLivePage({super.key});
  @override
  Widget build(BuildContext context) => BookingLiveHost(
    mode: 'settings',
    builder: (c) => AppointmentSettingsTemplate(c: c),
  );
}
