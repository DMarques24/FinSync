import 'dart:io';

import 'package:finsync/domain/repositories/desire_repository.dart';

class UploadDesireImage {
  final DesireRepository desireRepository;

  UploadDesireImage(this.desireRepository);

  Future<String> call(File file) async {
    return await desireRepository.uploadImage(file);
  }
}
