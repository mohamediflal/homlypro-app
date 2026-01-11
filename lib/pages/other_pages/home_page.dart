import 'package:flutter/material.dart';
import 'ser_booking_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final services = [
      {'title': 'Cleaning', 'image': 'assets/service/clean.jpg'},
      {'title': 'Plumber', 'image': 'assets/service/plumber.jpg'},
      {'title': 'Electrician', 'image': 'assets/service/elec.png'},
      {'title': 'Painter', 'image': 'assets/service/paint.png'},
      {'title': 'Carpenter', 'image': 'assets/service/carpenter.png'},
      {'title': 'Gardener', 'image': 'assets/service/gardener.jpg'},
      {'title': 'Cook', 'image': 'assets/service/cook.png'},
      {'title': 'Driver', 'image': 'assets/service/driver.jpg'},
      {'title': 'Mechanic', 'image': 'assets/service/mech.jpg'},
      {'title': 'Tailor', 'image': 'assets/service/tailor.png'},
    ];

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Hello!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Welcome back Iflal',
                              style: TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      // Notification icon on the right
                      IconButton(
                        onPressed: () {
                          final notifications = [
                            {'title': 'Booking confirmed', 'subtitle': 'Your Cleaning booking is confirmed.'},
                            {'title': 'New message', 'subtitle': 'Service provider sent a message.'},
                            {'title': 'Reminder', 'subtitle': 'Your appointment is tomorrow.'},
                          ];

                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              title: const Text('Notifications'),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: 260,
                                child: ListView.separated(
                                  itemCount: notifications.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final n = notifications[i];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                        child: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
                                      ),
                                      title: Text(n['title']!),
                                      subtitle: Text(n['subtitle']!),
                                      onTap: () {
                                        // optionally handle tap on notification
                                        Navigator.of(ctx).pop();
                                      },
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Stack(
                          children: [
                            const Icon(Icons.notifications_none, size: 26, color: Colors.black87),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            

              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  'Which service do you need?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 40,
                    childAspectRatio: 1,
                    children: services.asMap().entries.map((entry) {
                      final index = entry.key;
                      final s = entry.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedIndex = index);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SerBookingPage(
                                serviceTitle: s['title']!,
                              ),
                            ),
                          ).then((_) {
                            if (mounted) setState(() => _selectedIndex = null);
                          });
                        },
                        child: _ServiceCard(
                          title: s['title']!,
                          imagePath: s['image']!,
                          isSelected: _selectedIndex == index,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;

  const _ServiceCard({required this.title, required this.imagePath, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF8A2BE2) : Colors.transparent,
          width: isSelected ? 2.0 : 0.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}