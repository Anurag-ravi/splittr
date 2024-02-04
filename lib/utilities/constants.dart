import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String url = "http://localhost:5000";
const Color mainGreen = Color(0xff1dc29f);
const Color mainOrange = Color.fromARGB(255, 238, 100, 49);
const Color sideGreen = Color(0xff4fc3b2);
const categories = [
  "general",
  "games",
  "movies",
  "music",
  "sports",
  "groceries",
  "dining",
  "liquor",
  "mortgage",
  "household-supplies",
  "pets",
  "services",
  "electronics",
  "furniture",
  "maintenance",
  "clothing",
  "gifts",
  "medical",
  "education",
  "parking",
  "car",
  "bus-train",
  "fuel",
  "plane",
  "taxi",
  "bicycle",
  "hotel",
  "cleaning",
  "electricity",
  "gas",
  "internet",
  "trash",
  "water",
];
const Map<String, String> catMap = {
  "bicycle": "Bicycle",
  "bus-train": "Bus/Train",
  "car": "Car",
  "cleaning": "Cleaning",
  "clothing": "Clothing",
  "dining": "Dining",
  "education": "Education",
  "electricity": "Electricity",
  "electronics": "Electronics",
  "fuel": "Fuel",
  "furniture": "Furniture",
  "games": "Games",
  "gas": "Gas",
  "general": "General",
  "gifts": "Gifts",
  "groceries": "Groceries",
  "hotel": "Hotel",
  "household-supplies": "Household",
  "internet": "Internet",
  "liquor": "Liquor",
  "maintenance": "Maintenance",
  "medical": "Medical",
  "mortgage": "Rent",
  "movies": "Movies",
  "music": "Music",
  "parking": "Parking",
  "pets": "Pets",
  "plane": "Plane",
  "services": "Services",
  "sports": "Sports",
  "taxi": "Taxi",
  "trash": "Trash",
  "water": "Water"
};

double roundAmount(double amount) {
  String x = (amount).toStringAsFixed(20);
  return double.parse(x.substring(0, x.length - 18));
}

String roundAmountStr(double amount) {
  String x = (amount).toStringAsFixed(20);
  return x.substring(0, x.length - 18);
}


void haptics() {
  HapticFeedback.mediumImpact();
  SystemSound.play(SystemSoundType.click);
}