import 'package:capstone_app/models/garage.dart';
import 'package:flutter/material.dart';

import 'garageCard.dart';

class GarageListSearchDelegate extends SearchDelegate {
  final List<Garage> garages;
  
  List<Garage> _searchResults = List();

  GarageListSearchDelegate({this.garages});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(
          Icons.close
        ),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildCurrentSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query == '') {
      _searchResults.clear();
    } else {
      _searchResults = garages.where((garage) => garage.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    
    return _buildCurrentSearchResults();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryIconTheme: IconThemeData(
        color: Colors.white
      ),
      textTheme: theme.textTheme.copyWith(
        title: theme.primaryTextTheme.title.copyWith(
          color: Colors.white
        )
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Color.fromARGB(196, 255, 255, 255)
        )
      )
    );
  }

  Widget _buildCurrentSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (BuildContext context, int index) {
        return GarageCard(
          garage: _searchResults[index],
        );
      },
    );
  }
}