import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/routes/file/all_files_page.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/on_tap_widget.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:aes/ui/components/shimmer_box.dart';
import 'package:aes/ui/components/snackbar.dart';
import 'package:flutter/material.dart';

class HomeFiles extends StatefulWidget {
  const HomeFiles({super.key});

  @override
  State<HomeFiles> createState() => _HomeFilesState();
}

class _HomeFilesState extends State<HomeFiles> {
  final AppColors colors = AppColors();
  final fileOperations = FileOperations();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(theme),
        const SizedBox(height: 12),
        FutureBuilder<List<int>>(
          future: fileOperations.getFileCountForInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }
            return Column(
              children: [
                _buildFileContainer("Yüklenen", "Dosyalar", Icons.file_upload_rounded, "owned", snapshot.data![0]),
                const SizedBox(height: 12),
                _buildFileContainer("Gelen", "Dosyalar", Icons.file_download_rounded, "inComing", snapshot.data![1]),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RegularText(
          texts: "Dosya İşlemleri",
          size: 15,
          color: theme.colorScheme.onTertiary,
          style: FontStyle.italic,
          weight: FontWeight.w600,
        ),
        InkWell(
          onTap: () => showSnackbar("Açıklama metni eklenmemiş", colors.greenDark, context),
          child: BaseContainer(
            padding: 2,
            color: theme.colorScheme.onTertiary,
            radius: 50,
            child: Icon(Icons.question_mark_sharp, size: 14, color: colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildFileContainer(String prefix, String suffix, IconData icon, String fileType, int fileCount) {
    final theme = Theme.of(context);
    return BaseContainer(
      height: 84,
      padding: 0,
      child: Stack(
        children: [
          Positioned(
            left: fileType == "owned" ? 14 : null,
            right: fileType == "inComing" ? 14 : null,
            bottom: 0,
            child: Image.asset(
              "assets/icons/${fileType}Files.png",
              height: 72,
              color: theme.scaffoldBackgroundColor,
            ),
          ),
          onTapWidget(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllFilesPage(fileType: fileType)),
              );
              if (result == 'updated') setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichTextWidget(
                        fontSize: 15,
                        texts: ["$prefix ", suffix],
                        colors: [theme.colorScheme.inversePrimary],
                        fontFamilies: const ["FontMedium", "FontBold"],
                      ),
                      Icon(icon, size: 22, color: theme.colorScheme.inversePrimary),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: RegularText(
                      texts: fileCount == 0 ? "$prefix dosyaları görüntüleyin" : "$prefix dosya sayısı $fileCount",
                      size: 11,
                      align: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Column(
      children: [
        ShimmerBox(height: 84),
        SizedBox(height: 12),
        ShimmerBox(height: 84),
      ],
    );
  }
}