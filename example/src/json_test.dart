part 'json_test.g.dart';

class JsonTest {
  final String id;

  JsonTest(this.id);

  factory JsonTest.fromJson(Map<String, dynamic> json) =>
      _$JsonTestFromJson(json);

  Map<String, dynamic> toJson() => _$JsonTestToJson(this);
}
