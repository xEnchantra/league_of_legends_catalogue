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
  List<dynamic> allCharacters = [];
  List<dynamic> displayedCharacters = [];
  bool isLoading = true;
  String errorMessage = '';
  String languageCode = 'en_US';

  String selectedLetter = 'All';
  final List<String> alphabet = ['All', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

  @override
  void initState() {
    super.initState();
    getCharacters();
  }

  void filterCharacters(String letter) {
    setState(() {
      selectedLetter = letter;
      if (letter == 'All') {
        displayedCharacters = allCharacters;
      } else {
        displayedCharacters = allCharacters.where((char) => char['name'].toString().startsWith(letter)).toList();
      }
    });
  }

  Future<void> getCharacters() async {
    final memory = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });

    try {
      final answer = await http.get(Uri.parse('https://ddragon.leagueoflegends.com/cdn/16.10.1/data/$languageCode/champion.json'));

      if (answer.statusCode == 200) {
        await memory.setString("saved_list", answer.body);

        final data = jsonDecode(answer.body);
        setState(() {
          allCharacters = data['data'].values.toList();
          filterCharacters(selectedLetter);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = languageCode == 'en_US' ? "Server error" : "Błąd serwera";
          isLoading = false;
        });
      }
    } catch (e) {
        final savedData = memory.getString('saved_list');

        setState(() {
          if (savedData != null) {
            final data = jsonDecode(savedData);
            allCharacters = data['data'].values.toList();
            filterCharacters(selectedLetter);
          } else {
            errorMessage = languageCode == 'en_US' ? "No internet connection and no saved data" : "Brak połączenia z internetem i zapisanych danych";
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
        title: Padding(padding: const EdgeInsets.only(top: 16),
            child: Text("League of Legends Champions",
            style: GoogleFonts.cormorant(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: 1)
            ),
        ),
        centerTitle: true,

        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  languageCode = languageCode == 'en_US' ? 'pl_PL' : 'en_US';
                });
                getCharacters();
              },
          child: Text(
            languageCode == 'en_US' ? 'EN' : 'PL',
            style: GoogleFonts.cormorant(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red[900]),
          ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildScreenBody(),
    );
  }

  Widget _buildScreenBody() {
    if (isLoading && allCharacters.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: alphabet.map((letter) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.76, vertical: 8),
                    child: ActionChip(
                      label: Text(letter, style: GoogleFonts.cormorant(fontSize: 16, fontWeight: FontWeight.bold)),
                      backgroundColor: selectedLetter == letter ? Colors.red[900] : Colors.grey[900],
                      onPressed: () => filterCharacters(letter),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

    Expanded(
    child: RefreshIndicator(
      onRefresh: getCharacters,
      child: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
          childAspectRatio: 0.6,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: displayedCharacters.length,
        itemBuilder: (context, index) {
          final character = displayedCharacters[index];
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
                    LanguageCode: languageCode,
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
      ),
    ),
    ),
    ],
    );
  }
}


class DetailsScreen extends StatefulWidget {
  final String CharacterID;
  final String CharacterName;
  final String LanguageCode;

  const DetailsScreen({super.key, required this.CharacterID, required this.CharacterName, required this.LanguageCode});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String lore = '';
  bool loading = true;
  String error = '';
  List<dynamic> spells = [];
  String currentAbilityDescription = '';

  @override
  void initState() {
    super.initState();

    currentAbilityDescription = widget.LanguageCode == 'en_US'
        ? 'Choose ability to see description'
        : 'Wybierz umiejetność, żeby zobaczyć opis';

    getDetailedData();
  }

  Future<void> getDetailedData() async {
    try {
      final answer2 = await http.get(Uri.parse('https://ddragon.leagueoflegends.com/cdn/16.10.1/data/${widget.LanguageCode}/champion/${widget.CharacterID}.json'));

      if (answer2.statusCode == 200) {
        final data = jsonDecode(answer2.body);
        setState(() {
          spells = data['data'][widget.CharacterID]['spells'];
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.CharacterName,
          style: GoogleFonts.cormorant(
              fontSize: 32, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis)
      ),
      body: _buildDetailsBody(),
    );
  }

  Widget _buildDetailsBody() {
    if (loading) return const Center(child: CircularProgressIndicator());

    final SplashArtAdress = 'https://ddragon.leagueoflegends.com/cdn/img/champion/splash/${widget
        .CharacterID}_0.jpg';

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Image.network(SplashArtAdress, fit: BoxFit.cover),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: error.isNotEmpty
                  ? Center(
                    child: Text(
                      widget.LanguageCode == 'en_US'
                       ? "No internet connection, can't get abilities"
                       : "Brak internetu, nie można pobrać umiejętności",
                      style: GoogleFonts.cormorant(fontSize: 24, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : Column(
                    children: [
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: spells.asMap().entries.map((entry) {
                          final index = entry.key;
                          final spell = entry.value;
                          final spellImage = 'https://ddragon.leagueoflegends.com/cdn/16.10.1/img/spell/${spell['image']['full']}';

                          final keys = ['Q', 'W', 'E', 'R'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                currentAbilityDescription = spell['description'].replaceAll(RegExp(r'<[^>]*>'), '');
                              });
                            },
                            child: Column(
                              children: [
                                Image.network(spellImage, width: 70, height: 70),
                                const SizedBox(height: 4),
                                Text(
                                  index < 4 ? keys[index] : '',
                                  style: GoogleFonts.cormorant(fontSize: 18, fontWeight: FontWeight.w700),
                                )
                              ],
                            )
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentAbilityDescription,
                        style: GoogleFonts.cormorant(fontSize: 20, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              ],
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  error.isNotEmpty
                      ? (widget.LanguageCode == 'en_US'
                        ? "No internet connection, can't get lore"
                        : "Brak internetu, nie można pobrać historii")
                      : lore,
                  style: GoogleFonts.cormorant(fontSize: 20,
                    fontWeight: FontWeight.w500),
                    textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        );
      }
    }