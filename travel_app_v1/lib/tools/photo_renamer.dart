// ignore_for_file: avoid_print

import 'dart:io';

Future<void> renamePhotosInDistricts(String baseDirPath) async {
  final basePath = Directory(baseDirPath);

  if (!basePath.existsSync()) {
    print('Hata: $basePath klasörü bulunamadı.');
    return;
  }

  final districts = basePath.listSync().whereType<Directory>();

  for (var districtDir in districts) {
    print('İlçe: ${districtDir.path}');

    final places = districtDir.listSync().whereType<Directory>();

    for (var placeDir in places) {
      print('  Yer: ${placeDir.path}');

      final files = placeDir.listSync().whereType<File>().toList();

      final photos = files.where((f) {
        final ext = f.path.toLowerCase();
        return ext.endsWith('.png') ||
            ext.endsWith('.jpg') ||
            ext.endsWith('.jpeg') ||
            ext.endsWith('.gif') ||
            ext.endsWith('.bmp');
      }).toList();

      print('    Fotoğraf sayısı: ${photos.length}');

      for (int i = 0; i < photos.length; i++) {
        final file = photos[i];
        final ext = file.path.split('.').last;
        final newPath = '${placeDir.path}/${i + 1}.$ext';

        if (File(newPath).existsSync()) {
          final tempPath = '${placeDir.path}/temp_${i + 1}.$ext';
          File(newPath).renameSync(tempPath);
          file.renameSync(newPath);
          File(tempPath).renameSync(file.path);
        } else {
          file.renameSync(newPath);
        }
        print('      ${file.path.split('/').last} -> ${i + 1}.$ext');
      }
    }
  }
}
