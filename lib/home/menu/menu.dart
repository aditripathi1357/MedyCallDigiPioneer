import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medycall/auth/signin.dart';
import 'package:medycall/home/profile/profile.dart';
import 'package:medycall/home/menu/fingerprint.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Guest';
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header with user info
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF018C7E),
              borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(
                          'assets/homescreen/home_profile.png',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu items
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20),
                ),
                color: Colors.white,
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: SvgPicture.asset('assets/menu/menu_profile.svg'),
                    title: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: SvgPicture.asset('assets/menu/menu_reminder.svg'),
                    title: 'Monthly Reminders',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Image.asset('assets/menu/menu_wallet.png'),
                    title: 'Wallet',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Image.asset('assets/menu/menu_refer.png'),
                    title: 'Refer',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Image.asset('assets/menu/Fingerprint.png'),
                    title: 'Fingerprint Password',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const FingerprintPasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 32, thickness: 1),
                  _buildMenuItem(
                    icon: SvgPicture.asset('assets/menu/menu_logout.svg'),
                    title: 'Log Out',
                    onTap: () async {
                      // Show confirmation dialog (optional)
                      bool? shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Logout'),
                            content: Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: Text('Log Out'),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldLogout == true) {
                        // Clear stored authentication data
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs
                            .clear(); // Or remove specific keys like prefs.remove('auth_token')

                        // Navigate to SignInPage and clear navigation stack
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => SignInPage()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: SizedBox(
        width: 24,
        height: 24,
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Color(0xFF018C7E),
            BlendMode.srcIn,
          ),
          child: icon,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 13,
          fontWeight: FontWeight.w300,
          height: 21.5 / 13, // Calculated line height (21.5px / 13px)
          letterSpacing: 0.11,
          color: Colors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF018C7E)),
      onTap: onTap,
    );
  }
}
