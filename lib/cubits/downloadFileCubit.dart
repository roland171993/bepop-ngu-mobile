import 'dart:io';

import 'package:dio/dio.dart';
import 'package:bepop_ngu/data/models/studyMaterial.dart';
import 'package:bepop_ngu/data/repositories/subjectRepository.dart';
import 'package:bepop_ngu/utils/errorMessageKeysAndCodes.dart';
import 'package:bepop_ngu/utils/utils.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class DownloadFileState {}

class DownloadFileInitial extends DownloadFileState {}

class DownloadFileCheckingExistence extends DownloadFileState {}

class DownloadFileAlreadyExists extends DownloadFileState {
  final String existingFileUrl;

  DownloadFileAlreadyExists(this.existingFileUrl);
}

class DownloadFileInProgress extends DownloadFileState {
  final double uploadedPercentage;

  DownloadFileInProgress(this.uploadedPercentage);
}

class DownloadFileSuccess extends DownloadFileState {
  final String downloadedFileUrl;

  DownloadFileSuccess(this.downloadedFileUrl);
}

class DownloadFileProcessCanceled extends DownloadFileState {}

class DownloadFileFailure extends DownloadFileState {
  final String errorMessage;

  DownloadFileFailure(this.errorMessage);
}

class DownloadFileCubit extends Cubit<DownloadFileState> {
  final SubjectRepository _subjectRepository;

  DownloadFileCubit(this._subjectRepository) : super(DownloadFileInitial());

  final CancelToken _cancelToken = CancelToken();

  void _downloadedFilePercentage(double percentage) {
    emit(DownloadFileInProgress(percentage));
  }

  Future<void> writeFileFromTempStorage({
    required String sourcePath,
    required String destinationPath,
  }) async {
    final tempFile = File(sourcePath);
    final byteData = await tempFile.readAsBytes();
    final downloadedFile = File(destinationPath);
    //write into downloaded file
    await downloadedFile.writeAsBytes(
      byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
  }

  Future<String?> _checkIfFileExists({
    required StudyMaterial studyMaterial,
    required bool storeInExternalStorage,
  }) async {
    try {
      // Always check external storage first (priority for permanent files)
      if (await Utils.hasStoragePermissionGiven()) {
        final externalDirectory = Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory();
        final externalFilePath =
            "${externalDirectory?.path}/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

        final externalFile = File(externalFilePath);
        if (await externalFile.exists()) {
          return externalFilePath; // Found in external storage
        }
      }

      // If not found in external storage, check temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempFilePath =
          "${tempDir.path}/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

      final tempFile = File(tempFilePath);
      if (await tempFile.exists()) {
        return tempFilePath; // Found in temp storage
      }

      return null; // File not found in either location
    } catch (e) {
      return null;
    }
  }

  Future<void> downloadFile({
    required StudyMaterial studyMaterial,
    required bool storeInExternalStorage,
  }) async {
    emit(DownloadFileCheckingExistence());

    // First, check if file already exists
    final existingFilePath = await _checkIfFileExists(
      studyMaterial: studyMaterial,
      storeInExternalStorage: storeInExternalStorage,
    );

    if (existingFilePath != null) {
      // File already exists, emit success with existing file path
      emit(DownloadFileAlreadyExists(existingFilePath));
      return;
    }

    emit(DownloadFileInProgress(0.0));
    try {
      //if wants to download the file then
      if (storeInExternalStorage) {
        Future<void> thingsToDoAfterPermissionIsGiven(
            bool isPermissionGranted) async {
          //storing the fie temp
          final Directory tempDir = await getTemporaryDirectory();
          final tempFileSavePath =
              "${tempDir.path}/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

          await _subjectRepository.downloadStudyMaterialFile(
            cancelToken: _cancelToken,
            savePath: tempFileSavePath,
            updateDownloadedPercentage: _downloadedFilePercentage,
            url: studyMaterial.fileUrl,
          );

          //download file
          String downloadFilePath = Platform.isAndroid && isPermissionGranted
              ? (await getExternalStorageDirectory())?.path ?? ""
              : (await getApplicationDocumentsDirectory()).path;

          downloadFilePath =
              "$downloadFilePath/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

          await writeFileFromTempStorage(
            sourcePath: tempFileSavePath,
            destinationPath: downloadFilePath,
          );

          emit(DownloadFileSuccess(downloadFilePath));
        }

        //if user has given permission to download and view file or if it is for android
        if (await Utils.hasStoragePermissionGiven()) {
          await thingsToDoAfterPermissionIsGiven(true);
        } else {
          //if user does not give permission to store files in download directory
          emit(
            DownloadFileFailure(
              ErrorMessageKeysAndCode.permissionNotGivenCode,
            ),
          );
          openAppSettings();
        }
      } else {
        //download file for just to see
        final Directory tempDir = await getTemporaryDirectory();
        final savePath =
            "${tempDir.path}/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

        await _subjectRepository.downloadStudyMaterialFile(
          cancelToken: _cancelToken,
          savePath: savePath,
          updateDownloadedPercentage: _downloadedFilePercentage,
          url: studyMaterial.fileUrl,
        );

        emit(DownloadFileSuccess(savePath));
      }
    } catch (e) {
      if (_cancelToken.isCancelled) {
        emit(DownloadFileProcessCanceled());
      } else {
        emit(DownloadFileFailure(e.toString()));
      }
    }
  }

  void cancelDownloadProcess() {
    _cancelToken.cancel();
  }
}
