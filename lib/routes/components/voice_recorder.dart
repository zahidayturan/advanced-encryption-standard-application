import 'dart:async';
import 'dart:io';
import 'package:aes/core/constants/colors.dart';
import 'package:aes/routes/key/generate_key.dart';
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
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final AppColors colors = AppColors();
  late AnimationController _animationController;

  bool _isRecording = false;
  bool _isPlaying = false;
  String _filePath = '';
  Duration _recordDuration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeRecorderAndPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _initializeRecorderAndPlayer() async {
    await _recorder.openRecorder();
    await _player.openPlayer();
    await Permission.microphone.request();
    _deleteRecording();
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/recorded_audio.aac';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordDuration += const Duration(seconds: 1));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _recordDuration = Duration.zero);
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _animationController.forward();
    });
    _filePath = await _getFilePath();
    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.aacADTS,
      bitRate: 128000,
      sampleRate: 44100,
    );
    _startTimer();
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    _stopTimer();
    setState(() {
      _isRecording = false;
      _animationController.reverse();
    });
  }

  Future<void> _playRecording() async {
    setState(() => _isPlaying = true);
    await _player.startPlayer(fromURI: _filePath, whenFinished: () {
      setState(() => _isPlaying = false);
    });
  }

  Future<void> _stopPlaying() async {
    await _player.stopPlayer();
    setState(() => _isPlaying = false);
  }

  Future<void> _deleteRecording() async {
    final file = File(_filePath);
    if (await file.exists()) {
      await file.delete();
      setState(() => _filePath = '');
    }
  }

  Future<String?> _pickAudioPath() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => GenerateKey(codeOrPath: path, type: "voice"),
        ));
        return path;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: const RegularText(texts: "Ses Kaydedici", size: 17),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_isRecording ? Icons.mic : Icons.mic_none, size: 84, color: _isRecording ? colors.red : colors.blueMid),
                RegularText(texts: _isRecording ? '${_recordDuration.inSeconds} saniye' : 'Başlatılmadı', size: 18),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _isRecording ? colors.red : colors.blueMid),
                    child: AnimatedIcon(icon: AnimatedIcons.play_pause, size: 50, color: colors.grey, progress: _animationController),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _pickAudioPath,
                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(colors.blueMid)),
                  child: RegularText(texts: "Ses dosyası yükle", color: colors.grey),
                ),
                const SizedBox(height: 20),
                if (_filePath.isNotEmpty && !_isRecording) const RegularText(texts: 'Ses Kaydedildi', size: 15),
                const SizedBox(height: 10),
                if (_filePath.isNotEmpty && !_isRecording)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: _isPlaying ? _stopPlaying : _playRecording, child: Text(_isPlaying ? 'Durdur' : 'Kaydı Dinle')),
                      const SizedBox(width: 20),
                      ElevatedButton(onPressed: _deleteRecording, child: const Text('Kaydı Sil')),
                    ],
                  ),
                const SizedBox(height: 40),
                if (_filePath.isNotEmpty && !_isRecording)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            String path = await _getFilePath();
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GenerateKey(codeOrPath: path, type: "voice")),
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