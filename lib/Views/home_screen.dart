import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/Data/database_helper.dart';
import 'package:notes_app/Views/create_notes_screen.dart';
import 'package:notes_app/utils/colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int activeIndex = 0;
  final CarouselSliderController controller = CarouselSliderController();
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbHelper;
  bool isLoading = true;
  String? errorMessage;

  List<String> imgList = [
    'assets/img1.png',
    'assets/img3.png',
    'assets/img4.png',
  ];

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      dbHelper = DBHelper.getInstance;

      // Check if database is ready
      bool isReady = await dbHelper!.isDatabaseReady();
      if (!isReady) {
        throw Exception("Database initialization failed");
      }

      await loadAllNotes();

      setState(() {
        isLoading = false;
      });

      print("Database initialized successfully");
    } catch (e) {
      print("Database initialization error: $e");
      setState(() {
        isLoading = false;
        errorMessage = "Failed to initialize database: ${e.toString()}";
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: initializeDatabase,
            ),
          ),
        );
      }
    }
  }

  Future<void> loadAllNotes() async {
    try {
      if (dbHelper == null) {
        throw Exception("Database not initialized");
      }

      final notes = await dbHelper!.getAllNotes();

      if (mounted) {
        setState(() {
          allNotes = notes;
          errorMessage = null;
        });
        print("Loaded ${allNotes.length} notes successfully");
      }
    } catch (e) {
      print("Error loading notes: $e");
      if (mounted) {
        setState(() {
          errorMessage = "Failed to load notes: ${e.toString()}";
        });
      }
    }
  }

  // ✅ FIX 5: Enhanced delete functionality
  Future<void> deleteNote(int id) async {
    try {
      // Show confirmation dialog
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        bool success = await dbHelper!.deleteNote(id: id);
        if (success) {
          await loadAllNotes();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Note deleted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete note!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print("Error deleting note: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting note: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> navigateToCreateNote() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateNotesScreen()),
      );

      await loadAllNotes();
    } catch (e) {
      print("Navigation error: $e");
    }
  }

  // Helper function to get category color
  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'personal':
        return Colors.blue;
      case 'work':
      case 'professional':
        return Colors.orange;
      case 'study':
        return Colors.purple;
      case 'family':
        return Colors.pink;
      default:
        return AppColors.gold;
    }
  }

  // Build note card widget
  Widget buildNoteCard(Map<String, dynamic> note) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, right: 10),
      width: MediaQuery.of(context).size.width / 2.2,
      constraints: BoxConstraints(minHeight: 150, maxHeight: 200),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: getCategoryColor(note['category'] ?? 'Work'),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note['category'] ?? 'No Category',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => deleteNote(note['id']),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Note content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    note['name'] ?? 'No Title',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  // Description
                  Expanded(
                    child: Text(
                      note['description'] ?? 'No Description',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIX 7: Error widget
  Widget buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            "Database Error",
            style: GoogleFonts.roboto(
              fontSize: 20,
              color: Colors.red[300],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              errorMessage ?? "Unknown error occurred",
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.red[200]),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: initializeDatabase,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.green, size: 30),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hey Users!",
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pureWhite,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "What do you think today?",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.pureWhite,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: navigateToCreateNote,
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.pureWhite,
                      ),
                      child: Icon(Icons.add, color: Colors.green),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),

              CarouselSlider.builder(
                carouselController: controller,
                itemCount: imgList.length,
                itemBuilder: (context, index, realIndex) {
                  final image = imgList[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 122, 145, 115),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        image,
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 1,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  onPageChanged: (index, reason) {
                    setState(() {
                      activeIndex = index;
                    });
                  },
                ),
              ),

              SizedBox(height: 15),
              AnimatedSmoothIndicator(
                activeIndex: activeIndex,
                count: imgList.length,
                onDotClicked: (index) {
                  controller.animateToPage(index);
                },
                effect: ExpandingDotsEffect(
                  dotHeight: 10,
                  dotWidth: 14,
                  activeDotColor: AppColors.green,
                  dotColor: AppColors.pureWhite,
                  spacing: 6,
                ),
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Notes (${allNotes.length})",
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isLoading && errorMessage == null)
                    GestureDetector(
                      onTap: loadAllNotes,
                      child: Icon(
                        Icons.refresh,
                        color: AppColors.pureWhite,
                        size: 24,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 15),

              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.green,
                        ),
                      )
                    : errorMessage != null
                    ? buildErrorWidget()
                    : allNotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_add_outlined,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No notes yet!",
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Tap + to create your first note",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: allNotes.length,
                        itemBuilder: (context, index) {
                          return buildNoteCard(allNotes[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
