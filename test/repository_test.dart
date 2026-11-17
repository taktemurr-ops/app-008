import 'package:flutter_test/flutter_test.dart';
import 'package:ogun_360/meal_models.dart';
import 'package:ogun_360/meal_repository.dart';

class FakeStorage implements MealStorage {
  String? data;
  bool failWrite = false;
  @override Future<String?> read() async => data;
  @override Future<void> write(String value) async {
    if (failWrite) throw StateError('Simulated storage failure');
    data = value;
  }
  @override Future<void> clear() async { data = null; }
}

const food = Food(id: 'food', name: 'Egg',
  per100g: Nutrients(kcal: 140, protein: 13, carbs: 1, fat: 9));
const meal = MealItem(id: 'entry', day: '2026-11-17', foodId: 'food',
  foodName: 'Egg', slot: MealSlot.breakfast, grams: 200,
  per100g: Nutrients(kcal: 140, protein: 13, carbs: 1, fat: 9));

void main() {
  test('persists foods, meals, eaten state and targets atomically', () async {
    final storage = FakeStorage();
    final repository = MealRepository(storage);
    await repository.addFood(food);
    await repository.addMeal(meal);
    await repository.toggleEaten('entry');
    await repository.updateTargets(const Targets(kcal: 1800));
    final reloaded = MealRepository(storage);
    await reloaded.load();
    expect(reloaded.state.foods.length, 1);
    expect(reloaded.state.meals.single.eaten, true);
    expect(reloaded.state.targets.kcal, 1800);
  });
  test('failed durable write leaves memory and storage unchanged', () async {
    final storage = FakeStorage();
    final repository = MealRepository(storage);
    await repository.addFood(food);
    final before = storage.data;
    storage.failWrite = true;
    await expectLater(repository.addMeal(meal), throwsStateError);
    expect(repository.state.meals, isEmpty);
    expect(storage.data, before);
  });
  test('copy day creates planned entries and new identity', () async {
    final repository = MealRepository(FakeStorage());
    await repository.addMeal(meal.copyWith(eaten: true));
    final count = await repository.copyDay('2026-11-17', '2026-11-18', () => 'new');
    expect(count, 1);
    final copied = repository.state.forDay('2026-11-18').single;
    expect(copied.eaten, false);
    expect(copied.id, 'new');
    expect(() => repository.copyDay('2026-11-17', '2026-11-17', () => 'x'), throwsFormatException);
  });
  test('deleted foods preserve historic nutrition snapshots', () async {
    final repository = MealRepository(FakeStorage());
    await repository.addFood(food);
    await repository.addMeal(meal.copyWith(eaten: true));
    await repository.removeFood('food');
    expect(repository.state.foods, isEmpty);
    expect(repository.state.totalFor('2026-11-17').kcal, 280);
  });
  test('shopping checklist and clearing all local data', () async {
    final storage = FakeStorage();
    final repository = MealRepository(storage);
    await repository.addMeal(meal);
    await repository.toggleShopping('2026-11-17', 'Egg');
    expect(repository.state.checkedShopping.contains('2026-11-17::Egg'), isTrue);
    await repository.reset();
    expect(storage.data, isNull);
    expect(repository.state.meals, isEmpty);
  });
  test('malformed backup cannot replace existing records', () async {
    final storage = FakeStorage();
    final repository = MealRepository(storage);
    await repository.addFood(food);
    final before = storage.data;
    await expectLater(repository.importBackup('{invalid'), throwsFormatException);
    expect(storage.data, before);
    expect(repository.state.foods.length, 1);
  });
}
