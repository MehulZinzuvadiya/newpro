import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD SharedPref'),
        centerTitle: true,
      ),
      body: Center(
        child: DataList(),
      ),
    );
  }
}

class DataList extends StatefulWidget {
  @override
  _DataListState createState() => _DataListState();
}

class _DataListState extends State<DataList> {
  List<String> dataList = [];
  TextEditingController txtname = TextEditingController();
  TextEditingController txt_update = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int? age;

  void sort() {
    // dataList.sort((a, b) => (a['age']).compareTo(b['age']));
  }

  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;

    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;

      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  @override
  void initState() {
    super.initState();
    loadListFromSharedPreferences();
  }

  Future<void> loadListFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      dataList = prefs.getStringList('dataList') ?? [];
    });
  }

  Future<void> addItemToSharedPreferences(String newItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dataList.add(newItem);
    await prefs.setStringList('dataList', dataList);
  }

  Future<void> updateItemInSharedPreferences(
      int index, String updatedItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    dataList[index] = updatedItem;
    await prefs.setStringList('dataList', dataList);
  }

  Future<void> deleteItemFromSharedPreferences(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (index >= 0 && index < dataList.length) {
      dataList.removeAt(index);
      await prefs.setStringList('dataList', dataList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Add new item
          TextField(
            controller: txtname,
            decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                  ),
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: 'New Item'),
            onSubmitted: (text) {
              addItemToSharedPreferences(text);
              loadListFromSharedPreferences();
            },
          ),
          const SizedBox(
            height: 20,
          ),
          DateTimeFormField(
            onDateSelected: (value) {
              selectedDate = value;
              age = calculateAge(selectedDate);
            },
            mode: DateTimeFieldPickerMode.date,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Select Birthdate'),
          ),

          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              addItemToSharedPreferences(txtname.text);
              loadListFromSharedPreferences();
            },
            child: const Text('Add'),
          ),
          const SizedBox(
            height: 10,
          ),

          // Display and manage the list
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  child: ListTile(
                    title: Text(dataList[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue.shade500,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                txt_update = TextEditingController(
                                    text: dataList[index]);
                                return Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: Container(
                                    height: 400,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Update Data",
                                          style: GoogleFonts.lato(fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          controller: txt_update,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'enter title';
                                            }
                                          },
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'enter title',
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              updateItemInSharedPreferences(
                                                  index, txt_update.text);
                                              loadListFromSharedPreferences();
                                              Navigator.of(context).pop();
                                              txt_update.clear();
                                            },
                                            child: Text(
                                              'Update',
                                              style: GoogleFonts.poppins(),
                                            ))
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },

                          // Open an edit dialog or screen
                          // Handle updating the ite
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            deleteItemFromSharedPreferences(index);
                            loadListFromSharedPreferences();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
