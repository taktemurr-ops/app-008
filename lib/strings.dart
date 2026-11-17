import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class S {
  static const locales = [Locale('tr'), Locale('en'), Locale('ar')];
  static const delegates = [GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate];
  static String of(BuildContext context, String key) {
    final language = Localizations.localeOf(context).languageCode;
    return (_labels[language] ?? _labels['en']!)[key] ?? _labels['en']![key] ?? key;
  }
  static const Map<String, Map<String,String>> _labels = {
    'tr': {
      'app': 'Öğün 360', 'today': 'Bugün', 'foods': 'Besinler', 'planner': 'Planlayıcı',
      'insights': 'Analiz', 'settings': 'Ayarlar', 'planned': 'Planlanan', 'eaten': 'Tüketildi',
      'addFood': 'Besin ekle', 'foodName': 'Besin adı', 'kcal': 'Kalori', 'protein': 'Protein',
      'carbs': 'Karbonhidrat', 'fat': 'Yağ', 'per100': '100 gram başına', 'grams': 'Gram',
      'addMeal': 'Öğün ekle', 'breakfast': 'Kahvaltı', 'lunch': 'Öğle', 'dinner': 'Akşam',
      'snack': 'Ara öğün', 'save': 'Kaydet', 'cancel': 'İptal', 'delete': 'Sil',
      'favorite': 'Favori', 'empty': 'Henüz kayıt bulunmuyor.', 'search': 'Besin ara',
      'remaining': 'Kalan', 'goals': 'Günlük hedefler', 'week': 'Son 7 gün',
      'shopping': 'Alışveriş listesi', 'copyYesterday': 'Dünü kopyala',
      'export': 'JSON yedeği kopyala', 'import': 'JSON yedeği içe aktar',
      'clear': 'Tüm verileri sil', 'confirm': 'İşlemi onaylıyor musunuz?',
      'copied': 'Panoya kopyalandı', 'importPaste': 'JSON yedeğini yapıştırın',
      'invalid': 'Geçersiz değerleri kontrol edin.', 'error': 'İşlem kaydedilemedi.',
      'success': 'Kaydedildi', 'pickDay': 'Tarih seç', 'nutrition': 'Besin değerleri',
      'noFood': 'Önce besin ekleyin.', 'food': 'Besin', 'slot': 'Öğün türü',
      'summary': 'Günlük özet', 'copy': 'Kopyala', 'progress': 'Hedef ilerlemesi',
      'confirmDelete': 'Seçilen kaydı sil?', 'confirmReset': 'Tüm özel veriler kalıcı silinecek.',
      'confirmImport': 'Mevcut kayıtlar yedekle değiştirilecek.',
      'privacy': 'Verileriniz cihazınızda şifreli saklanır. Yedek panoya kopyalanırsa gizliliği sizin sorumluluğunuzdadır.',
      'disclaimer': 'Besin değerleri kullanıcı girdisidir; tıbbi öneri değildir.',
    },
    'en': {
      'app': 'Meal 360', 'today': 'Today', 'foods': 'Foods', 'planner': 'Planner',
      'insights': 'Insights', 'settings': 'Settings', 'planned': 'Planned', 'eaten': 'Eaten',
      'addFood': 'Add food', 'foodName': 'Food name', 'kcal': 'Calories', 'protein': 'Protein',
      'carbs': 'Carbohydrates', 'fat': 'Fat', 'per100': 'Per 100 grams', 'grams': 'Grams',
      'addMeal': 'Add meal', 'breakfast': 'Breakfast', 'lunch': 'Lunch', 'dinner': 'Dinner',
      'snack': 'Snack', 'save': 'Save', 'cancel': 'Cancel', 'delete': 'Delete',
      'favorite': 'Favorite', 'empty': 'No records yet.', 'search': 'Search foods',
      'remaining': 'Remaining', 'goals': 'Daily targets', 'week': 'Last 7 days',
      'shopping': 'Shopping list', 'copyYesterday': 'Copy yesterday',
      'export': 'Copy JSON backup', 'import': 'Import JSON backup',
      'clear': 'Delete all data', 'confirm': 'Confirm this action?',
      'copied': 'Copied to clipboard', 'importPaste': 'Paste JSON backup',
      'invalid': 'Check invalid values.', 'error': 'Could not save changes.',
      'success': 'Saved', 'pickDay': 'Choose date', 'nutrition': 'Nutrition',
      'noFood': 'Add a food first.', 'food': 'Food', 'slot': 'Meal slot',
      'summary': 'Daily summary', 'copy': 'Copy', 'progress': 'Target progress',
      'confirmDelete': 'Delete selected item?', 'confirmReset': 'All private data will be permanently deleted.',
      'confirmImport': 'Existing records will be replaced by the backup.',
      'privacy': 'Your data is encrypted on this device. Clipboard exports may be read by other apps.',
      'disclaimer': 'Nutrition figures are user-entered and are not medical advice.',
    },
    'ar': {
      'app': 'الوجبات ٣٦٠', 'today': 'اليوم', 'foods': 'الأطعمة', 'planner': 'المخطط',
      'insights': 'التحليلات', 'settings': 'الإعدادات', 'planned': 'مخطط', 'eaten': 'تم تناوله',
      'addFood': 'إضافة طعام', 'foodName': 'اسم الطعام', 'kcal': 'السعرات', 'protein': 'بروتين',
      'carbs': 'كربوهيدرات', 'fat': 'دهون', 'per100': 'لكل ١٠٠ غرام', 'grams': 'غرامات',
      'addMeal': 'إضافة وجبة', 'breakfast': 'فطور', 'lunch': 'غداء', 'dinner': 'عشاء',
      'snack': 'وجبة خفيفة', 'save': 'حفظ', 'cancel': 'إلغاء', 'delete': 'حذف',
      'favorite': 'المفضلة', 'empty': 'لا توجد سجلات بعد.', 'search': 'البحث عن طعام',
      'remaining': 'المتبقي', 'goals': 'الأهداف اليومية', 'week': 'آخر ٧ أيام',
      'shopping': 'قائمة التسوق', 'copyYesterday': 'نسخ الأمس',
      'export': 'نسخ نسخة JSON', 'import': 'استيراد نسخة JSON',
      'clear': 'حذف كل البيانات', 'confirm': 'تأكيد العملية؟',
      'copied': 'تم النسخ', 'importPaste': 'الصق نسخة JSON',
      'invalid': 'تحقق من القيم.', 'error': 'تعذر حفظ التغييرات.',
      'success': 'تم الحفظ', 'pickDay': 'اختيار التاريخ', 'nutrition': 'القيم الغذائية',
      'noFood': 'أضف طعاماً أولاً.', 'food': 'الطعام', 'slot': 'نوع الوجبة',
      'summary': 'الملخص اليومي', 'copy': 'نسخ', 'progress': 'تقدم الهدف',
      'confirmDelete': 'حذف العنصر المحدد؟', 'confirmReset': 'سيتم حذف جميع البيانات نهائياً.',
      'confirmImport': 'ستستبدل النسخة الاحتياطية السجلات الحالية.',
      'privacy': 'تخزن البيانات مشفرة على الجهاز. قد تتمكن تطبيقات أخرى من قراءة النسخ المنسوخة.',
      'disclaimer': 'القيم الغذائية من إدخال المستخدم وليست نصيحة طبية.',
    },
  };
}
