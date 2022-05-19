import '../utils/utils.dart';

class Doc {
  late final int id;
  late final String title;
  late final String expiration;

  late final int fqYear;
  late final int fqHalfYear;
  late final int fqQuarter;
  late final int fqMonth;

  Doc(this.title, this.expiration, this.fqHalfYear, this.fqMonth,
      this.fqQuarter, this.fqYear);

  Doc.withId(this.id, this.title, this.expiration, this.fqHalfYear,
      this.fqMonth, this.fqQuarter, this.fqYear);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map["title"] = title;
    map["expiration"] = expiration;

    map["fqYear"] = fqYear;
    map["fqHalfYear"] = fqHalfYear;
    map["fqMonth"] = fqMonth;
    map["fqQuarter"] = fqQuarter;

    map["id"] = id;

    return map;
  }

  Doc.fromObject(dynamic o) {
    id = o["id"];
    title = o["title"];
    expiration = DateUtils.trimDate(o["expiration"]);
    fqYear = o["fqYear"];
    fqHalfYear = o["fqHalfYear"];
    fqQuarter = o["fqQuarter"];
    fqMonth = o["fqMonth"];
  }
}
