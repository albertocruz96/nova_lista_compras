import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:novalistacompras/Home.dart';


class TelaHistorico extends StatefulWidget {
  @override
  _TelaHistoricoState createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {

  NumberFormat formatter = NumberFormat("00.00");
  var dataFormatada = DateFormat('dd/MM/yyyy');
  var horaFormatada = DateFormat('HH:mm');

  List recuperada = [];
  List listaMapRecuperada = [];
  int? tamanho;

  receberListaBanco({excluir})async{
    WidgetsFlutterBinding.ensureInitialized();
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("listas").orderBy("lista", descending: true).getDocuments();

    List documentSnapshot = querySnapshot.documents;

    for(int i = 0; i < documentSnapshot.length; i++){
      recuperada.add(documentSnapshot[i].data["lista"]);
    }
    setState(() {
      tamanho = recuperada.length;
    });
  }
  
  excluirDoBanco(index) async{
    WidgetsFlutterBinding.ensureInitialized();
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("listas").orderBy("lista", descending: true).getDocuments();
    List documentSnapshot = querySnapshot.documents;

    String document = documentSnapshot[index].data["lista"][0]["nomelista"].toString();

    db.collection("listas").document(document).delete();

    recuperada.clear();
    setState(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TelaHistorico(),
        ),
      );
    });
  }

  mostrarLista(indice){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))
            ),
            title: Container(
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Recuperar lista",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue
                        ),
                      ),
                    ],
                  ),
                )
            ),
            content: Container(
              padding: EdgeInsets.all(4),
              height: 500,
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),


              child: ListView.builder(
                shrinkWrap: true,
                itemCount: listaMapRecuperada.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(6),
                    margin: EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      border: Border.all(width: 3, color: Colors.black),
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            listaMapRecuperada[index]["name"].toString(),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),
                          ),
                        ),

                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "Preço: ",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                  ),
                                  Text(
                                    formatter.format(listaMapRecuperada[index]["price"]),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(right: 15),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "Qntde: ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
                                      ),
                                    ),
                                    Text(
                                      listaMapRecuperada[index]["quantidade"].toString(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
                                      ),
                                    ),
                                  ],
                                )
                            ),

                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              "Total: ",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),
                            ),
                            Text(
                              formatter.format(listaMapRecuperada[index]["total"]).toString(),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: (){
                            listaMapRecuperada.clear();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),
                          )
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: (){
                            setState(() {
                              listaMapRecuperada.clear();
                              for(Map map in recuperada[indice]){
                                listaMapRecuperada.add(map);
                              }
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Home.historico(listaMapRecuperada, 1),
                                ),
                              );
                            });
                          },
                          child: Text(
                            "Recuperar",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),
                          )
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    receberListaBanco();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historico"),
      ),

      body: Container(
          padding: EdgeInsets.all(4),
          child: Center(
            child: Column(
              children: <Widget>[
                Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 3, color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        //color: Colors.black38
                      ),
                      padding: EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 6),
                      child: ListView.builder(
                          itemCount: recuperada.length,
                          itemBuilder: (context, indice){
                            return Slidable(
                                child: GestureDetector(
                                  onTap: (){
                                    mostrarLista(indice);
                                    for(Map map in recuperada[indice]){
                                      listaMapRecuperada.add(map);
                                    }
                                  },
                                  child: Container(
                                    height: 70,
                                    padding: EdgeInsets.all(8),
                                    margin: EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue, width: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.blueAccent
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Hora: ",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black
                                                  ),
                                                ),
                                                Text(
                                                  horaFormatada.format(DateTime.fromMillisecondsSinceEpoch(recuperada[indice][0]["diafinalizado"] - 10800000)),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Dia: ",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black
                                                  ),
                                                ),
                                                Text(
                                                  dataFormatada.format(DateTime.fromMillisecondsSinceEpoch(recuperada[indice][0]["diafinalizado"] - 10800000)),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Itens no carrinho: ",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black
                                                  ),
                                                ),
                                                Text(
                                                  recuperada[indice][0]["carrinho"].toString(),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Total: ",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black
                                                  ),
                                                ),
                                                Text(
                                                  "R\$ "+ formatter.format(recuperada[indice][0]["somatotal"]).toString(),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              actionPane: SlidableBehindActionPane(),
                              secondaryActions: <Widget>[
                                ElevatedButton(
                                  child: Column(
                                    children: <Widget>[
                                      Icon(
                                          Icons.delete_outline
                                      ),
                                      Text("Excluir")
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                  onPressed: (){
                                    excluirDoBanco(indice);
                                  },
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                            //side: BorderSide(color: Colors.red)
                                          )
                                      ),
                                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red)
                                  ),
                                ),
                              ],
                            );
                          }
                      ),
                    ),
                ),
              ],
            ),
          )
      ),
    );
  }
}
