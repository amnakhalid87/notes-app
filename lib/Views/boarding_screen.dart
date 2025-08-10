import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/Views/home_screen.dart';
import 'package:notes_app/utils/colors.dart';

class BoardingScreen extends StatelessWidget {
  const BoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "DayFlow.",
                style: GoogleFonts.roboto(
                  fontSize: 25,
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 39, 63, 39),
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Image.asset(
                  'assets/img4.png',
                  height: 250,
                  width: MediaQuery.of(context).size.width / 1.5,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Capture Moments,",
                style: GoogleFonts.roboto(
                  fontSize: 30,
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Grow Within",
                style: GoogleFonts.roboto(
                  fontSize: 30,
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "In the quiet corners of your mind,\n brilliant ideas are waiting to be discovered.\nGive them a home where they can grow.",
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      "Get Started",
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: AppColors.pureWhite,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
