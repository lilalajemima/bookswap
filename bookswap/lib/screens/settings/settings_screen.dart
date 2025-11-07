// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationReminders = true;
  bool _emailUpdates = false;
  String _userName = 'John Doe';
  String _userEmail = 'john.doe@example.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // TODO: Load user data from Firebase
    // Example:
    // User? user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   DocumentSnapshot doc = await FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(user.uid)
    //       .get();
    //   
    //   setState(() {
    //     _userName = user.displayName ?? 'User';
    //     _userEmail = user.email ?? '';
    //     _notificationReminders = doc['notificationReminders'] ?? true;
    //     _emailUpdates = doc['emailUpdates'] ?? false;
    //   });
    // }
  }

  Future<void> _updateNotificationSettings(String key, bool value) async {
    // TODO: Update settings in Firestore
    // Example:
    // String userId = FirebaseAuth.instance.currentUser!.uid;
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userId)
    //     .update({key: value});
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement logout
              // await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              
              // Navigate to login screen
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout functionality - Connect to Firebase'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.2),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.secondary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Profile Section
            _buildSettingsSection(
              'PROFILE',
              [
                _buildSettingsTile(
                  icon: Icons.person,
                  title: _userName,
                  subtitle: _userEmail,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSettingsSection(
              'NOTIFICATIONS',
              [
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notification reminders',
                  subtitle: 'Get notified about swap requests',
                  trailing: Switch(
                    value: _notificationReminders,
                    onChanged: (value) {
                      setState(() {
                        _notificationReminders = value;
                      });
                      _updateNotificationSettings('notificationReminders', value);
                    },
                    activeColor: AppColors.accent,
                  ),
                ),
                const Divider(height: 1),
                _buildSettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Email Updates',
                  subtitle: 'Receive updates via email',
                  trailing: Switch(
                    value: _emailUpdates,
                    onChanged: (value) {
                      setState(() {
                        _emailUpdates = value;
                      });
                      _updateNotificationSettings('emailUpdates', value);
                    },
                    activeColor: AppColors.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}