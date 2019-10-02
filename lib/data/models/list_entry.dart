class ListEntryDM {
  final String key;
  final String title;
  final String subtitle;
  final String body;
  final int position;

  ListEntryDM({this.key, this.title, this.subtitle, this.body, this.position});

  factory ListEntryDM.fromMap(Map<String, dynamic> json) => ListEntryDM(
    key: json["key"],
    title: json["title"],
    subtitle: json["subtitle"],
    body: json["body"],
    position: json["position"],
  );

  Map<String, dynamic> toMap() => {
    "key": key,
    "title": title,
    "subtitle": subtitle,
    "body": body,
    "position": position,
  };
}