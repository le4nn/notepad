import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'appointmentParams.dart';

class DetailPage extends StatelessWidget {
  final Appointment appointment;

  const DetailPage({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали записи'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Врач: ${appointment.doctorName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Дата: ${appointment.date}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Время: ${appointment.time}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Причина: ${appointment.reason}',
              style: const TextStyle(fontSize: 16),
            )])));
  }
}