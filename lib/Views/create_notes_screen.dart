import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/Data/database_helper.dart';
import 'package:notes_app/Views/home_screen.dart';
import 'package:notes_app/utils/colors.dart';
import 'package:notes_app/widgets/build_textfeild.dart';

class CreateNotesScreen extends StatefulWidget {
  const CreateNotesScreen({super.key});

  @override
  State<CreateNotesScreen> createState() => _CreateNotesScreenState();
}

class _CreateNotesScreenState extends State<CreateNotesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DBHelper? dbHelper;
  bool isPersonalSelected = false;
  bool isWorkSelected = false;
  bool isStudySelected = false;
  bool isFamilySelected = false;
  String category = "Work";

  bool loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper.getInstance;
  }

  void addNewNote(String title, String desc, String category) async {
    bool isAdded = await dbHelper!.addNotes(
      title: title,
      desc: desc,
      category: category,
    );

    if (isAdded) {
      setState(() {
        loading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notes not added properly try again :)'),
          backgroundColor: AppColors.green,
        ),
      );
      setState(() {
        loading = false;
      });
    }
  }

  void _validateAndSubmit() {
    setState(() {
      loading = true;
    });
    if (_formKey.currentState!.validate()) {
      if (!isPersonalSelected && !isWorkSelected && !isStudySelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select at least one category'),
            backgroundColor: AppColors.green,
          ),
        );
        setState(() {
          loading = false;
        });
      }

      if (isPersonalSelected) category = 'Personal';
      if (isWorkSelected) category = 'Work';
      if (isStudySelected) category = 'Study';
      if (isFamilySelected) category = 'Family';
    }
    addNewNote(
      _nameController.text.toString(),
      _descController.text.toString(),
      category,
    );
  }

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "DayFlow.",
          style: GoogleFonts.roboto(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppColors.pureWhite,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.green,
      ),
      backgroundColor: AppColors.pureWhite,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Note!",
                  style: GoogleFonts.roboto(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
                SizedBox(height: 20),

                CustomTextField(
                  hintText: "Enter note name",
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter note name';
                    }
                    if (value.trim().length < 5) {
                      return 'Note name must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                CustomTextField(
                  hintText: "Enter description",
                  controller: _descController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter description';
                    }

                    int wordCount = _countWords(value);
                    if (wordCount > 120) {
                      return 'Description cannot exceed 120 words (current: $wordCount)';
                    }

                    return null;
                  },
                ),

                StatefulBuilder(
                  builder: (context, setState) {
                    _descController.addListener(() {
                      setState(() {});
                    });
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_countWords(_descController.text)}/100 words',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: _countWords(_descController.text) > 100
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 20),

                Text(
                  'Categories',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Personal checkbox
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: isPersonalSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                isPersonalSelected = value ?? false;
                              });
                            },
                            activeColor: AppColors.green,
                          ),
                          Expanded(
                            child: Text(
                              'Personal',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Work checkbox
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: isWorkSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                isWorkSelected = value ?? false;
                              });
                            },
                            activeColor: AppColors.green,
                          ),
                          Expanded(
                            child: Text(
                              'Profesional',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Study checkbox
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: isStudySelected,
                            onChanged: (bool? value) {
                              setState(() {
                                isStudySelected = value ?? false;
                              });
                            },
                            activeColor: AppColors.green,
                          ),
                          Expanded(
                            child: Text(
                              'Study',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Family
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: isFamilySelected,
                            onChanged: (bool? value) {
                              setState(() {
                                isStudySelected = value ?? false;
                              });
                            },
                            activeColor: AppColors.green,
                          ),
                          Expanded(
                            child: Text(
                              'Family',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                Center(
                  child: GestureDetector(
                    onTap: _validateAndSubmit,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: loading
                            ? CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              )
                            : Text(
                                "Create Note",
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
