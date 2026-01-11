import 'package:flutter/material.dart';

/// Simple admin page (mock data) with three tabs:
/// - Users: list users and disable/enable
/// - Bookings: list bookings and view details
/// - Services: list services and toggle availability
class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data
  final List<Map<String, dynamic>> _users = List.generate(
    6,
    (i) => {
      'id': i + 1,
      'name': 'User ${i + 1}',
      'email': 'user${i + 1}@example.com',
      'active': true,
    },
  );

  final List<Map<String, dynamic>> _services = [
    {'id': 1, 'name': 'Cleaning', 'available': true},
    {'id': 2, 'name': 'Plumber', 'available': true},
    {'id': 3, 'name': 'Electrician', 'available': true},
  ];

  final List<Map<String, dynamic>> _bookings = List.generate(
    8,
    (i) => {
      'id': 100 + i,
      'user': 'User ${i % 6 + 1}',
      'service': i % 3 == 0 ? 'Cleaning' : (i % 3 == 1 ? 'Plumber' : 'Electrician'),
      'date': DateTime.now().add(Duration(days: i)).toString().split(' ')[0],
      'status': (i % 3 == 0) ? 'Pending' : 'Confirmed',
      'notes': 'Notes for booking ${i + 1}',
    },
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        flexibleSpace: Container(
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
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Users'), Tab(text: 'Bookings'), Tab(text: 'Services')],
        ),
      ),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildUsersTab(),
            _buildBookingsTab(),
            _buildServicesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const Divider(height: 8),
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          leading: CircleAvatar(child: Text(user['name'][5])),
          title: Text(user['name']),
          subtitle: Text(user['email']),
          trailing: Switch(
            value: user['active'] as bool,
            onChanged: (v) {
              setState(() => user['active'] = v);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user['name']} is now ${v ? 'active' : 'disabled'}')),
              );
            },
          ),
          onTap: () => _showUserDetail(user),
        );
      },
    );
  }

  Widget _buildBookingsTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _bookings.length,
      separatorBuilder: (_, __) => const Divider(height: 8),
      itemBuilder: (context, index) {
        final b = _bookings[index];
        return ListTile(
          leading: CircleAvatar(child: Text(b['service'][0])),
          title: Text('${b['service']} — ${b['user']}'),
          subtitle: Text('Date: ${b['date']} • Status: ${b['status']}'),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showBookingDetail(b),
          ),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _services.length,
      separatorBuilder: (_, __) => const Divider(height: 8),
      itemBuilder: (context, index) {
        final s = _services[index];
        return ListTile(
          title: Text(s['name']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s['available'] ? 'Available' : 'Unavailable', style: TextStyle(color: s['available'] ? Colors.green : Colors.red)),
              const SizedBox(width: 12),
              Switch(
                value: s['available'] as bool,
                onChanged: (v) {
                  setState(() => s['available'] = v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${s['name']} is now ${v ? 'available' : 'unavailable'}')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserDetail(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(user['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Email: ${user['email']}'), const SizedBox(height: 8), Text('Status: ${user['active'] ? 'Active' : 'Disabled'}')],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showBookingDetail(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Booking ${booking['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${booking['user']}'),
            const SizedBox(height: 6),
            Text('Service: ${booking['service']}'),
            const SizedBox(height: 6),
            Text('Date: ${booking['date']}'),
            const SizedBox(height: 6),
            Text('Status: ${booking['status']}'),
            const SizedBox(height: 6),
            const Divider(),
            Text('Notes: ${booking['notes']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      ),
    );
  }
}
