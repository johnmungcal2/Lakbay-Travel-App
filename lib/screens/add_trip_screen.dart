import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lesson_7/models/trip_model.dart';
import 'package:lesson_7/provider/trip_provider.dart';
import 'package:intl/intl.dart';
import 'package:lesson_7/data/countries.dart';

class AddTripScreen extends HookConsumerWidget {
  final Trip? trip;

  const AddTripScreen({super.key, this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();

    final tripNameController =
        useTextEditingController(text: trip?.tripName ?? '');
    final destinationController =
        useTextEditingController(text: trip?.destination ?? '');
    final descriptionController =
        useTextEditingController(text: trip?.description ?? '');
    final startDateController = useTextEditingController(
      text: trip?.startDate != null
          ? DateFormat.yMMMd().format(trip!.startDate)
          : '',
    );
    final endDateController = useTextEditingController(
      text:
          trip?.endDate != null ? DateFormat.yMMMd().format(trip!.endDate) : '',
    );

    final dates = useState<Map<String, DateTime?>>({
      'startDate': trip?.startDate,
      'endDate': trip?.endDate,
    });

    Future<void> pickDate(BuildContext context, bool isStartDate) async {
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF8e6eeb),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (selectedDate != null) {
        dates.value = {
          ...dates.value,
          isStartDate ? 'startDate' : 'endDate': selectedDate,
        };

        final formatted = DateFormat.yMMMd().format(selectedDate);
        if (isStartDate) {
          startDateController.text = formatted;
        } else {
          endDateController.text = formatted;
        }
      }
    }

    final isEditing = trip?.firebaseKey != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Trip' : 'Add Trip'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: tripNameController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Trip Name',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF808080),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFF4644db),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a trip name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: destinationController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Destination',
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF808080),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1,
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFF4644db),
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () async {
                      final selectedCountry = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Select a Destination'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: countries.length,
                                itemBuilder: (context, index) {
                                  final country = countries[index];
                                  return ListTile(
                                    title: Text(
                                      country,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop(country);
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );

                      if (selectedCountry != null) {
                        destinationController.text = selectedCountry;
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select or enter a destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: startDateController,
                readOnly: true,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF808080),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFF4644db),
                      width: 2,
                    ),
                  ),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => pickDate(context, true),
                validator: (value) {
                  if (dates.value['startDate'] == null) {
                    return 'Please select a start date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: endDateController,
                readOnly: true,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF808080),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFF4644db),
                      width: 2,
                    ),
                  ),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => pickDate(context, false),
                validator: (value) {
                  if (dates.value['endDate'] == null) {
                    return 'Please select an end date';
                  }
                  if (dates.value['startDate'] != null &&
                      dates.value['endDate']!
                          .isBefore(dates.value['startDate']!)) {
                    return 'End date cannot be before start date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF808080),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFFD8D8D8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xFF4644db),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4644db),
                    Color(0xFF8e6eeb),
                    Color(0xFFe49efc),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final newTrip = Trip(
                      tripName: tripNameController.text,
                      destination: destinationController.text,
                      startDate: dates.value['startDate']!,
                      endDate: dates.value['endDate']!,
                      description: descriptionController.text,
                      firebaseKey: trip?.firebaseKey,
                    );

                    if (!isEditing) {
                      await ref.read(tripProvider.notifier).addTrip(newTrip);
                    } else {
                      await ref.read(tripProvider.notifier).updateTrip(newTrip);
                    }

                    GoRouter.of(context).pop();
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  foregroundColor: Colors.white,
                  overlayColor: Colors.white24,
                ),
                child: Text(
                  isEditing ? 'Update Trip' : 'Save Trip',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4644db),
                    Color(0xFF8e6eeb),
                    Color(0xFFe49efc),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Return',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
