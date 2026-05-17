abstract final class ExpenseCategories {
  static const List<String> all = [
    'general', 'games', 'movies', 'music', 'sports', 'groceries', 'dining',
    'liquor', 'mortgage', 'household-supplies', 'pets', 'services',
    'electronics', 'furniture', 'maintenance', 'clothing', 'gifts', 'medical',
    'education', 'parking', 'car', 'bus-train', 'fuel', 'plane', 'taxi',
    'bicycle', 'hotel', 'cleaning', 'electricity', 'gas', 'internet',
    'trash', 'water',
  ];

  static const Map<String, String> labels = {
    'bicycle': 'Bicycle', 'bus-train': 'Bus/Train', 'car': 'Car',
    'cleaning': 'Cleaning', 'clothing': 'Clothing', 'dining': 'Dining',
    'education': 'Education', 'electricity': 'Electricity',
    'electronics': 'Electronics', 'fuel': 'Fuel', 'furniture': 'Furniture',
    'games': 'Games', 'gas': 'Gas', 'general': 'General', 'gifts': 'Gifts',
    'groceries': 'Groceries', 'hotel': 'Hotel',
    'household-supplies': 'Household', 'internet': 'Internet',
    'liquor': 'Liquor', 'maintenance': 'Maintenance', 'medical': 'Medical',
    'mortgage': 'Rent', 'movies': 'Movies', 'music': 'Music',
    'parking': 'Parking', 'pets': 'Pets', 'plane': 'Plane',
    'services': 'Services', 'sports': 'Sports', 'taxi': 'Taxi',
    'trash': 'Trash', 'water': 'Water',
  };

  static String labelOf(String key) => labels[key] ?? key;
}
