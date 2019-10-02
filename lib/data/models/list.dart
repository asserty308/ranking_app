class ListDM {
  final String key;
  final String title;
  final String subtitle;
  final int position;

  ListDM({this.key, this.title, this.subtitle, this.position});

  factory ListDM.fromMap(Map<String, dynamic> json) => ListDM(
    key: json["key"],
    title: json["title"],
    subtitle: json["subtitle"],
    position: json["position"],
  );

  Map<String, dynamic> toMap() => {
    "key": key,
    "title": title,
    "subtitle": subtitle,
    "position": position,
  };
}