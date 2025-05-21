// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:medycall/Appointment/appointment.dart';
// import 'package:medycall/home/profile/profile.dart';
// import 'package:medycall/History/history.dart';
// import 'package:medycall/home/home_screen.dart';

// class CanceledPage extends StatefulWidget {
//   const CanceledPage({super.key});

//   @override
//   State<CanceledPage> createState() => _CanceledPageState();
// }

// class _CanceledPageState extends State<CanceledPage> {
//   int _selectedIndex = 1; // Assuming Appointment is index 1

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(automaticallyImplyLeading: false, title: _buildTopBar()),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 40),
//             Text(
//               'Your Slot Canceled...',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF37847E),
//               ),
//             ),
//             const SizedBox(height: 30),
//             Image.asset(
//               'assets/homescreen/success.png',
//               width: 100,
//               height: 100,
//             ),
//             const SizedBox(height: 30),
//             Text(
//               'Hey! Your appointment has been successfully canceled. You will receive a refund within 3 working days',
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
//             ),
//             const SizedBox(height: 40),
//             Column(
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     // Handle book another day
//                   },
//                   child: Text(
//                     'Book for another day',
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       color: const Color(0xFF37847E),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   'Book your slot for another day to save time',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.black54,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Handle explore now
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF37847E),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 32,
//                   vertical: 12,
//                 ),
//               ),
//               child: Text(
//                 'Explore Now',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   Widget _buildTopBar() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             const CircleAvatar(
//               radius: 20,
//               backgroundImage: AssetImage('assets/person.png'),
//             ),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Hello,',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: const Color(0xFF37847E),
//                   ),
//                 ),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Mohadeseh Shokri',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(width: 3),
//                     GestureDetector(
//                       onTap: () {
//                         // Handle image tap
//                       },
//                       child: Image.asset(
//                         'assets/homescreen/pencil.png',
//                         width: 30,
//                         height: 30,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             const SizedBox(width: 3),
//             GestureDetector(
//               onTap: () {
//                 // Handle image tap
//               },
//               child: Image.asset(
//                 'assets/homescreen/notification.png',
//                 width: 30,
//                 height: 30,
//               ),
//             ),
//             const SizedBox(width: 3),
//             const SizedBox(width: 3),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomNavigationBar() {
//     return Stack(
//       clipBehavior: Clip.none,
//       alignment: Alignment.topCenter,
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 spreadRadius: 1,
//                 blurRadius: 4,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           child: BottomNavigationBar(
//             items: [
//               BottomNavigationBarItem(
//                 icon: Image.asset(
//                   'assets/homescreen/home.png',
//                   width: 24,
//                   height: 24,
//                   color:
//                       _selectedIndex == 0
//                           ? const Color(0xFF00796B)
//                           : Colors.grey,
//                 ),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: Padding(
//                   padding: const EdgeInsets.only(bottom: 3),
//                   child: Image.asset(
//                     'assets/homescreen/appointment.png',
//                     width: 24,
//                     height: 24,
//                     color:
//                         _selectedIndex == 1
//                             ? const Color(0xFF00796B)
//                             : Colors.grey,
//                   ),
//                 ),
//                 label: 'Appointment',
//               ),
//               BottomNavigationBarItem(
//                 icon: const SizedBox(width: 24, height: 24),
//                 label: 'NIROG',
//               ),
//               BottomNavigationBarItem(
//                 icon: Image.asset(
//                   'assets/homescreen/history.png',
//                   width: 24,
//                   height: 24,
//                   color:
//                       _selectedIndex == 3
//                           ? const Color(0xFF00796B)
//                           : Colors.grey,
//                 ),
//                 label: 'History',
//               ),
//               BottomNavigationBarItem(
//                 icon: Image.asset(
//                   'assets/homescreen/profile.png',
//                   width: 24,
//                   height: 24,
//                   color:
//                       _selectedIndex == 4
//                           ? const Color(0xFF00796B)
//                           : Colors.grey,
//                 ),
//                 label: 'Profile',
//               ),
//             ],
//             currentIndex: _selectedIndex,
//             selectedItemColor: const Color(0xFF00796B),
//             unselectedItemColor: Colors.grey,
//             showUnselectedLabels: true,
//             type: BottomNavigationBarType.fixed,
//             selectedLabelStyle: GoogleFonts.poppins(
//               fontSize: 13.8,
//               fontWeight: FontWeight.w400,
//             ),
//             unselectedLabelStyle: GoogleFonts.poppins(
//               fontSize: 13.8,
//               fontWeight: FontWeight.w400,
//             ),
//             onTap: (index) {
//               if (index != 2) {
//                 setState(() {
//                   _selectedIndex = index;
//                 });

//                 // Navigate based on index
//                 if (index == 0) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => HomeScreen()),
//                   );
//                 } else if (index == 1) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AppointmentScreen(),
//                     ),
//                   );
//                 } else if (index == 3) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MedicalHistoryPage(),
//                     ),
//                   );
//                 } else if (index == 4) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => ProfileScreen()),
//                   );
//                 }
//               }
//             },
//           ),
//         ),
//         // Centered NIROG image
//         Positioned(
//           top: -20,
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   print('NIROG tapped');
//                   // Add your NIROG button action here
//                 },
//                 child: Image.asset(
//                   'assets/homescreen/nirog.png',
//                   width: 51,
//                   height: 54,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
