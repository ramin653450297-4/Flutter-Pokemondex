import 'package:flutter/material.dart';
import 'package:pokemondex/pokemondetail/views/pokemondetail_view.dart';
import 'package:pokemondex/pokemonlist/models/pokemonlist_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<PokemonListItem> _pokemonList = [];
  String? _nextUrl = 'https://pokeapi.co/api/v2/pokemon';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (_isLoading || _nextUrl == null) return;
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(_nextUrl!));
    if (response.statusCode == 200) {
      final data = PokemonListResponse.fromJson(jsonDecode(response.body));
      setState(() {
        _pokemonList.addAll(data.results);
        _nextUrl = data.next;
      });
    } else {
      throw Exception('Failed to load Pokemon');
    }

    setState(() {
      _isLoading = false;
    });
  }

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Expanded(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, 
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1, 
          ),
          padding: const EdgeInsets.all(8),
          itemCount: _pokemonList.length,
          itemBuilder: (context, index) {
            final PokemonListItem pokemon = _pokemonList[index];
            final int pokemonId = index + 1;
            final String imageUrl =
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png'; // Official Artwork ให้ภาพชัด

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemondetailView(pokemonId: pokemonId),
                ),
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover, 
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 50);
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        pokemon.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      if (_nextUrl != null) 
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton(
            onPressed: _isLoading ? null : loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), 
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Load More"),
          ),
        ),
    ],
  );
}


}
