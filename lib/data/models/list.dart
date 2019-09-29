class ListDM {
  final String key;
  final String title;
  final String subtitle;

  ListDM({this.key, this.title, this.subtitle});

  factory ListDM.fromMap(Map<String, dynamic> json) => ListDM(
    key: json["key"],
    title: json["title"],
    subtitle: json["subtitle"],
  );

  Map<String, dynamic> toMap() => {
    "key": key,
    "title": title,
    "subtitle": subtitle
  };
}