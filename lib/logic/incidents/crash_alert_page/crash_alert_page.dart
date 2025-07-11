import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:impaxt_alert/logic/incidents/provider/providers.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CrashAlertPage extends ConsumerStatefulWidget {
  const CrashAlertPage({required this.evt, super.key});
  final AccelerometerEvent evt;

  @override
  ConsumerState<CrashAlertPage> createState() => _CrashAlertPageState();
}

class _CrashAlertPageState extends ConsumerState<CrashAlertPage> {
  Timer? timer;
  int sec = 30;

  late SpeechToText _speechToText;
  bool _speechEnabled = false;
  bool _isListening = false;
  String _recognizedWords = '';
  Timer? _restartTimer;
  bool _disposed = false;
  bool _responseProcessed = false;
  bool _ttsCompleted = false; // Traccia se il TTS è completato

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
    _startCountdown();
  }

  Future<void> _initializeSpeechRecognition() async {
    if (_disposed || _responseProcessed) return;

    _speechToText = SpeechToText();

    // Verifica permessi microfono
    final micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        print('Permesso microfono negato');
        return;
      }
    }

    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          if (_disposed || _responseProcessed) return;
          print('Speech status: $status');

          if (mounted) {
            setState(() {
              _isListening = status == 'listening';
              print('>>> _isListening impostato a: $_isListening');
            });
          }

          // Riavvia solo se non stiamo ascoltando e non abbiamo una risposta
          if ((status == 'done' || status == 'notListening') &&
              !_hasValidResponse(_recognizedWords) &&
              !_isListening) { // Aggiunto controllo per evitare restart durante l'ascolto
            _scheduleRestart();
          }
        },
        onError: (error) {
          if (_disposed || _responseProcessed) return;
          print('Errore speech: ${error.errorMsg}');
          _handleSpeechError(error);
        },
      );

      print('Speech recognition inizializzato: $_speechEnabled');
    } catch (e) {
      print('Errore inizializzazione speech: $e');
      if (mounted) {
        setState(() => _speechEnabled = false);
      }
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    if (_disposed || _responseProcessed) return;

    if (mounted) {
      setState(() => _isListening = false);
    }

    print('Errore speech: ${error.errorMsg} - Permanente: ${error.permanent}');

    // Gestisci diversi tipi di errori
    switch (error.errorMsg) {
      case 'error_busy':
      // Il servizio è occupato, riprova dopo un po'
        print('Servizio speech occupato, riprovo tra 3 secondi');
        _scheduleRestart(delay: 3000);
        break;
      case 'error_network':
      // Errore di rete, riprova
        print('Errore di rete, riprovo tra 5 secondi');
        _scheduleRestart(delay: 5000);
        break;
      case 'error_no_match':
      // Nessun match, continua ad ascoltare
        print('Nessun match trovato, riprovo tra 1 secondo');
        _scheduleRestart(delay: 1000);
        break;
      case 'error_audio':
      // Problema audio, riprova
        print('Problema audio, riprovo tra 2 secondi');
        _scheduleRestart(delay: 2000);
        break;
      case 'error_permission':
      // Problema permessi
        print('Errore permessi, disabilito speech');
        if (mounted) {
          setState(() => _speechEnabled = false);
        }
        return;
      default:
      // Solo per errori realmente permanenti
        if (error.permanent) {
          print('Errore permanente, disabilito speech');
          if (mounted) {
            setState(() => _speechEnabled = false);
          }
          return;
        } else {
          print('Errore temporaneo, riprovo tra 2 secondi');
          _scheduleRestart(delay: 2000);
        }
    }
  }

  void _scheduleRestart({int delay = 1500}) {
    if (_disposed || _responseProcessed || !_speechEnabled) return;

    print('Scheduling restart in ${delay}ms');
    _restartTimer?.cancel();
    _restartTimer = Timer(Duration(milliseconds: delay), () {
      if (!_disposed && !_responseProcessed && _speechEnabled && mounted && _ttsCompleted) {
        print('Riavvio speech recognition');
        _startListening();
      }
    });
  }

  void _startCountdown() {
    if (_disposed || _responseProcessed) return;

    // Avvia TTS e poi speech recognition
    _startTTSAndSpeech();

    // Timer countdown
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_disposed || _responseProcessed) {
        t.cancel();
        return;
      }

      if (sec <= 0) {
        _handleResponse(false); // Timeout = No
      } else {
        if (mounted) {
          setState(() => sec--);
        }
      }
    });
  }

  Future<void> _startTTSAndSpeech() async {
    try {
      // Prima il TTS
      print('Avvio TTS...');
      await ref.read(ttsProvider).speak('Tutto ok? Premi Sì o No o dillo a voce');

      // Aspetta che il TTS finisca prima di iniziare il speech recognition
      await Future.delayed(const Duration(milliseconds: 3000)); // Aumentato a 3 secondi

      _ttsCompleted = true;
      print('TTS completato, avvio speech recognition');

      // Poi avvia il speech recognition
      if (!_disposed && !_responseProcessed && _speechEnabled) {
        _startListening();
      }
    } catch (e) {
      print('Errore durante TTS: $e');
      _ttsCompleted = true;
      // Avvia comunque il speech recognition
      if (!_disposed && !_responseProcessed && _speechEnabled) {
        _startListening();
      }
    }
  }

  Future<void> _startListening() async {
    if (_disposed || _responseProcessed || !_speechEnabled || !mounted) return;

    print('>>> Avvio ascolto speech recognition');

    try {
      // Ferma ascolto precedente
      if (_speechToText.isListening) {
        print('>>> Fermando ascolto precedente');
        await _speechToText.stop();
        await Future.delayed(const Duration(milliseconds: 1000)); // Aumentato delay
      }

      if (_disposed || _responseProcessed) return;

      print('>>> Avvio nuovo ascolto');
      await _speechToText.listen(
        onResult: (result) {
          if (_disposed || _responseProcessed) return;

          final words = result.recognizedWords.toLowerCase().trim();
          print("Riconosciuto: '$words'");

          if (mounted) {
            setState(() => _recognizedWords = words);
          }

          if (_hasValidResponse(words)) {
            print("Risposta valida rilevata: '$words'");
            _processVoiceResponse(words);
          }
        },
        listenFor: const Duration(seconds: 15), // Aumentato a 15 secondi
        pauseFor: const Duration(seconds: 2),   // Ridotto a 2 secondi
        localeId: 'it_IT',
        onSoundLevelChange: (level) {
          // Opzionale: puoi usare questo per mostrare il livello audio
          // print('Livello audio: $level');
        },
      );
    } catch (e) {
      print('Errore durante ascolto: $e');
      if (mounted) {
        setState(() => _isListening = false);
      }
      _scheduleRestart(delay: 2000);
    }
  }

  bool _hasValidResponse(String words) {
    if (words.isEmpty) return false;

    final yesWords = ['sì', 'si', 'yes', 'ok', 'okay', 'va bene', 'tutto ok',
      'tutto bene', 'sto bene', 'bene', 'perfetto', 'va bene', 'tutto apposto'];
    final noWords = ['no', 'aiuto', 'help', 'non sto bene', 'male', 'emergenza',
      'chiamate', 'soccorso', 'non va bene', 'male', 'non bene'];

    // Controlla se contiene parole complete per evitare falsi positivi
    for (String word in yesWords) {
      if (words.contains(word)) {
        print("Trovata parola SI: '$word' in '$words'");
        return true;
      }
    }

    for (String word in noWords) {
      if (words.contains(word)) {
        print("Trovata parola NO: '$word' in '$words'");
        return true;
      }
    }

    return false;
  }

  void _processVoiceResponse(String words) {
    if (_disposed || _responseProcessed) return;

    final yesWords = ['sì', 'si', 'yes', 'ok', 'okay', 'va bene', 'tutto ok',
      'tutto bene', 'sto bene', 'bene', 'perfetto', 'va bene', 'tutto apposto'];

    final isYes = yesWords.any((word) => words.contains(word));
    print("Risposta vocale: ${isYes ? 'SI' : 'NO'} per: '$words'");

    _handleResponse(isYes);
  }

  void _handleResponse(bool isYes) {
    if (_responseProcessed) return;
    _responseProcessed = true;

    print("Gestione risposta: ${isYes ? 'SI' : 'NO'}");
    timer?.cancel();
    _restartTimer?.cancel();
    _stopSpeechRecognition();

    if (isYes) {
      _handleYes();
    } else {
      _handleNo();
    }
  }

  Future<void> _stopSpeechRecognition() async {
    print('>>> Fermando speech recognition');
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    if (mounted) {
      setState(() => _isListening = false);
    }
  }


  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void _handleYes() async {
    print("Risposta: SI - Torno alla home");
    await ref.read(daoProvider).insert(
        x: widget.evt.x,
        y: widget.evt.y,
        z: widget.evt.z,
        ref: ref,
        called_rescue: 1,
        response_time: 30-sec,
    );

    _navigateBack();
  }

  Future<void> _handleNo() async {
    print("Risposta: NO - Invio SMS e torno alla home");
    print(Geolocator.getCurrentPosition());
    try {
      // Invia SMS di emergenza
      final contacts = ref.read(contactsProvider);
      final msg = 'SOS! Mi trovo in pericolo '
          '${DateTime.now().toIso8601String()} '
          '(x:${widget.evt.x.toStringAsFixed(1)}, '
          'y:${widget.evt.y.toStringAsFixed(1)}, '
          'z:${widget.evt.z.toStringAsFixed(1)})';

      await ref.read(smsProvider).sendIncidentAlert(contacts, msg);

      await ref.read(daoProvider).insert(
        x: widget.evt.x,
        y: widget.evt.y,
        z: widget.evt.z,
        ref: ref,
        called_rescue: 1,
        response_time: 30-sec,
      );

      _determinePosition();

      print("SMS inviato con successo");
    } catch (e) {
      await ref.read(daoProvider).insert(
          x: widget.evt.x,
          y: widget.evt.y,
          z: widget.evt.z,
          ref: ref,
          called_rescue: 1,
          response_time: 30-sec,
      );
      _determinePosition();
      print('Errore invio SMS: $e');
    }

    await ref.read(ttsProvider).speak('Sto notificado i contatti');

    _navigateBack();
  }

  void _navigateBack() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.red.shade900,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tutto ok?',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Countdown
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '$sec',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Indicatore Speech Recognition
            if (_speechEnabled && !_responseProcessed) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isListening ? Icons.mic : Icons.mic_off,
                          color: _isListening ? Colors.greenAccent : Colors.white70,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isListening ? 'Ti sto ascoltando...' :
                            !_ttsCompleted ? 'Attendo fine messaggio...' :
                            'Preparando ascolto...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    if (_recognizedWords.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Hai detto: "$_recognizedWords"',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Dì "SÌ" o "NO" oppure usa i bottoni',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Bottoni
            if (!_responseProcessed) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    'SÌ',
                    Colors.green.shade600,
                    Icons.check_circle,
                        () => _handleResponse(true),
                  ),
                  _buildActionButton(
                    'NO',
                    Colors.red.shade600,
                    Icons.cancel,
                        () => _handleResponse(false),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

            // Info timeout
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Se non rispondi entro 30 secondi\nverrà inviato automaticamente un SMS di emergenza',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 24),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    timer?.cancel();
    _restartTimer?.cancel();
    _speechToText.stop();
    _speechToText.cancel();
    super.dispose();
  }

}