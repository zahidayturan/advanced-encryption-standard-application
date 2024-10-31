import 'dart:async';
import 'dart:io';
import 'package:aes/core/constants/colors.dart';
import 'package:aes/routes/encryption/generate_key.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class VoiceProductionPage extends StatefulWidget {
  const VoiceProductionPage({super.key});

  @override
  State<VoiceProductionPage> createState() => _VoiceProductionPageState();
}

class _VoiceProductionPageState extends State<VoiceProductionPage> with SingleTickerProviderStateMixin {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  String _filePath = '';
  Duration _recordDuration = Duration.zero;
  Timer? _timer;

  AppColors colors = AppColors();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _deleteRecording();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _initializeRecorder();
    _initializePlayer();
  }

  Future<void> _initializeRecorder() async {
    await _recorder!.openRecorder();
    await _requestPermissions();
  }

  Future<void> _initializePlayer() async {
    if (_player != null) {
      await _player!.openPlayer();
    } else {
      debugPrint("Player başlatılamıyor, null durumda.");
    }
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/recorded_audio.aac';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _recordDuration += const Duration(seconds: 1);
      });
      debugPrint('Kayıt Süresi: ${_recordDuration.inSeconds} saniye');
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    setState(() {
      _recordDuration = Duration.zero;
    });
  }

  Future<void> _startRecording() async {
    _deleteRecording();
    setState(() {
      _isRecording = true;
      _recordDuration = Duration.zero;
      _animationController.forward();
    });
    _filePath = await getFilePath();
    await _recorder!.startRecorder(
      toFile: _filePath,
      codec: Codec.aacADTS,
      bitRate: 128000,
      sampleRate: 44100,
    );

    _stopTimer();
    _startTimer();
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    _stopTimer();
    setState(() {
      _isRecording = false;
      _animationController.reverse();
    });
    debugPrint('Ses kaydedildi: $_filePath');
  }

  Future<void> _playRecording() async {
    if (_player == null) {
      debugPrint('Player null, başlatılamıyor.');
      return;
    }

    if (_filePath.isEmpty) {
      debugPrint('Dosya yolu boş, kayıt yapılmamış olabilir.');
      return;
    }

    setState(() {
      _isPlaying = true;
    });

    try {
      await _player!.startPlayer(
        fromURI: _filePath,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
    } catch (e) {
      debugPrint('Ses oynatma hatası: $e');
    }
  }

  Future<void> _stopPlaying() async {
    await _player!.stopPlayer();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _deleteRecording() async {
    if (_filePath.isEmpty) {
      debugPrint('Silinecek dosya yok.');
      return;
    }

    final file = File(_filePath);

    if (await file.exists()) {
      try {
        await file.delete();
        setState(() {
          _filePath = '';
          _stopTimer();
        });
        debugPrint('Kayıt başarıyla silindi.');
      } catch (e) {
        debugPrint('Dosya silme hatası: $e');
      }
    } else {
      debugPrint('Dosya bulunamadı: $_filePath');
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _player!.closePlayer();
    _animationController.dispose();
    super.dispose();
  }

  Future<String?> pickAudioPath() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      if (file.path != null) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GenerateKey(codeOrPath: file.path!,type: "voice",)),
        );
        return file.path;
      } else {
        debugPrint("Dosya yolu bulunamadı.");
        return null;
      }
    } else {
      debugPrint("Dosya seçilmedi.");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
          title: const RegularText(texts: "Ses Kaydedici",size: 17)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isRecording ? Icons.mic : Icons.mic_none,
                  size: 84,
                  color: _isRecording ? colors.red : colors.blueMid,
                ),
                RegularText(
                  texts: _isRecording ? '${_recordDuration.inSeconds} saniye':'Başlatılmadı' , size: 18,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? colors.red : colors.blueMid
                    ),
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      size: 50,
                      color: colors.grey,
                      progress: _animationController,
                    ),
                  ),
                ),
                const SizedBox(height: 12,),
                ElevatedButton(onPressed: () {
                  pickAudioPath();

                },
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(colors.blueMid)
                    ),
                    child: RegularText(texts: "Ses dosyası yükle",color: colors.grey,)),
                const SizedBox(height: 20),
                if (_filePath.isNotEmpty && !_isRecording)
                  const RegularText(texts: 'Ses Kaydedildi', size: 15,),
                const SizedBox(height: 10),
                if (_filePath.isNotEmpty && !_isRecording)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isPlaying ? _stopPlaying : _playRecording,
                        child: Text(_isPlaying ? 'Durdur' : 'Kaydı Dinle'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _deleteRecording,
                        child: const Text('Kaydı Sil'),
                      ),
                    ],
                  ),
                const SizedBox(height: 40),
                if (_filePath.isNotEmpty && !_isRecording)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:()  async {
                            String path = await getFilePath();
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GenerateKey(codeOrPath: path,type: "voice",)),
                            );
                          },
                          child: const Text("Anahtar Üretimine Geç"),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
