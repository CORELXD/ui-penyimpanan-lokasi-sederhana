import 'package:crud_lokasi/db.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];
  bool _isloading = true;

  //Get Semua Data Dari Database
  void _refereshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refereshData();
  }

  Future<void> _addData() async {
    await SQLHelper.createData(
        _namaController.text, _descController.text, _alamatController.text);
    _refereshData();
  }

  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(
        id, _namaController.text, _descController.text, _alamatController.text);
    _refereshData();
  }

  void _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Data Telah Dihapus")));
    _refereshData();
  }

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _namaController.text = existingData['nama'];
      _descController.text = existingData['desc'];
      _alamatController.text = existingData['alamat'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Nama Tempat",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Alamat Tempat",
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Deskripsi Alamat Lengkap",
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addData();
                  }
                  if (id != null) {
                    await _updateData(id);
                  }

                  _namaController.text = "";
                  _descController.text = "";
                  _alamatController.text = "";

                  Navigator.of(context).pop();
                  print("Data Ditambahkan");
                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Tambah Data" : "Perbarui Data",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          "List LokasiApp",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // Untuk menempatkan teks judul di tengah
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0),
          ),
        ),
      ),
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: (context, index) => Card(
                elevation: 3,
                margin: EdgeInsets.all(30),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://www.pravatar.cc/100?=img${_allData[index]['nama']}'),
                    radius: 20,
                  ),
                  title: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          _allData[index]['nama'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      SizedBox(width: 10), // Spasi antara foto dan teks nama
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _allData[index]['alamat'],
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _allData[index]['desc'],
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 5), // Spasi antara deskripsi dan alamat
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showBottomSheet(_allData[index]['id']);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.indigo,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteData(_allData[index]['id']);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        backgroundColor: Colors.indigo,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        shape: CircleBorder(),
      ),
    );
  }
}
