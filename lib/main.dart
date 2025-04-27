import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:clipboard/clipboard.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(GeminiChatApp());
}

class GeminiChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrivateGPT',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.system,
      home: ChatScreen(),
    );
  }
}

// Light Theme
ThemeData lightTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[800],
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      elevation: 0,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme.copyWith(
            bodyMedium: TextStyle(color: Colors.black87),
          ),
    ),
    iconTheme: IconThemeData(color: Colors.blue[800]),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      textStyle: GoogleFonts.inter(color: Colors.black87),
    ),
  );
}

// Dark Theme
ThemeData darkTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      elevation: 0,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme.copyWith(
            bodyMedium: TextStyle(color: Colors.white70),
          ),
    ),
    iconTheme: IconThemeData(color: Colors.blue[400]),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.grey[800],
      textStyle: GoogleFonts.inter(color: Colors.white70),
    ),
  );
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  bool isDarkMode = false;

  // Replace with your Gemini API key
  final String apiKey = 'AIzaSyDYewJHzhyk0UvevhBqOES13Sc-p5WUG6k'; // TODO: Replace with your key
  final String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({'text': text, 'isUser': true});
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': text}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final aiResponse = json['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          messages.add({'text': aiResponse, 'isUser': false});
        });
      } else {
        final errorJson = jsonDecode(response.body);
        throw Exception(
            'Failed to get response: ${response.statusCode}, ${errorJson['error']['message']}');
      }
    } catch (e) {
      setState(() {
        messages.add({'text': 'Error: $e', 'isUser': false});
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    _controller.clear();
  }

  void copyText(String text, {bool isCode = false}) {
    String content = text;
    if (isCode) {
      final regex = RegExp(r'```[\s\S]*?```');
      final matches = regex.allMatches(text);
      content = matches
          .map((m) => m.group(0)!.replaceAll('```', '').trim())
          .join('\n');
      if (content.isEmpty) content = text;
    }
    FlutterClipboard.copy(content).then((_) {
      HapticFeedback.lightImpact(); // Haptic feedback on copy
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCode ? 'Code copied' : 'Message copied'),
          backgroundColor: isDarkMode ? Colors.blue[400] : Colors.blue[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  void copyCodeBlock(String codeBlock) {
    final content = codeBlock.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '').trim();
    FlutterClipboard.copy(content).then((_) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code copied'),
          backgroundColor: isDarkMode ? Colors.blue[400] : Colors.blue[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void showContextMenu(BuildContext context, Offset position, String text) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy, size: 16, color: isDarkMode ? Colors.blue[400] : Colors.blue[800]),
              SizedBox(width: 8),
              Text('Copy Message', style: GoogleFonts.inter()),
            ],
          ),
          onTap: () => copyText(text),
        ),
      ],
      color: isDarkMode ? Colors.grey[800] : Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? darkTheme() : lightTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('PrivateGPT'),
          actions: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(isDarkMode),
                ),
              ),
              onPressed: toggleTheme,
              tooltip: 'Toggle Theme',
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.black, Colors.grey[900]!]
                  : [Colors.blue[50]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isLoading && index == messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Shimmer.fromColors(
                            baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                            highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[200]!,
                            child: Container(
                              width: 120,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final message = messages[index];
                    final isUser = message['isUser'];
                    return GestureDetector(
                      onLongPress: () {
                        HapticFeedback.lightImpact();
                        copyText(message['text']);
                      },
                      onSecondaryTapDown: (details) {
                        showContextMenu(context, details.globalPosition, message['text']);
                      },
                      child: OpenContainer(
                        transitionType: ContainerTransitionType.fade,
                        transitionDuration: Duration(milliseconds: 400),
                        openBuilder: (context, _) => Scaffold(
                          body: SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: Text(message['text']),
                          ),
                        ),
                        closedBuilder: (context, openContainer) => InkWell(
                          onTap: openContainer,
                          child: Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              padding: EdgeInsets.all(16),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isUser
                                      ? isDarkMode
                                          ? [Colors.blue[700]!, Colors.blue[500]!]
                                          : [Colors.blue[600]!, Colors.blue[400]!]
                                      : isDarkMode
                                          ? [Colors.grey[800]!, Colors.grey[700]!]
                                          : [Colors.grey[200]!, Colors.grey[100]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(isUser ? 12 : 0),
                                  topRight: Radius.circular(isUser ? 0 : 12),
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MarkdownBody(
                                    data: message['text'],
                                    selectable: true, // Enable text selection
                                    styleSheet: MarkdownStyleSheet(
                                      p: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: isDarkMode ? Colors.white70 : Colors.black87,
                                      ),
                                      code: GoogleFonts.sourceCodePro(
                                        fontSize: 14,
                                        color: isDarkMode ? Colors.yellow[200] : Colors.black87,
                                        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                                      ),
                                      codeblockPadding: EdgeInsets.all(12),
                                      codeblockDecoration: BoxDecoration(
                                        color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    builders: {
                                      'code': CodeBlockBuilder(
                                        onCopy: copyCodeBlock,
                                        isDarkMode: isDarkMode,
                                      ),
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.copy, size: 20),
                                        color: isDarkMode ? Colors.blue[400] : Colors.blue[800],
                                        onPressed: () => copyText(message['text']),
                                        tooltip: 'Copy Message',
                                        splashRadius: 20,
                                      ),
                                      if (message['text'].contains('```'))
                                        IconButton(
                                          icon: Icon(Icons.code, size: 20),
                                          color: isDarkMode ? Colors.blue[400] : Colors.blue[800],
                                          onPressed: () => copyText(message['text'], isCode: true),
                                          tooltip: 'Copy Code',
                                          splashRadius: 20,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.inter(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.inter(
                            color: isDarkMode ? Colors.white54 : Colors.black54,
                          ),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.blue[400]! : Colors.blue[800]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.blue[400]! : Colors.blue[800]!,
                              width: 2,
                            ),
                          ),
                        ),
                        onSubmitted: (value) => sendMessage(value),
                        enabled: !isLoading,
                      ),
                    ),
                    SizedBox(width: 12),
                    FloatingActionButton(
                      onPressed: isLoading ? null : () => sendMessage(_controller.text),
                      backgroundColor: isDarkMode ? Colors.blue[400] : Colors.blue[800],
                      elevation: 0,
                      child: Icon(Icons.send, size: 24),
                      tooltip: 'Send',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Markdown Code Block Builder
class CodeBlockBuilder extends MarkdownElementBuilder {
  final Function(String) onCopy;
  final bool isDarkMode;

  CodeBlockBuilder({required this.onCopy, required this.isDarkMode});

  @override
  Widget? visitElementAfter(element, TextStyle? style) {
    if (element.tag != 'pre') return null;

    // Extract code content
    String codeContent = element.textContent;
    // Remove language identifier if present (e.g., ```python)
    codeContent = codeContent.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '').trim();

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(right: 40), // Space for copy button
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            codeContent,
            style: GoogleFonts.sourceCodePro(
              fontSize: 14,
              color: isDarkMode ? Colors.yellow[200] : Colors.black87,
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: IconButton(
            icon: Icon(Icons.copy, size: 16),
            color: isDarkMode ? Colors.blue[400] : Colors.blue[800],
            onPressed: () => onCopy(codeContent),
            tooltip: 'Copy Code',
            splashRadius: 16,
          ),
        ),
      ],
    );
  }
}