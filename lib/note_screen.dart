import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'appointmentParams.dart';
import 'detail_page.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> appointments = [];
  final _formKey = GlobalKey<FormState>();
  final _doctorController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _reasonController = TextEditingController();
  late DatabaseReference _appointmentsRef;

  @override
  void initState() {
    super.initState();
    _appointmentsRef = FirebaseDatabase.instance.ref('appointments');
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final snapshot = await _appointmentsRef.get();
      if (snapshot.exists) {
        setState(() {
          final data = snapshot.value as Map<dynamic, dynamic>?;
          appointments = data?.entries
              .map((e) => Appointment.fromJson(e.value, e.key))
              .toList() ??
              [];
        });
      }
    } catch (e) {
      print('Error loading appointments: $e');
    }
  }

  Future<void> _saveAppointment(Appointment appointment) async {
    try {
      if (appointment.key == null) {
        final newRef = _appointmentsRef.push();
        await newRef.set(appointment.toJson());
        appointment.key = newRef.key;
      } else {
        await _appointmentsRef.child(appointment.key!).set(appointment.toJson());
      }
    } catch (e) {
      print('Error saving appointment: $e');
    }
  }

  Future<void> _deleteAppointment(String key) async {
    try {
      await _appointmentsRef.child(key).remove();
      setState(() {
        appointments.removeWhere((appointment) => appointment.key == key);
      });
    } catch (e) {
      print('Error deleting appointment: $e');
    }
  }

  void _showAddEditDialog({Appointment? appointment}) {
    if (appointment != null) {
      _doctorController.text = appointment.doctorName;
      _dateController.text = appointment.date;
      _timeController.text = appointment.time;
      _reasonController.text = appointment.reason;
    } else {
      _doctorController.clear();
      _dateController.clear();
      _timeController.clear();
      _reasonController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(appointment == null ? 'Новая запись' : 'Редактировать запись'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _doctorController,
                    decoration: const InputDecoration(labelText: 'Имя врача'),
                    validator: (value) => value!.isEmpty ? 'Введите имя врача' : null,
                  ),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Дата (ДД.ММ.ГГГГ)'),
                    validator: (value) => value!.isEmpty ? 'Введите дату' : null,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        _dateController.text =
                        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                      }
                    },
                  ),
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(labelText: 'Время (ЧЧ:ММ)'),
                    validator: (value) => value!.isEmpty ? 'Введите время' : null,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        _timeController.text = time.format(context);
                      }
                    },
                  ),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(labelText: 'Причина визита'),
                    validator: (value) => value!.isEmpty ? 'Введите причину' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newAppointment = Appointment(
                    doctorName: _doctorController.text,
                    date: _dateController.text,
                    time: _timeController.text,
                    reason: _reasonController.text,
                    key: appointment?.key,
                  );
                  setState(() {
                    if (appointment == null) {
                      appointments.add(newAppointment);
                    } else {
                      final index = appointments.indexWhere((a) => a.key == appointment.key);
                      appointments[index] = newAppointment;
                    }
                  });
                  _saveAppointment(newAppointment);
                  Navigator.pop(context);
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _goToAboutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user greeting and avatar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://example.com/user.jpg'),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, WelcomeBack',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Appointments section header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Appointments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // List of appointments
            Expanded(
              child: appointments.isEmpty
                  ? const Center(
                child: Text(
                  'No appointments yet. Add one!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    elevation: 0,
                    color: Colors.blue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                                'https://example.com/doctor.jpg'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.doctorName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                                Text(
                                  '${appointment.date} ${appointment.time}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  )),
                                Text(
                                  appointment.reason,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ))])),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(
                                          appointment: appointment),
                                    ));
                                  },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                child: const Text(
                                  'INFO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.grey),
                                onPressed: () =>
                                    _showAddEditDialog(appointment: appointment),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.grey),
                                onPressed: () =>
                                    _deleteAppointment(appointment.key!),
                              )])])));
                }))])),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 0) {
            // Navigate to profile
          } else if (index == 2) {
            _goToAboutPage();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}