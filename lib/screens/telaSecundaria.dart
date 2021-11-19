import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:novalistacompras/Home.dart';


class TelaSecundaria extends StatefulWidget {

  double? valorTotal;
  int? quantidade;
  List? listDeProdutos;

  TelaSecundaria(this.valorTotal, this.quantidade, this.listDeProdutos);

  @override
  _TelaSecundariaState createState() => _TelaSecundariaState();
}

class _TelaSecundariaState extends State<TelaSecundaria> {

  NumberFormat formatter = NumberFormat("00.00");

  finalizarlista() async{
    if(widget.listDeProdutos!.length >= 1) {
      WidgetsFlutterBinding.ensureInitialized();
      Firestore db = Firestore.instance;

      DocumentReference documentReference = await db.collection("listas")
          .add(
          {
            "lista": widget.listDeProdutos
          }
      );

      widget.listDeProdutos![0]["somatotal"] = widget.valorTotal;
      widget.listDeProdutos![0]["nomelista"] =
          documentReference.documentID.toString();
      widget.listDeProdutos![0]["diafinalizado"] = DateTime
          .now()
          .millisecondsSinceEpoch;
      widget.listDeProdutos![0]["carrinho"] = widget.quantidade.toString();

      db.collection("listas")
          .document(documentReference.documentID)
          .setData(
          {
            "lista": widget.listDeProdutos
          }
      );

      setState(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Finalizar e salvar compra"
        ),
      ),

      body: Container(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            children: <Widget>[

              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 3, color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  //color: Colors.black38
                ),
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 6),
                height: 530,
                child: ListView.builder(
                    itemCount: widget.listDeProdutos!.length,
                    itemBuilder: (context, indice){
                      return Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blueAccent
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    widget.listDeProdutos![indice]["name"].toString(),
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
                                            formatter.format(widget.listDeProdutos![indice]["price"]).toString(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
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
                                            widget.listDeProdutos![indice]["quantidade"].toString(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                          ),
                                        ],
                                      )
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
                                          formatter.format(widget.listDeProdutos![indice]["total"]).toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            color: Colors.white
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                ),
              ),

              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.add_shopping_cart,
                            color: Colors.blueAccent,
                          ),
                          Text(
                            " Carrinho: ",
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 22,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            widget.quantidade.toString(),
                            style: TextStyle(
                                color: Color(0xff267A18),
                                fontSize: 25,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "R\$ ",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent
                            ),
                          ),
                          Text(
                            formatter.format(widget.valorTotal),
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff267A18)
                            ),
                          )
                        ],
                      ),
                    ],
                  ),


                  Padding(
                    padding: EdgeInsets.only(top: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        SizedBox(
                          height: 45,
                          width: 100,
                          child: ElevatedButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: Text(
                                  "Cancelar",
                                style: TextStyle(
                                  fontSize: 16
                                ),
                              )
                          ),
                        ),
                        SizedBox(
                          height: 45,
                          width: 100,
                          child: ElevatedButton(
                              onPressed: (){
                                finalizarlista();
                              },
                              child: Text(
                                "Finalizar",
                                style: TextStyle(
                                    fontSize: 16
                                ),
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}
