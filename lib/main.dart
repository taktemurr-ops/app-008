import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'meal_models.dart';
import 'meal_repository.dart';
import 'number_parser.dart';
import 'strings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Ogun360App());
}

class Ogun360App extends StatelessWidget {
  const Ogun360App({super.key, this.storage});
  final MealStorage? storage;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Öğün 360',
    debugShowCheckedModeBanner: false,
    supportedLocales: S.locales,
    localizationsDelegates: S.delegates,
    theme: ThemeData(useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff146b73))),
    home: MealHome(storage: storage ?? const SecureMealStorage()),
  );
}

class MealHome extends StatefulWidget {
  const MealHome({super.key, required this.storage});
  final MealStorage storage;
  @override State<MealHome> createState() => _MealHomeState();
}

class _MealHomeState extends State<MealHome> {
  late MealRepository repo;
  DateTime date = DateTime.now();
  int tab = 0;
  bool loading = true;
  String? loadError;
  String query = '';
  int counter = 0;

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}-${counter++}';
  String t(String key) => S.of(context, key);
  MealState get state => repo.state;
  String get day => dayKey(date);
  String get locale => Localizations.localeOf(context).toLanguageTag();
  String number(double value, {int decimals = 0}) =>
    NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: decimals).format(value);

  @override void initState() {
    super.initState();
    repo = MealRepository(widget.storage);
    _load();
  }

  Future<void> _load() async {
    try {
      await repo.load();
      if (mounted) setState(() { loading = false; loadError = null; });
    } catch (_) {
      if (mounted) setState(() { loading = false; loadError = 'Unable to open encrypted data'; });
    }
  }

  void _message(String content) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
  }

  Future<void> _perform(Future<void> Function() change) async {
    try {
      await change();
      if (!mounted) return;
      setState(() {});
      _message(t('success'));
    } catch (_) { _message(t('error')); }
  }

  Future<bool> _confirm(String key) async {
    final result = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(t('confirm')),
      content: Text(t(key)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'))),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('save'))),
      ],
    ));
    return result == true;
  }

  Future<void> _chooseDay() async {
    final next = await showDatePicker(context: context, initialDate: date,
      firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (next != null && mounted) setState(() => date = next);
  }

  Future<void> _addFood() async {
    final form = GlobalKey<FormState>();
    final name = TextEditingController();
    final kcal = TextEditingController();
    final protein = TextEditingController();
    final carbs = TextEditingController();
    final fat = TextEditingController();
    final fields = [kcal, protein, carbs, fat];
    final labels = ['kcal', 'protein', 'carbs', 'fat'];
    final food = await showDialog<Food>(context: context, builder: (ctx) => AlertDialog(
      title: Text(t('addFood')),
      content: SizedBox(width: 360, child: SingleChildScrollView(child: Form(
        key: form,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: name, maxLength: 90,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: t('foodName')),
            validator: (value) => value == null || value.trim().isEmpty ? t('invalid') : null),
          Text(t('per100')),
          for (var i = 0; i < fields.length; i++)
            TextFormField(controller: fields[i],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: t(labels[i])),
              validator: (value) => parsePortion(value ?? '', min: 0, max: 100000) == null
                ? t('invalid') : null),
        ]),
      ))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
        FilledButton(onPressed: () {
          if (!form.currentState!.validate()) return;
          Navigator.pop(ctx, Food(id: _newId(), name: name.text.trim(),
            per100g: Nutrients(
              kcal: parsePortion(kcal.text, min: 0)!,
              protein: parsePortion(protein.text, min: 0)!,
              carbs: parsePortion(carbs.text, min: 0)!,
              fat: parsePortion(fat.text, min: 0)!,
            )));
        }, child: Text(t('save'))),
      ],
    ));
    // Do not dispose controllers while the closing dialog is animating.
    if (food != null) await _perform(() => repo.addFood(food));
  }

  Future<void> _addMeal() async {
    if (state.foods.isEmpty) { _message(t('noFood')); return; }
    final grams = TextEditingController(text: '100');
    Food food = state.foods.first;
    MealSlot slot = MealSlot.breakfast;
    bool eaten = false;
    final entry = await showDialog<MealItem>(context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => AlertDialog(
        title: Text(t('addMeal')),
        content: SizedBox(width: 340, child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            initialValue: food.id,
            decoration: InputDecoration(labelText: t('food')),
            items: state.foods.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
            onChanged: (value) => refresh(() => food = state.foods.firstWhere((f) => f.id == value)),
          ),
          DropdownButtonFormField<MealSlot>(
            initialValue: slot, decoration: InputDecoration(labelText: t('slot')),
            items: MealSlot.values.map((s) => DropdownMenuItem(value: s,
              child: Text(t(s.name)))).toList(),
            onChanged: (value) { if (value != null) refresh(() => slot = value); },
          ),
          TextField(controller: grams,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t('grams'))),
          CheckboxListTile(value: eaten, title: Text(t('eaten')),
            onChanged: (value) => refresh(() => eaten = value == true)),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
          FilledButton(onPressed: () {
            final amount = parsePortion(grams.text, max: 10000);
            if (amount == null) { _message(t('invalid')); return; }
            Navigator.pop(ctx, MealItem(id: _newId(), day: day, foodId: food.id,
              foodName: food.name, slot: slot, grams: amount,
              per100g: food.per100g, eaten: eaten));
          }, child: Text(t('save'))),
        ],
      )));
    if (entry != null) await _perform(() => repo.addMeal(entry));
  }

  Future<void> _editTargets() async {
    final c = [state.targets.kcal, state.targets.protein,
      state.targets.carbs, state.targets.fat]
        .map((value) => TextEditingController(text: value.toStringAsFixed(0))).toList();
    final labels = ['kcal', 'protein', 'carbs', 'fat'];
    final next = await showDialog<Targets>(context: context, builder: (ctx) => AlertDialog(
      title: Text(t('goals')),
      content: SizedBox(width: 340, child: Column(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < c.length; i++) TextField(controller: c[i],
          keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t(labels[i]))),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
        FilledButton(onPressed: () {
          final values = c.map((e) => parsePortion(e.text)).toList();
          if (values.any((v) => v == null)) { _message(t('invalid')); return; }
          final targets = Targets(kcal: values[0]!, protein: values[1]!,
            carbs: values[2]!, fat: values[3]!);
          try { targets.validate(); Navigator.pop(ctx, targets); }
          catch (_) { _message(t('invalid')); }
        }, child: Text(t('save')))],
    ));
    if (next != null) await _perform(() => repo.updateTargets(next));
  }

  Future<void> _importBackup() async {
    final input = TextEditingController();
    final raw = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(t('import')),
      content: SizedBox(width: 420, child: TextField(controller: input,
        minLines: 4, maxLines: 8,
        decoration: InputDecoration(labelText: t('importPaste'),
          border: const OutlineInputBorder()))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
        FilledButton(onPressed: () => Navigator.pop(ctx, input.text), child: Text(t('save'))),
      ],
    ));
    if (raw == null) return;
    try { MealState.importJson(raw); }
    catch (_) { _message(t('invalid')); return; }
    if (!mounted || !await _confirm('confirmImport')) return;
    await _perform(() => repo.importBackup(raw));
  }

  Future<void> _reset() async {
    if (await _confirm('confirmReset')) await _perform(repo.reset);
  }

  Widget _metric(String label, double current, double target, {String unit = 'g'}) {
    final ratio = target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0).toDouble();
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(label)), Text('${number(current)} / ${number(target)} $unit')]),
        const SizedBox(height: 4),
        Semantics(label: '$label ${number(current)} / ${number(target)}',
          child: LinearProgressIndicator(value: ratio)),
      ],
    ));
  }

  Widget _dailySummary() {
    final total = state.totalFor(day);
    final targets = state.targets;
    final items = state.forDay(day);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t('summary'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      _metric(t('kcal'), total.kcal, targets.kcal, unit: 'kcal'),
      _metric(t('protein'), total.protein, targets.protein),
      _metric(t('carbs'), total.carbs, targets.carbs),
      _metric(t('fat'), total.fat, targets.fat),
      Text('${t('planned')}: ${items.where((m) => !m.eaten).length}   '
        '${t('eaten')}: ${items.where((m) => m.eaten).length}'),
    ]);
  }

  Widget _mealCard(MealItem meal) => Card(child: ListTile(
    leading: Checkbox(value: meal.eaten,
      tooltip: t('eaten'), onChanged: (_) => _perform(() => repo.toggleEaten(meal.id))),
    title: Text('${t(meal.slot.name)} · ${meal.foodName}'),
    subtitle: Text('${number(meal.grams)} g · ${number(meal.nutrients.kcal)} kcal'),
    trailing: IconButton(tooltip: t('delete'), icon: const Icon(Icons.delete_outline),
      onPressed: () async { if (await _confirm('confirmDelete')) {
        await _perform(() => repo.removeMeal(meal.id)); } }),
  ));

  Widget _mealList() {
    final list = state.forDay(day)..sort((a, b) => a.slot.index.compareTo(b.slot.index));
    if (list.isEmpty) return Text(t('empty'));
    return Column(children: list.map(_mealCard).toList());
  }

  Widget _daySelector() => Row(children: [
    IconButton(tooltip: 'Previous day', icon: const Icon(Icons.chevron_left),
      onPressed: () => setState(() => date = date.subtract(const Duration(days: 1)))),
    Expanded(child: TextButton.icon(onPressed: _chooseDay, icon: const Icon(Icons.calendar_month),
      label: Text(DateFormat.yMMMMd(locale).format(date)))),
    IconButton(tooltip: 'Next day', icon: const Icon(Icons.chevron_right),
      onPressed: () => setState(() => date = date.add(const Duration(days: 1)))),
  ]);

  Widget _dashboard() => ListView(padding: const EdgeInsets.all(16), children: [
    _daySelector(), const SizedBox(height: 14), _dailySummary(),
    const SizedBox(height: 18),
    FilledButton.icon(onPressed: _addMeal,
      icon: const Icon(Icons.add), label: Text(t('addMeal'))),
    const SizedBox(height: 12), _mealList(),
    const SizedBox(height: 24), Text(t('disclaimer')),
  ]);

  Widget _foods() {
    final foods = state.foods.where((f) => f.name.toLowerCase().contains(query.toLowerCase())).toList()
      ..sort((a, b) { if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
        return a.name.compareTo(b.name); });
    return ListView(padding: const EdgeInsets.all(16), children: [
      TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search),
        labelText: t('search'), border: const OutlineInputBorder()),
        onChanged: (value) => setState(() => query = value)),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: _addFood, icon: const Icon(Icons.add), label: Text(t('addFood'))),
      const SizedBox(height: 12),
      if (foods.isEmpty) Text(t('empty')),
      for (final food in foods) Card(child: ListTile(
        title: Text(food.name),
        subtitle: Text('${number(food.per100g.kcal)} kcal / 100 g · '
          'P ${number(food.per100g.protein, decimals: 1)}  '
          'C ${number(food.per100g.carbs, decimals: 1)}  '
          'F ${number(food.per100g.fat, decimals: 1)}'),
        leading: IconButton(tooltip: t('favorite'),
          icon: Icon(food.favorite ? Icons.star : Icons.star_border),
          onPressed: () => _perform(() => repo.toggleFavorite(food.id))),
        trailing: IconButton(tooltip: t('delete'), icon: const Icon(Icons.delete_outline),
          onPressed: () async { if (await _confirm('confirmDelete')) {
            await _perform(() => repo.removeFood(food.id)); } }),
      )),
    ]);
  }

  Widget _planner() => ListView(padding: const EdgeInsets.all(16), children: [
    _daySelector(), const SizedBox(height: 12),
    FilledButton.icon(onPressed: _addMeal, icon: const Icon(Icons.add), label: Text(t('addMeal'))),
    const SizedBox(height: 8),
    OutlinedButton.icon(onPressed: () async {
      final from = dayKey(date.subtract(const Duration(days: 1)));
      try {
        final count = await repo.copyDay(from, day, _newId);
        if (mounted) { setState(() {}); _message('$count ${t('copied')}'); }
      } catch (_) { _message(t('error')); }
    }, icon: const Icon(Icons.copy), label: Text(t('copyYesterday'))),
    const SizedBox(height: 16), _mealList(),
    const SizedBox(height: 24),
    Text(t('shopping'), style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 8),
    if (state.groceries(day).isEmpty) Text(t('empty')),
    for (final entry in (state.groceries(day).entries.toList()..sort((a,b) => a.key.compareTo(b.key))))
      CheckboxListTile(title: Text('${entry.key} — ${number(entry.value)} g'),
        value: state.checkedShopping.contains('$day::${entry.key}'),
        onChanged: (_) => _perform(() => repo.toggleShopping(day, entry.key))),
  ]);

  Widget _insights() {
    final days = List.generate(7, (i) => date.subtract(Duration(days: 6 - i)));
    return ListView(padding: const EdgeInsets.all(16), children: [
      _daySelector(), const SizedBox(height: 12),
      Text(t('week'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      for (final d in days) Builder(builder: (ctx) {
        final key = dayKey(d);
        final sum = state.totalFor(key);
        final count = state.forDay(key).where((m) => m.eaten).length;
        final ratio = (sum.kcal / state.targets.kcal).clamp(0.0, 1.0).toDouble();
        return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(DateFormat.E(locale).add_Md().format(d))),
              Text('${number(sum.kcal)} kcal · $count ${t('eaten')}')]),
            const SizedBox(height: 6), LinearProgressIndicator(value: ratio),
          ],
        )));
      }),
      const SizedBox(height: 16), Text(t('disclaimer')),
    ]);
  }

  Widget _settings() => ListView(padding: const EdgeInsets.all(16), children: [
    Text(t('goals'), style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 12), _metric(t('kcal'), 0, state.targets.kcal, unit: 'kcal'),
    _metric(t('protein'), 0, state.targets.protein),
    _metric(t('carbs'), 0, state.targets.carbs),
    _metric(t('fat'), 0, state.targets.fat),
    OutlinedButton.icon(onPressed: _editTargets, icon: const Icon(Icons.tune), label: Text(t('goals'))),
    const Divider(height: 28),
    ListTile(leading: const Icon(Icons.copy), title: Text(t('export')),
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: state.exportJson()));
        _message(t('copied'));
      }),
    ListTile(leading: const Icon(Icons.file_download), title: Text(t('import')), onTap: _importBackup),
    ListTile(leading: const Icon(Icons.delete_forever), title: Text(t('clear')),
      onTap: _reset),
    const Divider(height: 28),
    Text(t('privacy')),
    const SizedBox(height: 12), Text(t('disclaimer')),
  ]);

  @override
  Widget build(BuildContext context) {
    final tabs = [t('today'), t('foods'), t('planner'), t('insights'), t('settings')];
    return Scaffold(
      appBar: AppBar(title: Text(t('app'))),
      body: loading ? const Center(child: CircularProgressIndicator())
        : loadError != null ? Center(child: Column(mainAxisSize: MainAxisSize.min,
          children: [Text(loadError!), TextButton(onPressed: () {
            setState(() { loading = true; loadError = null; }); _load();
          }, child: const Text('Retry'))]))
        : switch (tab) {
          0 => _dashboard(),
          1 => _foods(),
          2 => _planner(),
          3 => _insights(),
          _ => _settings(),
        },
      bottomNavigationBar: NavigationBar(selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.today), label: tabs[0]),
          NavigationDestination(icon: const Icon(Icons.restaurant), label: tabs[1]),
          NavigationDestination(icon: const Icon(Icons.event_note), label: tabs[2]),
          NavigationDestination(icon: const Icon(Icons.insights), label: tabs[3]),
          NavigationDestination(icon: const Icon(Icons.settings), label: tabs[4]),
        ]),
    );
  }
}
