import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class FileDataReader {
  // Reads and parses an SVG file into a nested Map
  static Future<List<Map<String, dynamic>>> readCsv(String filePath) async {
    final file = File(filePath);
    final csvString = await file.readAsString();

    List<Map<String, dynamic>> parseCsvToMap(String csv) {
      final lines = csv.trim().split('\n');
      if (lines.isEmpty) return [];

      // Extract headers, removing any quotes
      final headers = lines.first
          .split(',')
          .map((h) => h.replaceAll('"', '').trim())
          .toList();

      final List<Map<String, String>> rows = [];

      for (var i = 1; i < lines.length; i++) {
        final values = lines[i]
            .split(',')
            .map((v) => v.replaceAll('"', '').trim())
            .toList();
        if (values.length != headers.length) {
          // Skip or handle error for malformed rows
          continue;
        }
        final Map<String, String> rowMap = {};
        for (var j = 0; j < headers.length; j++) {
          rowMap[headers[j]] = values[j];
        }
        rows.add(rowMap);
      }
      return rows;
    }

    return parseCsvToMap(csvString);
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

  static Future<Object?> pickAndReadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['csv', 'xls', 'xlsx'],
      type: FileType.custom,
    );
    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      String extension = path.split('.').last.toLowerCase();
      if (extension == 'csv') {
        return await readCsv(path);
      } else if (extension == 'xls' || extension == 'xlsx') {
        return await readExcel(path);
      } else {
        return null;
      }
    }
    return null;
  }
}
