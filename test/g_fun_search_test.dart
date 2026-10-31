import 'package:flutter_test/flutter_test.dart';
import 'package:visit_proof/core/utils/general_functions.dart/g_fun_search.dart';

void main() {
  test('an empty query matches everything', () {
    expect(GFunSearch.matches('  ', ['anything']), isTrue);
  });

  test('matching ignores case and checks every field', () {
    expect(GFunSearch.matches('vis-0001', [null, 'VIS-000123']), isTrue);
  });

  test('no field contains the query', () {
    expect(GFunSearch.matches('riyadh', ['Jeddah', null]), isFalse);
  });
}
