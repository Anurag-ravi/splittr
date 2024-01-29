import 'package:flutter/material.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/pages/chooseCategory.dart';
import 'package:splittr/utilities/constants.dart';

class AddExpense extends StatefulWidget {
  AddExpense({super.key, required this.trip});
  final TripModel trip;

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  String category = "general";
  TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Add expense',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.done,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'With you and: ',
                  style: TextStyle(color: Colors.white),
                ),
                Container(
                  height: 30,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      border: Border.all(
                        color: Color(0xffa0a0a0),
                        width: 0.5,
                      )),
                  child: Center(
                    child: Text(
                      'All of ${widget.trip.name}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      getCategory(category);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.asset(
                            'assets/categories/${category}.png',
                            height: 45.0,
                            width: 45.0,
                          ),
                        ),
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              border: Border.all(
                                color: mainGreen,
                                width: 1,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: TextField(
                      cursorColor: mainGreen,
                      style: TextStyle(color: Colors.white),
                      onChanged: (text) {},
                      controller: nameController,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: mainGreen,
                          ),
                        ),
                        labelText: 'Expense Name',
                        fillColor: Colors.grey[900],
                        filled: true,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> getCategory(String cat) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChooseCategory(categ: category)),
    );

    if (!mounted) return;
    setState(() {
      category = result;
    });
  }
}
