import 'dart:io';

import 'package:bepop_ngu/data/models/studyMaterial.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

class DownloadFileButton extends StatefulWidget {
  final StudyMaterial studyMaterial;
  const DownloadFileButton({Key? key, required this.studyMaterial})
      : super(key: key);

  @override
  State<DownloadFileButton> createState() => _DownloadFileButtonState();
}

class _DownloadFileButtonState extends State<DownloadFileButton> {
  bool _isFileDownloaded = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkIfFileExists();
  }

  Future<void> _checkIfFileExists() async {
    try {
      // Check external storage first (priority for permanent files)
      if (await Utils.hasStoragePermissionGiven()) {
        final externalDirectory = Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory();
        final externalFilePath =
            "${externalDirectory?.path}/${widget.studyMaterial.fileName}.${widget.studyMaterial.fileExtension}";

        final externalFile = File(externalFilePath);
        if (await externalFile.exists()) {
          setState(() {
            _isFileDownloaded = true;
            _isChecking = false;
          });
          return;
        }
      }

      // If not found in external storage, check temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempFilePath =
          "${tempDir.path}/${widget.studyMaterial.fileName}.${widget.studyMaterial.fileExtension}";

      final tempFile = File(tempFilePath);
      if (await tempFile.exists()) {
        setState(() {
          _isFileDownloaded = true;
          _isChecking = false;
        });
        return;
      }

      setState(() {
        _isFileDownloaded = false;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _isFileDownloaded = false;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Container(
        width: 30,
        height: 30,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () async {
        await Utils.openDownloadBottomsheet(
          context: context,
          storeInExternalStorage: true,
          studyMaterial: widget.studyMaterial,
        );

        // Refresh the state after download action
        _checkIfFileExists();
      },
      child: Container(
        width: 30,
        height: 30,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: _isFileDownloaded
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8)
              : Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: _isFileDownloaded
            ? Icon(
                Icons.check,
                color: Theme.of(context).scaffoldBackgroundColor,
                size: 14,
              )
            : SvgPicture.asset(Utils.getImagePath("download_icon.svg")),
      ),
    );
  }
}
