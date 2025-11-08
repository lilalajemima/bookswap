import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool _notificationReminders = true;
  bool _emailUpdates = false;
  String _userName = 'User';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Get user data from Firestore
        Map<String, dynamic>? userData = await _authService.getUserData(user.uid);

        if (mounted) {
          setState(() {
            _userName = user.displayName ?? 'User';
            _userEmail = user.email ?? '';
            
            if (userData != null) {
              _notificationReminders = userData['notificationReminders'] ?? true;
              _emailUpdates = userData['emailUpdates'] ?? false;
            }
            
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateNotificationSettings(String key, bool value) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (userId != null) {
        bool success = await _authService.updateUserSettings(userId, {key: value});
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Settings updated'),
              backgroundColor: AppColors.secondary,
              duration: const Duration(seconds: 1),
            ),
          );
        } else if (!success && mounted) {
          // Revert the switch if update failed
          setState(() {
            if (key == 'notificationReminders') {
              _notificationReminders = !value;
            } else if (key == 'emailUpdates') {
              _emailUpdates = !value;
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update settings'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Revert the switch on error
      setState(() {
        if (key == 'notificationReminders') {
          _notificationReminders = !value;
        } else if (key == 'emailUpdates') {
          _emailUpdates = !value;
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              Navigator.pop(context); // Close dialog
              
              try {
                await _authService.signOut();
                
                if (mounted) {
                  // Navigate to login screen and remove all previous routes
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.secondary,
              ),
            )
          : SingleChildScrollView(
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

                  // Account Section
                  _buildSettingsSection(
                    'ACCOUNT',
                    [
                      _buildSettingsTile(
                        icon: Icons.verified_user,
                        title: 'Email Verification',
                        subtitle: FirebaseAuth.instance.currentUser?.emailVerified == true
                            ? 'Email verified'
                            : 'Email not verified',
                        trailing: FirebaseAuth.instance.currentUser?.emailVerified == true
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : TextButton(
                                onPressed: () async {
                                  final result = await _authService.resendVerificationEmail();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result['message'] ?? result['error'] ?? 'Unknown error',
                                        ),
                                        backgroundColor: result['success']
                                            ? AppColors.secondary
                                            : Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Resend',
                                  style: TextStyle(color: AppColors.secondary),
                                ),
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