import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'meal_models.dart';

abstract class MealStorage {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

class SecureMealStorage implements MealStorage {
  const SecureMealStorage();
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _key = 'ogun360_v1';
  @override Future<String?> read() => _storage.read(key: _key);
  @override Future<void> write(String value) => _storage.write(key: _key, value: value);
  @override Future<void> clear() => _storage.delete(key: _key);
}

/// Commit to memory only after a successful durable, encrypted write.
class MealRepository {
  final MealStorage storage;
  MealState state = const MealState();
  MealRepository(this.storage);

  Future<void> load() async {
    final raw = await storage.read();
    if (raw == null) { state = const MealState(); return; }
    state = MealState.importJson(raw);
  }

  Future<void> replace(MealState next) async {
    next.validate();
    await storage.write(next.exportJson());
    state = next;
  }

  Future<void> importBackup(String raw) async {
    final parsed = MealState.importJson(raw);
    await replace(parsed);
  }

  Future<void> reset() async {
    await storage.clear();
    state = const MealState();
  }

  Future<void> addFood(Food food) async {
    food.validate();
    await replace(state.copyWith(foods: [...state.foods, food]));
  }

  Future<void> removeFood(String id) async {
    await replace(state.copyWith(foods: state.foods.where((f) => f.id != id).toList()));
  }

  Future<void> toggleFavorite(String id) async {
    await replace(state.copyWith(foods: state.foods.map((f) =>
      f.id == id ? f.copyWith(favorite: !f.favorite) : f).toList()));
  }

  Future<void> addMeal(MealItem entry) async {
    entry.validate();
    await replace(state.copyWith(meals: [...state.meals, entry]));
  }

  Future<void> removeMeal(String id) async {
    await replace(state.copyWith(meals: state.meals.where((m) => m.id != id).toList()));
  }

  Future<void> toggleEaten(String id) async {
    await replace(state.copyWith(meals: state.meals.map((m) =>
      m.id == id ? m.copyWith(eaten: !m.eaten) : m).toList()));
  }

  Future<int> copyDay(String source, String target, String Function() idGenerator) async {
    if (!isValidDayKey(source) || !isValidDayKey(target) || source == target) {
      throw const FormatException('Invalid days for copy');
    }
    final copy = state.forDay(source).map((m) => m.copyWith(
      id: idGenerator(), day: target, eaten: false)).toList();
    await replace(state.copyWith(meals: [...state.meals, ...copy]));
    return copy.length;
  }

  Future<void> updateTargets(Targets value) async {
    value.validate();
    await replace(state.copyWith(targets: value));
  }

  Future<void> toggleShopping(String day, String item) async {
    final key = '$day::$item';
    final next = {...state.checkedShopping};
    if (!next.add(key)) next.remove(key);
    await replace(state.copyWith(checkedShopping: next));
  }
}
