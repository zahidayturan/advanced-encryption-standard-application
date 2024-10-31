import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/get/get_storage_helper.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/loading.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/text_field.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AppColors colors = AppColors();
  final localStorage = GetLocalStorage();
  FileOperations fileOperations = FileOperations();
  String? uUUID;
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    uUUID = localStorage.getUUID();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: null,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
                child: Column(
              children: [
                appBar(context),
                const SizedBox(height: 8),
                userInfo(),
                const SizedBox(height: 12),
                dataActions(),
                const SizedBox(height: 12)
              ],
            )),
          ),
        ),
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).colorScheme.secondary,
            )),
        const RegularText(
          texts: "Ayarlar",
          size: 17,
          align: TextAlign.end,
        )
      ],
    );
  }

  Widget userInfo() {
    return BaseContainer(
      padding: 12,
      child: Column(
        children: [
          const FullTextField(
              fieldName: "Kullanıcı Kimliğiniz",
              hintText: "Değiştirilemez",
              myIcon: Icons.person_outline_rounded,
              readOnly: true,
              border: false),
          const SizedBox(height: 8,),
          RegularText(texts: uUUID!,maxLines: 3,color: colors.blueMid,),
          const SizedBox(height: 20,),
          const RegularText(
            texts:
            "Kullanıcı kimliiniz otomatik oluşturulmuştur. "
                "Bu kimliği şu an da değiştiremezsiniz. "
                "Dosyalarınız ve anahtarlarınız bu kimlik bilgilerine göre "
                "saklanacağı için bu kimliği kaybetmeniz durumunda kayıtlı "
                "dosyalarınıza ve anahtarlarınıza erişiminiz olamayacaktır.",
            size: 11,
            maxLines: 10,
            align: TextAlign.justify,
          )
        ],
      ),
    );
  }

  Widget dataActions(){
    return BaseContainer(
      padding: 12,
      child: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                LoadingDialog.showLoading(context,message:"Veriler siliniyor" );
                await fileOperations.deleteAllUserData();
                LoadingDialog.hideLoading(context);
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(colors.red),
                  padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 12,horizontal: 8))
              ),
              child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,color: colors.grey,size: 20,),
                    const SizedBox(width: 8),
                    RegularText(texts: "Tüm Verileri Kalıcı Olarak Sil",color: colors.grey,maxLines: 2,)

                  ])),
          const SizedBox(height: 8),
          const RegularText(
            texts: "Tüm şifrelenmiş dosyaları ve oluşturulmuş anahtarları siler. Bu işlem geri alınamaz.",
            size: 11,
            maxLines: 4,
            align: TextAlign.center,
          )

        ],
      ),
    );
  }
}
