import 'package:ru_carpooling/screens/utilities/constants.dart';
import 'package:ru_carpooling/services/api_service.dart';
import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart' as gmaps;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart' as location_pkg;
import 'package:permission_handler/permission_handler.dart' as permission_pkg;

class LocationSearchScreen extends StatefulWidget {
  final String title;
  final String googleApiKey;
  final String? initialLocation;
  final LatLng? initialLatLng;

  const LocationSearchScreen({
    super.key,
    required this.title,
    required this.googleApiKey,
    this.initialLocation,
    this.initialLatLng,
  });

  @override
  LocationSearchScreenState createState() => LocationSearchScreenState();
}

class LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final gmaps.GoogleMapsPlaces _places;
  LatLng? _selectedLocation;
  Marker? _selectedMarker;
  late GoogleMapController _mapController;

  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String _filePath = '';
  String? _transcription;

  LocationSearchScreenState()
      : _places = gmaps.GoogleMapsPlaces(apiKey: Constants.googleApiKey);

  @override
  void dispose() {
    _textEditingController.dispose();
    _recorder?.closeRecorder().then((_) {
      _recorder = null;
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initRecorder();

    // Set existing location if available
    if (widget.initialLocation != null && widget.initialLocation!.isNotEmpty) {
      _textEditingController.text = widget.initialLocation!;
    }
    if (widget.initialLatLng != null) {
      _selectedLocation = widget.initialLatLng;
      _selectedMarker = Marker(
        markerId: const MarkerId("selected"),
        position: _selectedLocation!,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _selectedLocation = newPosition;
          });
          _fetchAddressFromLatLng(newPosition); // Update address on marker move
        },
      );
    }
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();

    if (!await _checkMicrophonePermission()) {
      print("Microphone permission not granted. Cannot initialize recorder.");
      return;
    }

    try {
      await _recorder!.openRecorder();
      var dir = await getApplicationDocumentsDirectory();
      _filePath = '${dir.path}/audio.wav';
    } catch (e) {
      print("Error initializing recorder: $e");
    }
  }

  Future<bool> _checkMicrophonePermission() async {
    var status = await permission_pkg.Permission.microphone.request();

    if (status.isGranted) {
      return true; // Permission granted
    } else if (status.isDenied) {
      print("Microphone permission denied! Asking again...");
      return false; // User denied permission
    } else if (status.isPermanentlyDenied) {
      print("Microphone permission permanently denied! Open settings.");
      _showPermissionDialog();
      return false;
    }
    return false;
  }

  Future<void> _startRecording() async {
    if (_recorder == null) {
      print("Error: Recorder is not initialized!");
      return;
    }

    try {
      var dir = await getApplicationDocumentsDirectory();
      _filePath = '${dir.path}/audio.wav';

      print("Starting recording... Saving to: $_filePath");

      await _recorder!.startRecorder(toFile: _filePath);
      setState(() => _isRecording = true);
    } catch (e) {
      print("Error starting recorder: $e");
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Microphone Permission Needed"),
        content: Text(
            "This app needs microphone access to record audio. Please enable it in Settings."),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text("Open Settings"),
            onPressed: () {
              permission_pkg.openAppSettings();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _stopRecording() async {
    if (_recorder == null) {
      print("Error: Recorder is not initialized!");
      return;
    }

    try {
      await _recorder!
          .stopRecorder(); // stopRecorder() does not always return a file path
      setState(() => _isRecording = false);

      // Check manually if the file exists
      File recordedFile = File(_filePath);

      if (!await recordedFile.exists()) {
        print("Error: Audio file not found at $_filePath!");
        return;
      }

      print("Recording stopped. File saved at: $_filePath");
      _sendAudioToLambda(recordedFile);
    } catch (e) {
      print("Error stopping recorder: $e");
    }
  }

  Future<void> _sendAudioToLambda(File audioFile) async {
    try {
      if (!await audioFile.exists()) {
        print("Error: Audio file not found!");
        setState(() => _transcription = "Error: Audio file not found");
        return;
      }

      final bytes = await audioFile.readAsBytes();

      if (bytes.isEmpty) {
        print("Error: Audio file is empty!");
        setState(() => _transcription = "Error: Empty audio file");
        return;
      }

      String base64Audio = base64Encode(bytes);

      print("Sending audio to AWS...");
      print(
          "Base64 Encoded Audio: ${base64Audio.substring(0, 50)}..."); // Debugging

      // Add the missing `model` parameter
      final body = {
        'audio_file': base64Audio,
        'filename': 'audio.wav',
        'model': 'whisper-large-v3-turbo',
      };

      final response = await ApiService.postRequest(
        module: 'gorq_api',
        endpoint: 'speech-to-text',
        body: body, // Now passing a proper Map instead of String
      );

      if (response.containsKey("transcribed_text")) {
        print("response: ${response["transcribed_text"]}");
        setState(() {
          _transcription = response["transcribed_text"];
          _textEditingController.text = _transcription!;
          _performSearch();
        });
      } else {
        print("API Error: ${response}");
        setState(() => _transcription = "Error transcribing audio");
      }
    } catch (e) {
      print("Exception: $e");
      setState(() => _transcription = "Failed to process audio");
    }
  }

  Future<void> _performSearch() async {
    final predictions = await _fetchPredictions(_textEditingController.text);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return predictions.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "No results found. Please try a different search.",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  final prediction = predictions[index];
                  return ListTile(
                    title: Text(prediction.description ?? "Unknown Location"),
                    onTap: () {
                      Navigator.pop(context);
                      _handlePredictionSelection(prediction);
                    },
                  );
                },
              );
      },
    );
  }

  Future<void> _fetchAddressFromLatLng(LatLng position) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${widget.googleApiKey}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        if (mounted) {
          setState(() {
            _textEditingController.text =
                data['results'][0]['formatted_address'] ?? 'Unknown Address';
          });
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch address.")),
        );
      }
    }
  }

  Future<void> _handlePredictionSelection(gmaps.Prediction prediction) async {
    final placeDetails = await _places.getDetailsByPlaceId(prediction.placeId!);

    if (placeDetails.status == "OK" && placeDetails.result.geometry != null) {
      final location = placeDetails.result.geometry!.location;
      final lat = location.lat;
      final lng = location.lng;

      if (mounted) {
        setState(() {
          _textEditingController.text = prediction.description!;
          _selectedLocation = LatLng(lat, lng);
          _selectedMarker = Marker(
            markerId: const MarkerId("selected"),
            position: _selectedLocation!,
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _selectedLocation = newPosition;
              });
              _fetchAddressFromLatLng(newPosition);
            },
          );
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
          );
        });
      }
    }
  }

  Future<List<gmaps.Prediction>> _fetchPredictions(String input) async {
    final response = await _places.autocomplete(
      input,
      components: [gmaps.Component(gmaps.Component.country, "us")],
    );
    return response.predictions;
  }

  Future<void> _setCurrentLocation() async {
    final location = location_pkg.Location();

    final permissionStatus = await location.requestPermission();
    if (permissionStatus != location_pkg.PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
      }
      return;
    }

    try {
      final currentLocation = await location.getLocation();
      final currentLatLng =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);

      if (mounted) {
        setState(() {
          _selectedLocation = currentLatLng;
          _selectedMarker = Marker(
            markerId: const MarkerId("current"),
            position: _selectedLocation!,
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _selectedLocation = newPosition;
              });
              _fetchAddressFromLatLng(newPosition);
            },
          );
        });

        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
        );

        // Fetch and set address for current location
        await _fetchAddressFromLatLng(currentLatLng);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch current location.")),
        );
      }
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'description': _textEditingController.text,
        'lat': _selectedLocation!.latitude,
        'lng': _selectedLocation!.longitude,
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a location.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _textEditingController,
              onChanged: (value) {
                setState(() {}); // To update the clear button visibility
              },
              onSubmitted: (value) => _performSearch(),
              decoration: InputDecoration(
                labelText: "Search Location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.blue),
                  onPressed: _setCurrentLocation,
                  tooltip: "Use Current Location",
                ),
                suffixIcon: /* _textEditingController.text.isNotEmpty
                    ?*/
                    Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _textEditingController.clear();
                        setState(() {}); // Refresh UI to hide clear button
                      },
                      tooltip: "Clear",
                    ),
                    IconButton(
                      icon: Icon(_isRecording ? Icons.mic_off : Icons.mic,
                          color: Colors.blue),
                      onPressed:
                          _isRecording ? _stopRecording : _startRecording,
                      tooltip: "Voice Search",
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.blue),
                      onPressed: _performSearch,
                      tooltip: "Search",
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation ??
                    const LatLng(40.500618,
                        -74.447449), // Rutgers University, New Brunswick
                zoom: 15,
              ),
              markers: _selectedMarker != null ? {_selectedMarker!} : {},
              onMapCreated: (controller) {
                _mapController = controller;
                if (_selectedLocation != null) {
                  _mapController.animateCamera(
                    CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
                  );
                }
              },
              onTap: (position) {
                setState(() {
                  _selectedLocation = position;
                  _selectedMarker = Marker(
                    markerId: const MarkerId("selected"),
                    position: position,
                    draggable: true,
                    onDragEnd: (newPosition) {
                      setState(() {
                        _selectedLocation = newPosition;
                      });
                      _fetchAddressFromLatLng(newPosition);
                    },
                  );
                });
                _fetchAddressFromLatLng(position);
              },
            ),
          ),
          ElevatedButton(
            onPressed: _confirmLocation,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 70),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: const Text(
              "Confirm Location",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
