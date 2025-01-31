import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemondetailView extends StatefulWidget {
  final int pokemonId;

  const PokemondetailView({Key? key, required this.pokemonId}) : super(key: key);

  @override
  State<PokemondetailView> createState() => _PokemondetailViewState();
}

class _PokemondetailViewState extends State<PokemondetailView> {
  Map<String, dynamic>? _pokemonData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPokemonDetails();
  }

  Future<void> loadPokemonDetails() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.pokemonId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _pokemonData = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load Pokémon details');
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'fire': return Colors.redAccent;
      case 'water': return Colors.blueAccent;
      case 'grass': return Colors.green;
      case 'electric': return Colors.yellow;
      case 'ice': return Colors.lightBlueAccent;
      case 'fighting': return Colors.brown;
      case 'poison': return Colors.purple;
      case 'ground': return Colors.orange;
      case 'flying': return Colors.indigoAccent;
      case 'psychic': return Colors.pinkAccent;
      case 'bug': return Colors.lightGreen;
      case 'rock': return Colors.grey;
      case 'ghost': return Colors.deepPurple;
      case 'dragon': return Colors.deepOrangeAccent;
      case 'dark': return Colors.black54;
      case 'steel': return Colors.blueGrey;
      case 'fairy': return Colors.pink;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String name = _pokemonData!['name'];
    final String imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${widget.pokemonId}.png';
    final List<dynamic> types = _pokemonData!['types'];
    final List<dynamic> stats = _pokemonData!['stats'];
    final String primaryType = types[0]['type']['name'];

    return Scaffold(
      appBar: AppBar(
        title: Text(name.toUpperCase()),
        backgroundColor: _getTypeColor(primaryType),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_getTypeColor(primaryType).withOpacity(0.6), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 80);
              },
            ),
            const SizedBox(height: 10),
            Text(
              name.toUpperCase(),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.center,
              children: types.map((type) {
                return Chip(
                  label: Text(
                    type['type']['name'].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: _getTypeColor(type['type']['name']),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Column(
              children: stats.map((stat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80, 
                        child: Text(
                          stat['stat']['name'].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: stat['base_stat'] / 150,
                          backgroundColor: Colors.grey[300],
                          color: _getTypeColor(primaryType),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 40, 
                        child: Text(
                          stat['base_stat'].toString(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
