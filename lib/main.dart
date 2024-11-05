import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, String>> entries = [];
  final Map<String, String> labelMap = {
    'First Name': 'fn',
    'Last Name': 'ln',
    'Phone': 'ph',
    'Television': 'tl',
  };

  String? selectedLabel;
  final TextEditingController valueController = TextEditingController();
  String? qrData;

  void _addEntry() {
    if (selectedLabel != null && valueController.text.isNotEmpty) {
      entries.add({
        'label': selectedLabel!,
        'value': valueController.text,
      });
      selectedLabel = null; // Reset selection
      valueController.clear(); // Clear the input field
      setState(() {});
    }
  }

  void _generateQRCode() {
    if (entries.isNotEmpty) {
      StringBuffer sb = StringBuffer(); // Use StringBuffer to build the QR data
      for (var entry in entries) {
        String type = labelMap[entry['label']]!;
        String value = entry['value']!;
        String length = value.length.toString();
        sb.write('$type$length$value');
      }
      qrData = sb.toString();
      setState(() {});
    }
  }

  Future<void> _scanQRCode() async {
  try {
    final result = await BarcodeScanner.scan();
    if (result.rawContent.isNotEmpty) {
      // Simply display the raw content
      setState(() {
        qrData = result.rawContent;
      });

      // Optionally show the result in a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Scan Result'),
            content: Text(result.rawContent),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    // Handle exceptions such as user cancelling the scan
    print(e);
  }
}



  void _decodeTLV(String tlv) {
  List<Map<String, String>> newEntries = [];
  int i = 0;
  
  while (i < tlv.length) {
    // Validate if there are enough characters left in the string
    if (i + 2 >= tlv.length) {
      print('TLV string is malformed: $tlv');
      break; // Exit if the string is not valid
    }

    String type = tlv[i];

    // Try parsing the length safely
    int? length;
    try {
      length = int.parse(tlv[i + 1]); // Convert the length part to an integer
    } catch (e) {
      print('Error parsing length from TLV: $e');
      break; // Exit if length parsing fails
    }

    // Ensure the remaining TLV string is long enough for the expected length
    if (i + 2 + length > tlv.length) {
      print('TLV string length does not match the expected length: $tlv');
      break;
    }

    String value = tlv.substring(i + 2, i + 2 + length);

    // Find the label from the type
    String? label = labelMap.keys.firstWhere(
      (key) => labelMap[key] == type,
      orElse: () => '',
    );

    if (label.isNotEmpty) {
      newEntries.add({'label': label, 'value': value});
    }

    i += 2 + length; // Move to the next entry
  }

  // Update entries state and refresh the UI
  setState(() {
    entries.clear();
    entries.addAll(newEntries);
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator & Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text('${entries[index]['label']}: ${entries[index]['value']}'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('Select a Label'),
                    value: selectedLabel,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLabel = newValue;
                      });
                    },
                    items: labelMap.keys.map<DropdownMenuItem<String>>((String label) {
                      return DropdownMenuItem<String>(
                        value: label,
                        child: Text(label),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: valueController,
                    decoration: const InputDecoration(labelText: 'Value'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addEntry,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateQRCode,
              child: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 20),
            if (qrData != null)
              Column(
                children: [
                  QrImageView(
                    data: qrData!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ElevatedButton(
              onPressed: _scanQRCode,
              child: const Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}