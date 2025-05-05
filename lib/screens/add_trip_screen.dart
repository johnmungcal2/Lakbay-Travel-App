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
      );

      if (selectedDate != null) {
        dates.value = {
          ...dates.value,
          isStartDate ? 'startDate' : 'endDate': selectedDate,
        };

        final formatted = selectedDate.toLocal().toString().split(' ')[0];
        if (isStartDate) {
          startDateController.text = formatted;
        } else {
          endDateController.text = formatted;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(trip == null ? 'Add Trip' : 'Edit Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: tripNameController,
                decoration: const InputDecoration(
                  labelText: 'Trip Name',
                  border: OutlineInputBorder(),
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
                decoration: InputDecoration(
                  labelText: 'Destination',
                  border: const OutlineInputBorder(),
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
                                    title: Text(country),
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
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
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

                    if (trip == null) {
                      await ref.read(tripProvider.notifier).addTrip(newTrip);
                    } else {
                      await ref.read(tripProvider.notifier).updateTrip(newTrip);
                    }

                    GoRouter.of(context).pop();
                  }
                },
                child: Text(trip == null ? 'Save Trip' : 'Update Trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
