import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController
      _controller; // The boss that tells the camera what to do
  bool _isCameraReady = false; // Camera still loading?  Yes/No
  String _currentStatus =
      "Initializing..."; // What's happening right now in words

  // Data logging variables
  List<int> brightnessValues = []; // empty list ready to receive bright values
  int _frameCount = 0; // no frames prosessed yet
  bool _isLogging = false; // Not recording nor saving data - camera is idle
  StreamSubscription?
      _imageStreamSubscription; //Listens for new camera images constantly. ? means: not listening right now

  final double _detectionZoneSize =
      100.0; //The size of our LED square area (never changes. That is why is final)

  double _calculateAverageBrightness(
      //A math calculator that figures out how bright the red square area is
      CameraImage image,
      int x,
      int y,
      int width,
      int height) {
    // "The current camera photo, Top-left corner of the red square (coordinates), How wide and tall the red square is"
    int totalBrightness = 0; //Counter bucket for adding brightness
    int pixelCount = 0; //Counter for how many pixels are checked

    if (image.format.group == ImageFormatGroup.yuv420) {
      // Make sure the camera uses the YUV format (most cameras do). Industry standart
      final Uint8List yPlane =
          image.planes[0].bytes; // "Grab the brightness layer"
      final int bytesPerRow =
          image.planes[0].bytesPerRow; // "How many bytes per row"

      for (int row = y; row < y + height; row++) {
        // "Go down each row"
        for (int col = x; col < x + width; col++) {
          // "Go across each column"
          int pixelIndex =
              row * bytesPerRow + col; // "Find this pixel's address"
          totalBrightness +=
              yPlane[pixelIndex]; // "Add its brightness to total"
          pixelCount++; // "Count that we checked one more pixel"
        }
      }
    }
    return pixelCount > 0
        ? totalBrightness / pixelCount
        : 0.0; // If we checked at least one pixel, return the average. Otherwise return 0.
  }

  void _processCameraImage(CameraImage image) {
    // processes each new camera frame
    if (!_isLogging) {
      return; // "Are we currently logging? If not, ignore this picture"
    }

    _frameCount++; //Count that we've processed one more frame

    int x = (image.width / 2 - _detectionZoneSize / 2).round();
    int y = (image.height / 2 - _detectionZoneSize / 2).round();
    int size = _detectionZoneSize.round();

    x = x.clamp(0, image.width - size);
    y = y.clamp(0, image.height - size);

    double currentBrightness = _calculateAverageBrightness(
        image, x, y, size, size); // Calculate how bright the red square area is

    setState(() {
      // app's update UI
      // Save this brightness number in our list "brightnessValues[]"
      brightnessValues.add(currentBrightness.round());
      // Update screen to show: 'Logging... Frames: 45 | Brightness: 148
      _currentStatus =
          "Logging... Frames: $_frameCount | Brightness: ${currentBrightness.round()}";
    });
  }

  @override
  void initState() {
    super.initState(); // Hey Flutter, do your normal startup stuff first
    _initializeCamera(); // "Then get camera ready
  }

  Future<void> _initializeCamera() async {
    // Camera setup function that takes time and we have to wait for it to be ready
    final cameras =
        await availableCameras(); // Find what cameras are available on this device
    final firstCamera = cameras.first; // Pick the back camera

    // Create a controller to manage the camera
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    // Wait for the camera to fully initialize
    await _controller.initialize();
    // Start listening for new camera images
    await _controller.startImageStream(_processCameraImage);

    setState(() {
      // update UI
      _isCameraReady = true; // camere is ready to record/log? YES
      _currentStatus = "Press START to begin logging"; // current status
    });
  }

  void _startLogging() {
    // Start recording (pressing Start logging button)
    setState(() {
      //update the app
      brightnessValues.clear(); // "Empty the list - fresh start!"
      _frameCount = 0; // "Reset the frame counter to zero"
      _isLogging = true; // "Flip the switch to RECORDING mode"
    });
  }

  void _stopLogging() {
    // Stop recording (pressing Start stop button)
    setState(() {
      _isLogging = false; // stop RECORDING mode
      _currentStatus =
          "Stopped - $_frameCount frames logged"; //display: Stopped - x frames logged
    });
  }

  String _getBrightnessCSV() {
    // Simple CSV: one brightness value per line
    return brightnessValues.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      // if the camera is not ready display a black screen
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(_currentStatus, style: TextStyle(color: Colors.white)),
          ],
        )),
      );
    }
    //if the camera is ready display normal UI screen
    return Scaffold(
      appBar: AppBar(title: const Text('Brightness Logger (Decoder)')),
      body: Column(
        children: [
          // Camera preview
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Center(
                    child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: CameraPreview(_controller),
                )),
                // Target overlay
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 -
                      _detectionZoneSize / 2,
                  top: MediaQuery.of(context).size.height / 3 -
                      _detectionZoneSize / 2,
                  child: Container(
                    width: _detectionZoneSize,
                    height: _detectionZoneSize,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _isLogging ? Colors.green : Colors.red,
                          width: 3.0),
                    ),
                    child: Icon(
                      _isLogging
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: _isLogging ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min, // Row tight to children
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Button 1
              ElevatedButton(
                onPressed: _isLogging
                    ? null
                    : _startLogging, // start recording if pressed
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('START LOGGING'),
              ),

              const SizedBox(width: 16),

              // Button 2
              ElevatedButton(
                onPressed: _isLogging
                    ? _stopLogging
                    : null, // stop recording if pressed
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('STOP'),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Button 3
              ElevatedButton(
                onPressed: brightnessValues.isNotEmpty
                    ? _exportData
                    : null, // export brighness numbers
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('EXPORT DATA'),
              ),
            ],
          ),

          // Controls and data display
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text(_currentStatus, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: brightnessValues.isEmpty
                          ? Center(child: Text('No data collected yet\n\n'))
                          : SingleChildScrollView(
                              child: SelectableText(
                                // Display a preview of the recorded data without overwhelming the screen
                                brightnessValues.take(100).join(', ') +
                                    (brightnessValues.length > 100
                                        ? '\n... (${brightnessValues.length - 100} more values)'
                                        : ''),
                                style: TextStyle(
                                    fontFamily: 'Monospace', fontSize: 12),
                              ),
                            ),
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

  void _exportData() {
    //Take all the brightness measurements collected and saves them to a file that you can share or analyze later
    String csvData =
        _getBrightnessCSV(); // Convert our brightness numbers into Excel-friendly CSV format
    showDialog(
      // show it in a separate dialog box
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Brightness Data'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Copy these numbers to Python:'),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 200,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    csvData,
                    style: TextStyle(fontFamily: 'Monospace', fontSize: 10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text('${brightnessValues.length} brightness values'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  //When closing the app.
  void dispose() {
    _imageStreamSubscription?.cancel(); // "Stop listening to the camera"
    _controller.dispose(); // "Turn off the camera"
    super.dispose(); // "Let Flutter do its own cleanup"
  }
}
