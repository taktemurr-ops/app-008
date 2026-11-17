import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogun_360/meal_models.dart';

const sample = Nutrients(kcal: 200, protein: 10, carbs: 30, fat: 5);
const food = Food(id: 'f1', name: 'Yulaf', per100g: sample, favorite: true);
const meal = MealItem(id: 'm1', day: '2026-11-17', foodId: 'f1',
    foodName: 'Yulaf', slot: MealSlot.breakfast, grams: 150,
    per100g: sample, eaten: true);

void main() {
  test('calendar key preserves valid dates', () {
    expect(dayKey(DateTime(2026, 11, 7)), '2026-11-07');
    expect(isValidDayKey('2026-02-30'), false);
    expect(isValidDayKey('2024-02-29'), true);
    expect(isValidDayKey('2026-11-17'), true);
  });
  test('meal calorie and macro totals scale with portion', () {
    expect(meal.nutrients.kcal, 300);
    expect(meal.nutrients.protein, 15);
    expect(meal.nutrients.carbs, 45);
    expect(meal.nutrients.fat, 7.5);
  });
  test('daily consumed totals exclude planned entries', () {
    final pending = meal.copyWith(id: 'm2', eaten: false);
    final state = MealState(foods: [food], meals: [meal, pending]);
    expect(state.totalFor('2026-11-17').kcal, 300);
    expect(state.totalFor('2026-11-17', eatenOnly: false).kcal, 600);
    expect(state.groceries('2026-11-17')['Yulaf'], 150);
  });
  test('backup roundtrip preserves Arabic names and metadata', () {
    final arabic = Food(id: 'f2', name: 'شوفان', per100g: sample);
    final state = MealState(foods: [food, arabic], meals: [meal],
      checkedShopping: {'2026-11-17::شوفان'});
    final restored = MealState.importJson(state.exportJson());
    expect(restored.foods[1].name, arabic.name);
    expect(restored.meals.single.eaten, true);
    expect(restored.checkedShopping.single, '2026-11-17::شوفان');
    expect(restored.exportJson(), state.exportJson());
  });
  test('rejects version mismatch, duplicate IDs and malformed food', () {
    expect(() => MealState.importJson('{"schemaVersion":2}'), throwsFormatException);
    expect(() => MealState(foods: [food, food]).validate(), throwsFormatException);
    expect(() => Food(id: 'x', name: ' ', per100g: sample).validate(), throwsFormatException);
    final bad = jsonDecode(MealState(foods: [food]).exportJson()) as Map<String, dynamic>;
    (bad['foods'] as List).first['per100g']['kcal'] = -1;
    expect(() => MealState.importJson(jsonEncode(bad)), throwsFormatException);
  });
  test('new targets apply safe ranges', () {
    expect(() => const Targets(kcal: 0).validate(), throwsFormatException);
    expect(() => const Targets(kcal: 500).validate(), returnsNormally);
    expect(() => const Targets(kcal: 10001).validate(), throwsFormatException);
  });
}
