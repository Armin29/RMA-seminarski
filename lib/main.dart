import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(SearchApp());
}

class SearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];

  Future<void> _search() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    // Make API call
    final url = Uri.parse('https://api.datamuse.com/words?ml=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Process the data and store it in _results
      setState(() {
        _results = List<Map<String, dynamic>>.from(data);
      });
    } else {
      // Handle errors
      print('Error fetching data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Welcome! Search for something below:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter search term',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _search,
                  child: Text('Search'),
                ),
              ],
            ),
            SizedBox(height: 20),
            _results.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  final word = result['word'];
                  final score = result['score'];
                  final tags = result['tags'] != null ? result['tags'].join(', ') : 'No tags';

                  return ListTile(
                    title: Text('$word (Score: $score)'),
                    subtitle: Text('Tags: $tags'),
                  );
                },
              ),
            )
                : Text('No results yet'),
          ],
        ),
      ),
    );
  }
}
