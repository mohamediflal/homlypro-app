import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';

class SerBookingPage extends StatefulWidget {
  final String? serviceTitle;

  const SerBookingPage({Key? key, this.serviceTitle}) : super(key: key);

  @override
  State<SerBookingPage> createState() => _SerBookingPageState();
}

class _SerBookingPageState extends State<SerBookingPage> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? phoneError;

  bool _isPhoneValid(String p) {
    final digits = p.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15;
  }

  List<DateTime> getWeekDates(DateTime from) {
    final start = DateTime(from.year, from.month, from.day);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  List<String> generateTimeSlots({int startHour = 9, int endHour = 18, int stepMinutes = 30}) {
    final slots = <String>[];
    for (var hour = startHour; hour < endHour; hour++) {
      for (var m = 0; m < 60; m += stepMinutes) {
        final hh = hour.toString().padLeft(2, '0');
        final mm = m.toString().padLeft(2, '0');
        slots.add('$hh:$mm');
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getWeekDates(selectedDate);
    final timeSlots = generateTimeSlots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.serviceTitle ?? 'Book Service'),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 205, 187, 223),
                Color.fromARGB(255, 143, 171, 220),
              ],
            ),
          ),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Date and Time',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Use a ListView inside Expanded so the scrollable content has proper
              // scroll physics and doesn't cause RenderFlex overflow on small screens.
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 120 + MediaQuery.of(context).viewInsets.bottom),
                  children: [
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_monthName(selectedDate.month)} ${selectedDate.year}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.calendar_today_outlined),
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (picked != null) setState(() => selectedDate = picked);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                              SizedBox(
                                // increased height slightly to account for font scaling and padding
                                height: 104,
                                child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final d = weekDates[index];
                                  final isSelected = _isSameDate(d, selectedDate);
                                  return GestureDetector(
                                    onTap: () => setState(() => selectedDate = d),
                                    child: Container(
                                        width: 72,
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        decoration: BoxDecoration(
                                        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _weekdayShort(d.weekday),
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : Colors.black87,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.white24 : Colors.transparent,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              d.day.toString(),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemCount: weekDates.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text(' Time', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: timeSlots.map((t) {
                          final isSelected = selectedTime == t;
                          return ChoiceChip(
                            label: Text(t),
                            selected: isSelected,
                            onSelected: (_) => setState(() => selectedTime = t),
                            selectedColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Customer input fields: description, address, phone
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Describe what you need', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              hintText: 'Simply describe your need here...',
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('Address', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: addressController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              hintText: 'Your address',
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              onChanged: (v) {
                                if (phoneError != null && _isPhoneValid(v)) {
                                  setState(() => phoneError = null);
                                }
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                hintText: 'e.g. +94 712345678',
                                errorText: phoneError,
                              ),
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedTime != null) ? _onBook : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3A3A),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void _onBook() async {
    final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final phone = phoneController.text.trim();
    final desc = descriptionController.text.trim();
    final addr = addressController.text.trim();

    if (!_isPhoneValid(phone)) {
      setState(() => phoneError = 'Enter a valid phone number');
      return;
    }

    setState(() => phoneError = null);

    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to book a service')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Processing your booking...'),
          ],
        ),
      ),
    );

    try {
      final firestoreService = FirestoreService();
      final notificationService = NotificationService();

      // Create booking in Firestore
      final bookingId = await firestoreService.createBooking(
        userId: user.uid,
        serviceType: widget.serviceTitle ?? 'Service',
        serviceDescription: desc,
        bookingDate: selectedDate,
        address: addr,
        city: 'Default City', // You can make this dynamic
        phoneNumber: phone,
        estimatedCost: 0.0, // Set based on service pricing
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (bookingId != null) {
        // Send confirmation notification
        await notificationService.sendNotificationToUser(
          userId: user.uid,
          title: 'Booking Confirmed',
          body: '${widget.serviceTitle ?? 'Service'} booked for $dateStr at $selectedTime',
          notificationType: 'booking_confirmed',
          data: {'bookingId': bookingId},
        );

    // Show a confirmation dialog styled like the provided image.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: Center(
                    child: Icon(Icons.check, size: 40, color: Color(0xFF8A2BE2)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Booking Successful',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                      '${widget.serviceTitle ?? 'Service'} booked on $dateStr at $selectedTime',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A3A3A),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Go to home', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create booking. Please try again.')),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekdayShort(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(w - 1) % 7];
  }

  String _monthName(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[m - 1];
  }
}
