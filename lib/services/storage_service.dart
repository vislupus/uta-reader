import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/song_model.dart';

class StorageService {
  static const String _fileName = 'songs_data.json';
  
  /// Връща директорията където е програмата
  String get _appDirectory {
    // Взимаме пътя до изпълнимия файл
    final exePath = Platform.resolvedExecutable;
    // Взимаме директорията
    return p.dirname(exePath);
  }
  
  /// Връща пълния път до JSON файла
  String get filePath {
    return p.join(_appDirectory, _fileName);
  }
  
  File get _localFile {
    return File(filePath);
  }
  
  Future<List<SongModel>> loadSongs() async {
    try {
      final file = _localFile;
      if (!file.existsSync()) {
        print('📁 Songs file does not exist yet at: ${file.path}');
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      print('📁 Loaded ${jsonList.length} songs from: ${file.path}');
      return jsonList.map((j) => SongModel.fromJson(j)).toList();
    } catch (e) {
      print('❌ Error loading songs: $e');
      return [];
    }
  }
  
  Future<void> saveSongs(List<SongModel> songs) async {
    try {
      final file = _localFile;
      final jsonList = songs.map((s) => s.toJson()).toList();
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);
      await file.writeAsString(jsonString);
      print('💾 Saved ${songs.length} songs to: ${file.path}');
    } catch (e) {
      print('❌ Error saving songs: $e');
      rethrow;
    }
  }
  
  Future<void> deleteSong(String id) async {
    final songs = await loadSongs();
    songs.removeWhere((s) => s.id == id);
    await saveSongs(songs);
  }
  
  /// Показва пътя до файла (за debug)
  void printFilePath() {
    print('📂 Songs file location: $filePath');
  }
}