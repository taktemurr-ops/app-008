import 'package:flutter_test/flutter_test.dart';
import 'package:uyg_yemek_planlayici/uyg_yemek_planlayici.dart';

void main() {
  test('33 dilde ad ve açıklama, doğru kimlik', () {
    expect(yemekPlanlayiciTool.id, yemekPlanlayiciId);
    expect(yemekPlanlayiciTool.title.length, 33);
    expect(yemekPlanlayiciTool.tagline.length, 33);
  });
}
