import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(name: 'Linkin Park', id: '1', votes: 7),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', (payload) {
      bands = (payload as List).map((banda) => Band.fromMap(banda)).toList();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        elevation: 1,
        title: const Text('Band Names', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.online)
                ? Icon(Icons.check_circle, color: Colors.green[600])
                : const Icon(Icons.cancel_rounded, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTile(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand, //Si no necesito mandar args, solo mando la refer
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context);

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
        // bands.removeWhere((element) => element.id == band.id);
        // setState(() {});
        socketService.socket.emit('delete-band', {'id': band.id});
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[200],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        onTap: () {
          socketService.socket.emit('vote-band', {'id': band.id});
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
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name, 'votes': 0});
      // bands.add(Band(name: name, id: DateTime.now().toString()));
      // setState(() {});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {};
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes!.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue[100]!,
      Colors.blue[200]!,
      Colors.pink[100]!,
      Colors.pink[200]!,
      Colors.yellow[100]!,
      Colors.yellow[200]!,
      Colors.green[100]!,
      Colors.green[200]!,
    ];

    return (dataMap.isEmpty)
        ? const SizedBox(child: Center(child: CircularProgressIndicator()))
        : SizedBox(
            width: double.infinity,
            height: 250,
            child: PieChart(
              dataMap: dataMap,
              colorList: colorList,
              chartValuesOptions: const ChartValuesOptions(
                showChartValuesInPercentage: true,
                showChartValueBackground: false,
              ),
            ),
          );
  }
}
