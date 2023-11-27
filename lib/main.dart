import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking App',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: ParkingScreen(),
    );
  }
}

class ParkingScreen extends StatefulWidget {
  @override
  _ParkingScreenState createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  int _currentIndex = 0; // Index for the current selected tab
  List<ParkingSlot> parkingSlots = [];
  int totalSlots = 0; // Initial total number of slots
  String companyName = '';
  String contactNumber = '';
  List<SlotDetails> dailyOccupiedSlots = [];
  List<SlotDetails> dailyReleasedSlots = [];
  List<SlotDetails> weeklyOccupiedSlots = [];
  List<SlotDetails> weeklyReleasedSlots = [];
  String vehicleType = '';
  double perHourCharges = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize parking slots (replace with actual data)
    parkingSlots = List.generate(
        totalSlots, (index) => ParkingSlot(id: index + 1, isAvailable: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Easy Parking'),
        actions: [
          if (_currentIndex == 1)
            IconButton(
              icon: Icon(Icons.print),
              onPressed: () {
                _printOccupiedSlots();
              },
            ),
          if (_currentIndex == 1)
            IconButton(
              icon: Icon(Icons.report),
              onPressed: () {
                _showReports();
              },
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 2) {
      // Account tab
      return _buildAccountTab();
    }

    List<ParkingSlot> displayedSlots = _currentIndex == 1
        ? parkingSlots.where((slot) => !slot.isAvailable).toList()
        : parkingSlots;

    return ListView.builder(
      itemCount: displayedSlots.length,
      itemBuilder: (context, index) {
        final slot = displayedSlots[index];
        return ListTile(
          title: Text('Slot ${slot.id}'),
          subtitle: _buildSlotSubtitle(slot),
          onTap: () {
            if (_currentIndex == 0 && slot.isAvailable) {
              _showVehicleDetailsDialog(slot);
            } else if (_currentIndex == 1 && !slot.isAvailable) {
              _releaseSlot(slot);
            }
          },
          trailing: !slot.isAvailable
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.print),
                      onPressed: () {
                        _printOccupiedSlotDetails(slot);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        _releaseSlot(slot);
                      },
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildSlotSubtitle(ParkingSlot slot) {
    if (slot.isAvailable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available'),
          if (slot.vehicleType != null)
            Text('Vehicle Type: ${slot.vehicleType!}'),
          if (slot.perHourCharges != null)
            Text('Per Hour Charges: \$${slot.perHourCharges.toString()}'),
        ],
      );
    } else {
      return Text('Occupied');
    }
  }

  Widget _buildAccountTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total Slots: $totalSlots',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showAddVehicleTypeDialog();
                },
                child: Text('Increase Slots'),
              ),
              ElevatedButton(
                onPressed: () {
                  _decreaseTotalSlots();
                },
                child: Text('Decrease Slots'),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(labelText: 'Company Name'),
            onChanged: (value) {
              setState(() {
                companyName = value;
              });
            },
          ),
          SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(labelText: 'Contact Number'),
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              setState(() {
                contactNumber = value;
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _saveCompanyDetails();
            },
            child: Text('Save Company Details'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddVehicleTypeDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Increase Slot with Vehicle Type'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Vehicle Type'),
                  onChanged: (value) {
                    vehicleType = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Per Hour Charges'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    perHourCharges = double.parse(value);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle saving the entered details and increasing slot
                _increaseSlotWithVehicleType(vehicleType, perHourCharges);
                Navigator.of(context).pop();
              },
              child: Text('Save and Increase Slot'),
            ),
          ],
        );
      },
    );
  }

  void _increaseSlotWithVehicleType(String vehicleType, double perHourCharges) {
    // Increase the total slots
    setState(() {
      totalSlots++;
      parkingSlots.add(
        ParkingSlot(
          id: totalSlots,
          isAvailable: true,
          vehicleType: vehicleType,
          perHourCharges: perHourCharges,
        ),
      );
    });
  }

  Future<void> _showVehicleDetailsDialog(ParkingSlot slot) async {
    DateTime? selectedEntryDate;
    DateTime? selectedArrivalDate;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Vehicle Details'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Vehicle Number'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Vehicle Make'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Vehicle Name'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Owner Name'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Owner Address'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Parked Time'),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      // Handle the selected time
                      print('Parked Time: ${pickedTime.format(context)}');
                    }
                  },
                ),
                ListTile(
                  title: Text('Entry Date'),
                  subtitle: Text(
                    selectedEntryDate != null
                        ? '${selectedEntryDate!.toLocal()}'.split(' ')[0]
                        : 'Select a date',
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedEntryDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedEntryDate) {
                      setState(() {
                        selectedEntryDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text('Expected Return Date'),
                  subtitle: Text(
                    selectedArrivalDate != null
                        ? '${selectedArrivalDate!.toLocal()}'.split(' ')[0]
                        : 'Select a date',
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedArrivalDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedArrivalDate) {
                      setState(() {
                        selectedArrivalDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle saving the entered details and reserving the slot
                _reserveSlot(slot);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _reserveSlot(ParkingSlot slot) {
    // Handle reserving the slot and saving the entered details
    setState(() {
      slot.isAvailable = false;
      _saveDailyOccupiedSlot(slot);
    });
  }

  void _releaseSlot(ParkingSlot slot) {
    // Handle releasing the occupied slot
    setState(() {
      slot.isAvailable = true;
      _saveDailyReleasedSlot(slot);
    });
  }

  void _saveCompanyDetails() {
    // Handle saving the company details
    print('Company Name: $companyName, Contact Number: $contactNumber');
  }

  void _printOccupiedSlotDetails(ParkingSlot slot) {
    // Implement the logic to print the details of the occupied slot
    print('Printing details for Occupied Slot ${slot.id}');
    print('Vehicle Number: ...'); // Add actual details here
    print('Vehicle Make: ...');
    print('Vehicle Name: ...');
    print('Owner Name: ...');
    print('Owner Address: ...');
    print('Entry Date: ...');
    print('Expected Arrival Date: ...');
  }

  void _printOccupiedSlots() {
    // Handle the printing logic for occupied slots
    print('Printing Occupied Slots...');
    // You can use a printer package or send the data to a printer here
  }

  void _showReports() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reports'),
          content: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  _printDailyReport('Occupied Slots', dailyOccupiedSlots);
                },
                child: Text('Print Daily Occupied Slots Report'),
              ),
              ElevatedButton(
                onPressed: () {
                  _printDailyReport('Released Slots', dailyReleasedSlots);
                },
                child: Text('Print Daily Released Slots Report'),
              ),
              ElevatedButton(
                onPressed: () {
                  _printWeeklyReport('Occupied Slots', weeklyOccupiedSlots);
                },
                child: Text('Print Weekly Occupied Slots Report'),
              ),
              ElevatedButton(
                onPressed: () {
                  _printWeeklyReport('Released Slots', weeklyReleasedSlots);
                },
                child: Text('Print Weekly Released Slots Report'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveDailyOccupiedSlot(ParkingSlot slot) {
    // Save the details of the occupied slot for the current day
    final details = SlotDetails(
      slotId: slot.id,
      action: 'Occupied',
      dateTime: DateTime.now(),
    );
    dailyOccupiedSlots.add(details);
    print('Saved Daily Occupied Slot Details: $details');
  }

  void _saveDailyReleasedSlot(ParkingSlot slot) {
    // Save the details of the released slot for the current day
    final details = SlotDetails(
      slotId: slot.id,
      action: 'Released',
      dateTime: DateTime.now(),
    );
    dailyReleasedSlots.add(details);
    print('Saved Daily Released Slot Details: $details');
  }

  void _printDailyReport(String title, List<SlotDetails> slots) {
    print('Printing $title Report for the Day:');
    for (final slot in slots) {
      print('Slot ${slot.slotId} - ${slot.action} at ${slot.dateTime}');
    }
  }

  void _printWeeklyReport(String title, List<SlotDetails> slots) {
    print('Printing $title Report for the Week:');
    for (final slot in slots) {
      print('Slot ${slot.slotId} - ${slot.action} at ${slot.dateTime}');
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _increaseTotalSlots() {
    setState(() {
      totalSlots++;
      parkingSlots.add(ParkingSlot(id: totalSlots, isAvailable: true));
    });
  }

  void _decreaseTotalSlots() {
    if (totalSlots > 0) {
      setState(() {
        parkingSlots.removeLast();
        totalSlots--;
      });
    }
  }
}

String generatePrintContent(List<SlotDetails> slots) {
  // Generate HTML content here based on the slots data
  String htmlContent = '<html><body>';
  for (final slot in slots) {
    htmlContent +=
        'Slot ${slot.slotId} - ${slot.action} at ${slot.dateTime}<br>';
  }
  htmlContent += '</body></html>';
  return htmlContent;
}

class ParkingSlot {
  final int id;
  bool isAvailable;
  String? vehicleType;
  double? perHourCharges;

  ParkingSlot({
    required this.id,
    required this.isAvailable,
    this.vehicleType,
    this.perHourCharges,
  });
}

class SlotDetails {
  final int slotId;
  final String action; // 'Occupied' or 'Released'
  final DateTime dateTime;

  SlotDetails({
    required this.slotId,
    required this.action,
    required this.dateTime,
  });
}

class Rate {
  String vehicleType;
  double charges;

  Rate({required this.vehicleType, required this.charges});
}
