# UART-LED-Visual-Demonstrator---Part-2-Mobile-Decoder

#### main.dart and camera.screen.dart goes inside your lib folder inside your flutter project.</br></br>

## Project Overview</br>

### The Complete System:
Part 1: Arduino Transmitter
Hardware: Arduino + LED

Role: Sends messages by blinking LED in UART protocol

What it does: Converts text like "Hello World" into light pulses</br></br>
link to part 1: https://github.com/amartig16/uart-led-visual-demostrator-part1/blob/main/README.md</br></br>

### Part 2: Flutter Decoder (This App)

Dependencies (goes inside your pubspec.yaml in Flutter): </br>
  camera: ^0.11.0+2 </br>
  camera_platform_interface: ^2.6.2 </br>

Hardware: Smartphone with camera

Role: Receives and decodes messages from blinking LED

What it does: Watches LED through camera, converts light pulses back to text values.</br></br>

### How the Two Parts Work Together:

<pre>Arduino (Part 1)                Phone (Part 2)</br>
       ↓                                ↓</br>
"Hello World" → UART → LED blinks → Camera sees → Decodes → "Hello ..."</pre></br>

### Standalone Capability:
* This app can also work independently with:
* Any UART-compatible light source
* Pre-recorded LED blinking videos
* Other light-based communication systems
* Educational demonstrations of serial protocols</br></br>

## Learning Path:

### Part 1 Focus:
* UART protocol theory
* Arduino programming
* Bit manipulation
* Hardware setup</br></br>

### Part 2 Focus:
* Signal processing
* Computer vision basics
* Real-time data analysis
* Mobile app development</br></br>

## Technical Integration:

### Shared Specifications:
* Baud rate: 5 bit per second (configurable)
* Data format: 8N1 (8 data bits, no parity, 1 stop bit)
* Protocol: Standard UART with visual adaptation
* Encoding: ASCII text transmission</br></br>

### Cross-Platform Compatibility:
* Works with any Arduino (Uno, Nano, Mega, etc.)
* Compatible with Android and iOS
* Adjustable for different LED colors and intensities</br></br>

### Educational Value:
* Complete Learning Experience:
* Understand UART at bit level (Part 1)
* Implement transmitter in hardware (Part 1)
* Build receiver in software (Part 2)
* See end-to-end communication in action (Both parts)</br></br>

### Classroom Ready:
* Teacher demonstrates with Part 1 transmitter
* Students decode with Part 2 app on their phones
* Hands-on learning about serial communication</br></br>

### Project Flexibility:
As a Complete System:
* Full UART demonstration from text to light to text
* Real wireless communication without radio frequencies
* Tangible understanding of data transmission</br></br>

### Perfect For:
* University courses in embedded systems or networking
* Maker workshops on communication protocols
* Science projects demonstrating data transmission
* Professional training on serial communication fundamentals</br></br>

### The Complete Package:
"From Arduino code to mobile app - see UART communication come to life through visible light! A hands-on journey through the entire stack of embedded communication systems."</br></br>

Where hardware meets software through the magic of light!

***Note: 
* You can use python to translate app logged values into words.
* Message is received like this: "H" = 0 (start bit) + 00010010 ("H" in binary in reverse) + 1 (Stop bit) = 0000100101  (this is how it is going to look like in the Decoder app. In reverse)  
* Arduino starts with the last bit and "pushes it to the rightmost place"
