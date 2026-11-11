import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/business_dashboard/presentation/widgets/compact_number.dart';

void main() {
  test('shortens large numbers for the stat tiles', () {
    expect(compactNumber(950), '950');
    expect(compactNumber(10800), '10.8k');
    expect(compactNumber(12000), '12k');
    expect(compactNumber(2500000), '2.5M');
  });
}
