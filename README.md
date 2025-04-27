
PrivateGPT - Gemini Chat App 🚀
=============================

PrivateGPT is a modern chatbot app built using Flutter that integrates with Google's Gemini API to generate intelligent responses. The app features a sleek and responsive UI, offers a light/dark theme toggle, and supports various advanced features like copying messages and code, along with smooth transitions and animations.

---

Features ✨
----------

- **Responsive UI**: The app has a modern and minimalistic user interface that adapts to different screen sizes.
- **Light/Dark Mode**: Switch between light and dark themes with a toggle button. 🌞🌙
- **Message Copying**: Long press on a message to copy it or use the context menu for additional actions. 📋
- **Code Block Copying**: Special support for copying code snippets with a formatted view. 💻
- **Shimmer Animation**: Loading state with shimmer effect for smooth user experience. ✨
- **Markdown Rendering**: Displays rich formatted messages using Markdown rendering. 📑

---

Requirements 📋
--------------

To build and run the app, you need:

- Flutter SDK (2.0 or higher)
- Dart SDK (compatible with Flutter version)
- An Android or iOS device (or emulator) 📱

---

Setup ⚙️
--------

1. Clone the repository:

```bash
git clone https://github.com/your-username/privategpt.git
```

2. Install dependencies:

Navigate to the project directory and run the following command to install the required dependencies:

```bash
flutter pub get
```

3. Set up the API Key 🔑:

In the `lib/main.dart` file, replace the placeholder API key with your own Gemini API key. 

```dart
final String apiKey = 'YOUR_API_KEY'; // Replace with your Gemini API key
```

You can obtain the Gemini API key from the Google Cloud Console.

4. Run the app 🚀:

To run the app on your Android or iOS device, use the following command:

```bash
flutter run
```

Alternatively, you can run it on an emulator. 🎮

---

Screenshots 📸
--------------

<img src="https://github.com/user-attachments/assets/037479c5-93aa-4691-8e12-917895b2c13a" width="300" /> 
<img src="https://github.com/user-attachments/assets/800ae31a-fa25-4d24-8aee-c50a7a472339" width="300" />

---

Acknowledgements 💡
-----------------

- [Flutter](https://flutter.dev/) - The UI framework used to build the app. 🐦
- [Google Fonts](https://pub.dev/packages/google_fonts) - For beautiful font integration. 🔤
- [Shimmer](https://pub.dev/packages/shimmer) - For the shimmer effect during loading. ✨
- [Clipboard](https://pub.dev/packages/clipboard) - To copy messages and code to clipboard. 📋
- [Flutter Markdown](https://pub.dev/packages/flutter_markdown) - For rendering markdown content. 📑
- [Google Gemini API](https://cloud.google.com/generative-language) - For generating AI-powered responses. 🤖

---
