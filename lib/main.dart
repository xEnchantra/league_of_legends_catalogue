import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "League of Legends Catalogue",
      theme: ThemeData.dark(),
      home: const CharacterListScreen(),
    );
  }
}

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  List<dynamic> characters = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    getCharacters();
  }

  Future<void> getCharacters() async {
    try {
      final answer = await http.get(Uri.parse('https://ddragon.leagueoflegends.com/cdn/16.10.1/data/en_US/champion.json'));

      if (answer.statusCode == 200) {
        final data = jsonDecode(answer.body);
        setState(() {
          characters = data['data'].values.toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Server error";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "No internet connection";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Padding(padding: const EdgeInsets.only(top: 27),
            child: Text("League of Legends Champions",
            style: GoogleFonts.cormorant(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: 1)
            ),
        ),
          centerTitle: true,
      ),
      body: _buildScreenBody(),
    );
  }

  Widget _buildScreenBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
          childAspectRatio: 0.6,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),

        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          final imageAdress = 'https://ddragon.leagueoflegends.com/cdn/img/champion/loading/${character['id']}_0.jpg';
          // path to icons
          // 'https://ddragon.leagueoflegends.com/cdn/16.10.1/img/champion/${character['id']}.png'
          // path to loading screen icons
          // 'https://ddragon.leagueoflegends.com/cdn/img/champion/loading/${character['name']}_0.jpg'

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.network(imageAdress),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    character['name'],
                    style: GoogleFonts.cormorant(
                        fontSize: 32, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 1, overflow:
                  TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
    );
  }
}