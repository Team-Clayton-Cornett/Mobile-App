import 'package:capstone_app/models/garage.dart';
import 'package:flutter/material.dart';

class GarageDetailPage extends StatefulWidget {
  final Garage garage;

  GarageDetailPage({
    @required this.garage
  });

  @override
  GarageDetailPageState createState() => GarageDetailPageState();
}

class GarageDetailPageState extends State<GarageDetailPage> {
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.garage.name),
      centerTitle: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(
              Icons.filter_list
          ),
          onPressed: () {
            // TODO: Navigate to filter page
          },
        )
      ],
      iconTheme: IconThemeData(
        color: Colors.white
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(),
    );
  }

}