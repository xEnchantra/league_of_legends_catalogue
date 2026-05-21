import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final memory = await SharedPreferences.getInstance();

    try {
      final answer = await http.get(Uri.parse('https://ddragon.leagueoflegends.com/cdn/16.10.1/data/en_US/champion.json'));

      if (answer.statusCode == 200) {
        await memory.setString("saved_list", answer.body);

        final data = jsonDecode(answer.body);
        setState(() {
          characters = data['data'].values.toList();
          isLoading = false;
        });
      } else {
          errorMessage = "Server error";
      }
    } catch (e) {
        final savedData = memory.getString('saved_list');

        setState(() {
          if (savedData != null) {
            final data = jsonDecode(savedData);
            characters = data['data'].values.toList();
          } else {
            errorMessage = "No internet connection and no saved data";
          }
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

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailsScreen(
                      CharacterID: character['id'],
                      CharacterName: character['name'],
                    ),
                ),
              );
            },
              child: Card(
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
              ),
          );
        },
    );
  }
}


class DetailsScreen extends StatefulWidget {
  final String CharacterID;
  final String CharacterName;

  const DetailsScreen({super.key, required this.CharacterID, required this.CharacterName});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String lore = '';
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    getDetailedData();
  }

  Future<void> getDetailedData() async {
    try {
      final answer2 = await http.get(Uri.parse('https://ddragon.leagueoflegends.com/cdn/16.10.1/data/en_US/champion/${widget.CharacterID}.json'));

      if (answer2.statusCode == 200) {
        final data = jsonDecode(answer2.body);
        setState(() {
          lore = data['data'][widget.CharacterID]['lore'];
          loading = false;
        });
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      setState(() {
        error = "No internet connection, can't get character's lore";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final SplashArtAdress = 'https://ddragon.leagueoflegends.com/cdn/img/champion/splash/${widget.CharacterID}_0.jpg';

    return Scaffold(
      appBar: AppBar(title: Text(widget.CharacterName,
          style: GoogleFonts.cormorant(
          fontSize: 32, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis)),
      body: loading ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : SingleChildScrollView(
        child: Column(
          children: [
            Image.network(SplashArtAdress),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Text(lore, style: GoogleFonts.cormorant(
                  fontSize: 24, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}