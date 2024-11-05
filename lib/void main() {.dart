void main() {
  String tlvString = '0103426f6202033132'; // Exemple de chaîne TLV

  List<TLV> tlvList = decodeTLV(tlvString);
  
  print('Décodage TLV:');
  for (var tlv in tlvList) {
    tlv.afficher(); // Appel de la méthode pour afficher le contenu
  }
}

class TLV {
  String tag;
  int length;
  String value;

  TLV({required this.tag, required this.length, required this.value});

  // Méthode pour afficher le contenu du TLV
  void afficher() {
    print('Tag: $tag, Length: $length, Value: $value');
  }
}

List<TLV> decodeTLV(String tlvString) {
  List<TLV> tlvList = [];
  int index = 0;

  while (index < tlvString.length) {
    // Extraire le tag (2 caractères)
    String tag = tlvString.substring(index, index + 2);
    index += 2;

    // Extraire la longueur (2 caractères convertis en nombre)
    int length = int.parse(tlvString.substring(index, index + 2), radix: 16);
    index += 2;

    // Extraire la valeur (en fonction de la longueur)
    String value = tlvString.substring(index, index + length * 2);
    index += length * 2;

    // Ajouter l'objet TLV à la liste
    tlvList.add(TLV(tag: tag, length: length, value: value));
  }

  return tlvList;
}
