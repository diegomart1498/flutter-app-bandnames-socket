import 'package:band_names/models/band.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(name: 'Linkin Park', id: '1', votes: 7),
    Band(name: '30 Seconds to Mars', id: '2', votes: 6),
    Band(name: 'Queen', id: '3', votes: 5),
    Band(name: 'Muse', id: '4', votes: 4),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('Band Names'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, index) => _bandTile(bands[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand, //Si no necesito mandar args, solo mando la refer
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id!),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red[300],
        child: const Text(
          'Delete band',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      onDismissed: (direction) {
        bands.removeWhere((element) => element.id == band.id);
        setState(() {}); //TODO: Borrar en el servidor
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[200],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('New band name:')),
          content: TextField(
            textCapitalization: TextCapitalization.sentences,
            controller: textController,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () => addBandToList(textController.text),
                  child: const Text('Add'),
                ),
                const SizedBox(width: 20),
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.red,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      bands.add(Band(name: name, id: DateTime.now().toString()));
      setState(() {});
    }
    Navigator.pop(context);
  }
}
