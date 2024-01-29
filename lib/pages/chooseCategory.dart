import 'package:flutter/material.dart';
import 'package:splittr/utilities/constants.dart';

class ChooseCategory extends StatefulWidget {
  const ChooseCategory({super.key, required this.categ});
  final String categ;
  @override
  State<ChooseCategory> createState() => _ChooseCategoryState();
}

class _ChooseCategoryState extends State<ChooseCategory> {
  String category = 'general';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      category = widget.categ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Choose category',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, category);
          },
        ),
      ),
      body: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, categories[index]);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.asset(
                        'assets/categories/${categories[index]}.png',
                        height: 45.0,
                        width: 45.0,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      catMap[categories[index]]!,
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
