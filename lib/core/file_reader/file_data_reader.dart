import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';

class FileDataReader {
  // Reads and parses an SVG file into a nested Map
  static Future<Map<String, dynamic>> readSvg(String filePath) async {
    final file = File(filePath);
    final svgString = await file.readAsString();

    XmlDocument document = XmlDocument.parse(svgString);

    Map<String, dynamic> svgElementToMap(XmlElement element) {
      return {
        'tag': element.name.local,
        'attributes': Map<String, String>.fromEntries(
          element.attributes.map(
            (attr) => MapEntry(attr.name.local, attr.value),
          ),
        ),
        'text': element.value,
        'children': element.children
            .whereType<XmlElement>()
            .map((child) => svgElementToMap(child))
            .toList(),
      };
    }

    return svgElementToMap(document.rootElement);
  }

  // Reads an Excel file and converts sheets into a List of Maps
  static Future<Map<String, dynamic>> readExcel(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    Map<String, dynamic> excelData = {};

    for (var sheetName in excel.sheets.keys) {
      var sheet = excel.sheets[sheetName];
      if (sheet == null) continue;

      List<Map<String, dynamic>> rows = [];

      List<String> headers = [];
      bool headersProcessed = false;

      for (var row in sheet.rows) {
        if (row.isEmpty) continue;

        // First row as headers
        if (!headersProcessed) {
          headers = row.map((cell) => cell?.value.toString() ?? '').toList();
          headersProcessed = true;
        } else {
          Map<String, dynamic> rowData = {};
          for (int i = 0; i < headers.length; i++) {
            rowData[headers[i]] = i < row.length ? row[i]?.value : null;
          }
          rows.add(rowData);
        }
      }

      excelData[sheetName] = rows;
    }

    return excelData;
  }

  static Future<Map<String, dynamic>?> pickAndReadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['csv', 'xls', 'xlsx'],
      type: FileType.custom,
    );
    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      String extension = path.split('.').last.toLowerCase();

      if (extension == 'svg') {
        return await readSvg(path);
      } else if (extension == 'xls' || extension == 'xlsx') {
        return await readExcel(path);
      } else {
        // Unsupported file type
        return null;
      }
    }
    return null; // No file picked
  }
}
