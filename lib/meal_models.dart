import 'dart:convert';

String dayKey(DateTime day) => '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

bool isValidDayKey(String key) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key)) return false;
  final parsed = DateTime.tryParse(key);
  return parsed != null && dayKey(parsed) == key;
}

void _checkNumber(double v, {double min = 0, double max = 100000}) {
  if (!v.isFinite || v < min || v > max) {
    throw const FormatException('Invalid number');
  }
}

String _name(Object? input, {int max = 90}) {
  if (input is! String || input.trim().isEmpty || input.trim().length > max) {
    throw const FormatException('Invalid text');
  }
  return input.trim();
}

String _id(Object? input) {
  if (input is! String || input.isEmpty || input.length > 80) {
    throw const FormatException('Invalid id');
  }
  return input;
}

class Nutrients {
  final double kcal, protein, carbs, fat;
  const Nutrients({required this.kcal, required this.protein, required this.carbs, required this.fat});
  static const zero = Nutrients(kcal: 0, protein: 0, carbs: 0, fat: 0);

  void validate() {
    _checkNumber(kcal);
    _checkNumber(protein);
    _checkNumber(carbs);
    _checkNumber(fat);
  }

  Nutrients scale(double by) => Nutrients(kcal: kcal * by, protein: protein * by,
      carbs: carbs * by, fat: fat * by);

  Nutrients operator +(Nutrients o) => Nutrients(kcal: kcal + o.kcal,
      protein: protein + o.protein, carbs: carbs + o.carbs, fat: fat + o.fat);

  Map<String, dynamic> toJson() => {'kcal': kcal, 'protein': protein, 'carbs': carbs, 'fat': fat};
  factory Nutrients.fromJson(Map<String, dynamic> data) {
    final values = ['kcal', 'protein', 'carbs', 'fat'].map((k) {
      final n = data[k];
      if (n is! num) throw const FormatException('Missing nutrients');
      return n.toDouble();
    }).toList();
    final item = Nutrients(kcal: values[0], protein: values[1], carbs: values[2], fat: values[3]);
    item.validate();
    return item;
  }
}

class Food {
  final String id, name;
  final Nutrients per100g;
  final bool favorite;
  const Food({required this.id, required this.name, required this.per100g, this.favorite = false});
  void validate() {
    _id(id);
    _name(name);
    per100g.validate();
  }
  Food copyWith({bool? favorite}) => Food(id: id, name: name, per100g: per100g,
      favorite: favorite ?? this.favorite);
  Map<String, dynamic> toJson() => {'id': id, 'name': name,
    'per100g': per100g.toJson(), 'favorite': favorite};
  factory Food.fromJson(Map<String, dynamic> j) {
    final food = Food(id: _id(j['id']), name: _name(j['name']),
      per100g: Nutrients.fromJson(Map<String, dynamic>.from(j['per100g'] as Map)),
      favorite: j['favorite'] == true);
    food.validate();
    return food;
  }
}

enum MealSlot { breakfast, lunch, dinner, snack }

class MealItem {
  final String id, day, foodId, foodName;
  final MealSlot slot;
  final double grams;
  final Nutrients per100g;
  final bool eaten;
  const MealItem({required this.id, required this.day, required this.foodId,
    required this.foodName, required this.slot, required this.grams,
    required this.per100g, this.eaten = false});

  Nutrients get nutrients => per100g.scale(grams / 100);
  MealItem copyWith({String? id, String? day, bool? eaten}) => MealItem(
    id: id ?? this.id, day: day ?? this.day, foodId: foodId,
    foodName: foodName, slot: slot, grams: grams, per100g: per100g,
    eaten: eaten ?? this.eaten);
  void validate() {
    _id(id);
    _id(foodId);
    _name(foodName);
    if (!isValidDayKey(day)) throw const FormatException('Invalid day');
    _checkNumber(grams, min: 0.01, max: 10000);
    per100g.validate();
  }
  Map<String, dynamic> toJson() => {'id': id, 'day': day,
    'foodId': foodId, 'foodName': foodName, 'slot': slot.name,
    'grams': grams, 'per100g': per100g.toJson(), 'eaten': eaten};
  factory MealItem.fromJson(Map<String, dynamic> j) {
    final slot = MealSlot.values.where((value) => value.name == j['slot']);
    if (slot.isEmpty || j['grams'] is! num) throw const FormatException('Invalid meal');
    final item = MealItem(id: _id(j['id']), day: _name(j['day']),
      foodId: _id(j['foodId']), foodName: _name(j['foodName']),
      slot: slot.first, grams: (j['grams'] as num).toDouble(),
      per100g: Nutrients.fromJson(Map<String, dynamic>.from(j['per100g'] as Map)),
      eaten: j['eaten'] == true);
    item.validate();
    return item;
  }
}

class Targets {
  final double kcal, protein, carbs, fat;
  const Targets({this.kcal = 2000, this.protein = 100,
    this.carbs = 250, this.fat = 70});
  void validate() {
    _checkNumber(kcal, min: 500, max: 10000);
    _checkNumber(protein, min: 1, max: 1000);
    _checkNumber(carbs, min: 1, max: 1500);
    _checkNumber(fat, min: 1, max: 1000);
  }
  Map<String, dynamic> toJson() => {'kcal': kcal, 'protein': protein, 'carbs': carbs, 'fat': fat};
  factory Targets.fromJson(Map<String, dynamic> j) {
    double take(String key) { final value = j[key];
      if (value is! num) throw const FormatException('Invalid targets');
      return value.toDouble(); }
    final targets = Targets(kcal: take('kcal'), protein: take('protein'),
      carbs: take('carbs'), fat: take('fat'));
    targets.validate();
    return targets;
  }
}

class MealState {
  final List<Food> foods;
  final List<MealItem> meals;
  final Targets targets;
  final Set<String> checkedShopping;
  const MealState({this.foods = const [], this.meals = const [],
    this.targets = const Targets(), this.checkedShopping = const {}});

  MealState copyWith({List<Food>? foods, List<MealItem>? meals,
      Targets? targets, Set<String>? checkedShopping}) => MealState(
        foods: foods ?? this.foods, meals: meals ?? this.meals,
        targets: targets ?? this.targets,
        checkedShopping: checkedShopping ?? this.checkedShopping);

  void validate() {
    if (foods.length > 5000 || meals.length > 50000 || checkedShopping.length > 5000) {
      throw const FormatException('Data limit exceeded');
    }
    targets.validate();
    final foodIds = <String>{};
    for (final f in foods) {
      f.validate();
      if (!foodIds.add(f.id)) throw const FormatException('Duplicate food');
    }
    final mealIds = <String>{};
    for (final item in meals) {
      item.validate();
      if (!mealIds.add(item.id)) throw const FormatException('Duplicate meal');
    }
    for (final entry in checkedShopping) {
      if (entry.isEmpty || entry.length > 150) throw const FormatException('Invalid grocery key');
    }
  }

  List<MealItem> forDay(String day) => meals.where((m) => m.day == day).toList();
  Nutrients totalFor(String day, {bool eatenOnly = true}) {
    var total = Nutrients.zero;
    for (final item in meals) {
      if (item.day == day && (!eatenOnly || item.eaten)) total = total + item.nutrients;
    }
    return total;
  }
  Map<String, double> groceries(String day) {
    final result = <String, double>{};
    for (final item in forDay(day)) {
      if (item.eaten) continue;
      result.update(item.foodName, (value) => value + item.grams,
        ifAbsent: () => item.grams);
    }
    return result;
  }
  Map<String, dynamic> toJson() => {
    'schemaVersion': 1, 'foods': foods.map((f) => f.toJson()).toList(),
    'meals': meals.map((m) => m.toJson()).toList(),
    'targets': targets.toJson(), 'checkedShopping': checkedShopping.toList()..sort(),
  };
  String exportJson() => jsonEncode(toJson());
  factory MealState.importJson(String source) {
    if (source.length > 5000000) throw const FormatException('Backup too large');
    final root = jsonDecode(source);
    if (root is! Map || root['schemaVersion'] != 1) {
      throw const FormatException('Unsupported backup version');
    }
    final data = Map<String, dynamic>.from(root);
    final foods = (data['foods'] as List).map((v) => Food.fromJson(
      Map<String, dynamic>.from(v as Map))).toList();
    final meals = (data['meals'] as List).map((v) => MealItem.fromJson(
      Map<String, dynamic>.from(v as Map))).toList();
    final shopping = (data['checkedShopping'] as List)
      .map((v) { if (v is! String) throw const FormatException('Invalid shopping'); return v; }).toSet();
    final state = MealState(foods: foods, meals: meals,
      targets: Targets.fromJson(Map<String, dynamic>.from(data['targets'] as Map)),
      checkedShopping: shopping);
    state.validate();
    return state;
  }
}
