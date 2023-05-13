import 'package:flutter/material.dart';
import 'dart:html';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

class UMKMModel {
  String id;
  String nama;
  String jenis;

  UMKMModel({required this.id, required this.nama, required this.jenis});
}

class UMKMCubit extends Cubit<UMKMModel> {
  String url = "http://178.128.17.76:8000/daftar_umkm";

  UMKMCubit() : super(UMKMModel(id: "", nama: "", jenis: ""));
  List<UMKMModel> listUMKM = <UMKMModel>[];

  void fromJson(Map<String, dynamic> json) {
    listUMKM.clear();
    for (var val in json['data']) {
      String id = val['id'];
      String nama = val['nama'];
      String jenis = val['jenis'];
      listUMKM.add(UMKMModel(id: id, nama: nama, jenis: jenis));
      emit(UMKMModel(id: id, nama: nama, jenis: jenis));
    }
  }

  // Ambi data
  void fetchData() async {
    final response =
        await http.get(Uri.parse(url)); // menampung respon dari server

    if (response.statusCode == 200) {
      // jika server mengembalikan 200 OK (berhasil),
      // parse json
      fromJson(jsonDecode(response.body));
    } else {
      // jika gagal (bukan  200 OK),
      // lempar exception
      throw Exception('Gagal load');
    }
  }
}

class DetailModel {
  String id;
  String nama;
  String jenis;
  String omzet;
  String lama;
  String member;
  String pinjam;

  DetailModel(
      {required this.id,
      required this.nama,
      required this.jenis,
      required this.omzet,
      required this.lama,
      required this.member,
      required this.pinjam});

  String getNama() {
    return this.nama;
  }
}

class DetailCubit extends Cubit<DetailModel> {
  DetailCubit()
      : super(DetailModel(
            id: "",
            nama: "",
            jenis: "",
            omzet: "",
            lama: "",
            member: "",
            pinjam: ""));
  List<DetailModel> detail = <DetailModel>[];
  void fromJson(Map<String, dynamic> json) {
    detail.clear();
    String id = json['id'];
    String nama = json['nama'];
    String jenis = json['jenis'];
    String omzet = json['omzet_bulan'];
    String lama = json['lama_usaha'];
    String member = json['member_sejak'];
    String pinjam = json['jumlah_pinjaman_sukses'];
    detail.add(DetailModel(
        id: id,
        nama: nama,
        jenis: jenis,
        omzet: omzet,
        lama: lama,
        member: member,
        pinjam: pinjam));
    emit(DetailModel(
        id: id,
        nama: nama,
        jenis: jenis,
        omzet: omzet,
        lama: lama,
        member: member,
        pinjam: pinjam));
  }

  // Ambi data
  Future<void> fetchData({required String id}) async {
    final response = await http.get(Uri.parse(
        "http://178.128.17.76:8000/detil_umkm/$id")); // menampung respon dari server

    if (response.statusCode == 200) {
      // jika server mengembalikan 200 OK (berhasil),
      // parse json
      fromJson(jsonDecode(response.body));
    } else {
      // jika gagal (bukan  200 OK),
      // lempar exception
      throw Exception('Gagal load');
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final umkmCubit = Provider.of<UMKMCubit>(context);
    return MaterialApp(
        home: MultiBlocProvider(
      providers: [
        BlocProvider<UMKMCubit>(
          create: (BuildContext context) => UMKMCubit(),
        ),
        BlocProvider<DetailCubit>(
          create: (BuildContext context) => DetailCubit(),
        ),
      ],
      child: MyHomePage(),
    ));
  }
}

class DetailApp extends StatelessWidget {
  String id = "";
  DetailApp({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Detail UMKM",
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Detail UMKM",
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<DetailCubit, DetailModel>(builder: (context, dtl) {
          context.read<DetailCubit>().fetchData(id: id);
          return Column(
            children: [
              Text("Nama UMKM: ${dtl.nama}"),
              Text("Jenis UMKM: ${dtl.jenis}"),
              Text("Omzet UMKM: ${dtl.omzet}"),
              Text("Lama UMKM: ${dtl.lama}"),
              Text("Member UMKM: ${dtl.member}"),
              Text("Pinjam UMKM: ${dtl.pinjam}"),
            ],
          );
        }),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  // MyHomePage({Key? key}) : super(key: key);
  final List<String> items = List.generate(20, (index) => "Item $index");

  @override
  Widget build(BuildContext context) {
    final umkmCubit = Provider.of<UMKMCubit>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "My App",
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: Container(
          child: BlocBuilder<UMKMCubit, UMKMModel>(
            buildWhen: (previousState, state) {
              developer.log("${previousState.id} -> ${state.id}",
                  name: 'logbayu');
              return true;
            },
            builder: (context, univ) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "2106836, Bayu Wicaksono; 2101990; Ayesha Ali Firdaus; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: ElevatedButton(
                              child: Text("Reload Daftar UMKM"),
                              onPressed: () {
                                context.read<UMKMCubit>().fetchData();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: context.read<UMKMCubit>().listUMKM.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(context
                                  .read<UMKMCubit>()
                                  .listUMKM[index]
                                  .nama),
                              subtitle: Text(context
                                  .read<UMKMCubit>()
                                  .listUMKM[index]
                                  .jenis),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                              ),
                              trailing: Icon(Icons.more_vert),
                              onTap: () {
                                // Navigator.of(context)
                                //     .push(MaterialPageRoute(builder: (context) {
                                //   return DetailApp(
                                //       id: umkmCubit.listUMKM[index].id);
                                // }));
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return DetailApp(
                                      id: umkmCubit.listUMKM[index].id);
                                }));
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ]);
            },
          ),
        ));
  }
}
