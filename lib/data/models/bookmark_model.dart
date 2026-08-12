

class BookmarkFolder {
  final String id;
  final String name;

  BookmarkFolder({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory BookmarkFolder.fromJson(Map<String, dynamic> json) {
    return BookmarkFolder(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class BookmarkNode {
  final String reference;
  final DateTime createdAt;
  final String? folderId;

  BookmarkNode({
    required this.reference,
    required this.createdAt,
    this.folderId,
  });

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'folderId': folderId,
      };

  factory BookmarkNode.fromJson(Map<String, dynamic> json) {
    return BookmarkNode(
      reference: json['reference'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      folderId: json['folderId'] as String?,
    );
  }
}

class BookmarkData {
  final List<BookmarkFolder> folders;
  final Map<String, BookmarkNode> nodes; // Key is reference

  BookmarkData({
    required this.folders,
    required this.nodes,
  });

  Map<String, dynamic> toJson() => {
        'folders': folders.map((f) => f.toJson()).toList(),
        'nodes': nodes.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory BookmarkData.fromJson(Map<String, dynamic> json) {
    final foldersList = (json['folders'] as List?)
            ?.map((e) => BookmarkFolder.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
        
    final nodesMap = <String, BookmarkNode>{};
    if (json['nodes'] != null) {
      final map = json['nodes'] as Map<String, dynamic>;
      map.forEach((key, value) {
        nodesMap[key] = BookmarkNode.fromJson(value as Map<String, dynamic>);
      });
    }

    return BookmarkData(
      folders: foldersList,
      nodes: nodesMap,
    );
  }
}
