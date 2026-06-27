import 'package:flutter/material.dart';
import 'package:rain_vault/setting/your_info.dart';
import 'package:rain_vault/pages/login_page.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkTheme;

  const SettingsPage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkTheme,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _darkMode;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDarkTheme;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.8,
      indent: 16,
      endIndent: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blue.shade300,
      ),
      body: ListView(
        children: [
          _buildSectionTitle("Account"),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blueAccent),
            title: const Text("Profile"),
            subtitle: const Text("View and edit your profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          _buildDivider(),

          _buildSectionTitle("Preferences"),
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6, color: Colors.orangeAccent),
            title: const Text("Dark Mode"),
            subtitle: const Text("Toggle Light / Dark Theme"),
            value: _darkMode,
            onChanged: (val) {
              setState(() => _darkMode = val);
              widget.onThemeToggle();
            },
          ),
          _buildDivider(),

          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.green),
            title: const Text("Notifications"),
            subtitle: const Text("Enable or disable notifications"),
            value: _notifications,
            onChanged: (val) {
              setState(() => _notifications = val);
            },
          ),
          _buildDivider(),

          ListTile(
            leading: const Icon(Icons.notification_important, color: Colors.deepOrange),
            title: const Text("Alerts"),
            subtitle: const Text("Manage alert preferences"),
            onTap: () {},
          ),
          _buildDivider(),

          _buildSectionTitle("Information"),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.blueGrey),
            title: const Text("Privacy"),
            subtitle: const Text("Privacy preferences"),
            onTap: () {},
          ),
          _buildDivider(),

          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blueGrey),
            title: const Text("About"),
            subtitle: const Text("App version and details"),
            onTap: () {},
          ),
          _buildDivider(),

          _buildSectionTitle("Account Actions"),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
            subtitle: const Text("Sign out of your account"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false,
              );
            },
          ),
          _buildDivider(),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.redAccent),
            ),
            subtitle: const Text("Permanently delete your account"),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Delete Account"),
                  content: const Text(
                      "Are you sure you want to permanently delete your account?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                              (route) => false,
                        );
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
