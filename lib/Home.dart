import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:novalistacompras/screens/telaHistorico.dart';
import 'package:novalistacompras/screens/telaSecundaria.dart';
import 'package:validatorless/validatorless.dart';


class Home extends StatefulWidget {

  List listProdutos = [];
  int numero = 0;

  Home();
  Home.historico(this.listProdutos, this.numero);

  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home> {

  NumberFormat formatter = NumberFormat("00.00");

  int itensNoCarrinho = 0;
  double somaDosItens = 0.0;
  var _context;
  var _index;
  final formKey = GlobalKey<FormState>();

  //testeGit
  
  List _listaDeItens = [];
  List _listaTeste = [];

  Map<String, dynamic> _ultimoItemRemovido = Map();

  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerPrice = TextEditingController();
  TextEditingController _controllerQuantidade = TextEditingController();

  _criarItem(){
    double priceTotal = double.parse(_controllerPrice.text.replaceAll(",", ".")) * int.parse(_controllerQuantidade.text);

        Map<String, dynamic> item = Map();
        item["name"] = _controllerName.text;
        item["price"] = double.parse(_controllerPrice.text.replaceAll(",", "."));
        item["total"] = priceTotal;
        item["somatotal"] = 0.0;
        item["quantidade"] = int.parse(_controllerQuantidade.text);
        item["checkBox"] = true;
        item["nomelista"] = "";
        item["diafinalizado"] = 0;
        item["carrinho"] = 0;

    if(_listaDeItens.length >= 1){
      _listaDeItens.clear();
    }
    setState(() {
      _listaTeste.add(item);
      _listaDeItens = _listaTeste.reversed.toList();
      somaDosItens += priceTotal;
      itensNoCarrinho = itensNoCarrinho + 1;
    });
  }

  listaRecuperadaHistorico(){
    if(widget.numero >= 1) {
      setState(() {
        for(Map map in widget.listProdutos){
          Map<String, dynamic> myMap = Map<String, dynamic>.from(map);
          _listaTeste.add(myMap);
        }

        _listaDeItens = _listaTeste.reversed.toList();
        somaDosItens = widget.listProdutos[0]["somatotal"];
        itensNoCarrinho = int.parse(widget.listProdutos[0]["carrinho"]);
      });
      widget.numero = 0;
    }
  }

  _calcularPreco(index){
    if(_listaDeItens[index]["checkBox"] == false){
      setState(() {
        somaDosItens -= (double.parse(_listaDeItens[index]["total"].toString()));
        itensNoCarrinho = itensNoCarrinho - 1;
      });
    }
    if(_listaDeItens[index]["checkBox"] == true){
      setState(() {
        somaDosItens += (double.parse(_listaDeItens[index]["total"].toString()));
        itensNoCarrinho = itensNoCarrinho + 1;
      });
    }
  }

  _aumentarQuantidade(context, index){
    setState(() {
      _listaDeItens[index]["quantidade"]++;
      _listaDeItens[index]["total"] += _listaDeItens[index]["price"];
      somaDosItens += _listaDeItens[index]["price"];
    });
  }

  _diminuirQuantidade(context, index){
    setState(() {
      if(_listaDeItens[index]["quantidade"] > 1){
        _listaDeItens[index]["quantidade"]--;
        _listaDeItens[index]["total"] -= _listaDeItens[index]["price"];
        somaDosItens -= _listaDeItens[index]["price"];
      } else{
        _removerItemLista(context, index);
      }
    });
  }

  _atualizarLista(context, index){
    var totalatualizado = double.parse(_controllerPrice.text.replaceAll(",", ".")) * int.parse(_controllerQuantidade.text);

    if(_listaDeItens[index]["checkBox"] == true){
      somaDosItens -= (double.parse(_listaDeItens[index]["total"].toString()));
      setState(() {
        _listaDeItens[index]["name"] = _controllerName.text;
        _listaDeItens[index]["price"] = double.parse(_controllerPrice.text.replaceAll(",", "."));
        _listaDeItens[index]["quantidade"] = int.parse(_controllerQuantidade.text);
        _listaDeItens[index]["total"] = totalatualizado;
        somaDosItens += double.parse(totalatualizado.toString());
      });
    }
    else{
      setState(() {
        _listaDeItens[index]["name"] = _controllerName.text;
        _listaDeItens[index]["price"] = double.parse(_controllerPrice.text);
        _listaDeItens[index]["quantidade"] = int.parse(_controllerQuantidade.text);
        _listaDeItens[index]["total"] = totalatualizado;
      });
    }
  }

  _removerItemLista(context, index){
    _ultimoItemRemovido = _listaDeItens[index];

    if(_listaDeItens[index]["checkBox"] == true){
      setState(() {
        somaDosItens -= (double.parse(_listaDeItens[index]["total"].toString()));
        itensNoCarrinho = itensNoCarrinho - 1;
        _listaDeItens.removeAt(index);
      });
      final snackBar = SnackBar(
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 3),
          content: Text("Produto removido"),
          action: SnackBarAction(
              label: "DESFAZER",
              textColor: Colors.white,
              onPressed: (){
                setState(() {
                  _listaDeItens.insert(index, _ultimoItemRemovido);
                  somaDosItens += (double.parse(_listaDeItens[index]["total"].toString()));
                  itensNoCarrinho = itensNoCarrinho + 1;
                });
              }
          )
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    else{
      setState(() {
        _listaDeItens.removeAt(index);
      });
      final snackBar = SnackBar(
          backgroundColor: Colors.black38,
          duration: Duration(seconds: 3),
          content: Text("Produto removido"),
          action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  _listaDeItens.insert(index, _ultimoItemRemovido);
                });
              }
          )
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _limparLista(){
    if (_listaDeItens.length >= 1){
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
                    height: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Limpar lista",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue
                          ),
                        )
                      ],
                    ),
                  )
              ),
              content: Text(
                "Tem certeza que deseja excluir todos os produtos da lista",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
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
                                _listaTeste.clear();
                                _listaDeItens.clear();
                                somaDosItens = 0;
                                itensNoCarrinho = 0;
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Excluir",
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
  }

  _caixaShowDialog(index, var adicionarOuEditar){
    var titulo = "";
    var botao = "";
    if(adicionarOuEditar == "adicionar"){
      titulo = "Adicionar produto";
      botao = "Adicionar";
    } else{
      titulo = "Alterar produto";
      botao = "Alterar";
    }
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))
              ),
              contentPadding: EdgeInsets.only(left: 25, right: 25, bottom: 6),
              title: Container(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          titulo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue
                          ),
                        )
                      ],
                    ),
                  )
              ),
              content: Container(
                child: Form(
                  key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[

                        Container(
                          margin: EdgeInsets.only(bottom: 11),
                          height: 60,
                          child: TextFormField(
                            controller: _controllerName,
                            style: TextStyle(
                                fontSize: 18
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: "Nome",

                              border: OutlineInputBorder(),
                            ),
                            validator: Validatorless.required("Nome do produto obrigatorio"),
                          ),
                        ),


                        Container(
                          margin: EdgeInsets.only(bottom: 11),
                          height: 60,
                          child: TextFormField(
                            controller: _controllerPrice,
                            style: TextStyle(
                                fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Preço",
                              border: OutlineInputBorder(),
                            ),
                            validator: Validatorless.multiple([
                              Validatorless.required("Preço do produto obrigatorio"),
                              Validatorless.number("Digite apenas numeros")
                            ]),
                          ),
                        ),


                        Container(
                          height: 60,
                          child: TextFormField(
                            controller: _controllerQuantidade,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Quantidade",
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                            ),
                            validator: Validatorless.multiple([
                              Validatorless.required("Quantidade do produto obrigatoria"),
                              Validatorless.number("Digite apenas numeros"),
                            ]),
                          ),
                        ),

                      ],
                    ),
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
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          onPressed: () {
                            //cancelar
                            Navigator.pop(context);
                            _controllerName.clear();
                            _controllerPrice.clear();
                            _controllerQuantidade.clear();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {
                              //salvar
                              var formValidade = formKey.currentState?.validate() ?? false;
                              if(formValidade){
                                if(int.parse(_controllerQuantidade.text) > 0){
                                  if (adicionarOuEditar == "adicionar") {
                                    _criarItem();
                                  } else {
                                    _atualizarLista(context, index);
                                  }
                                  Navigator.pop(context);
                                  _controllerName.clear();
                                  _controllerPrice.clear();
                                  _controllerQuantidade.clear();
                                }
                              }
                            },
                            child: Text(
                              botao,
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
    listaRecuperadaHistorico();
    super.initState();
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerQuantidade.dispose();
    _controllerPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //APP BAR
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconSlideAction(
              caption: "Limpar lista",
              icon: Icons.delete_outline,
              color: Colors.blue,
              foregroundColor: Colors.black,
              onTap: (){
                _limparLista();
              },
            ),
          ),
        ],
        title: Text(
          "Lista de compras",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TelaHistorico()
                  )
              );
            },

            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_sharp,
                  color: Colors.black,
                  size: 25,
                  semanticLabel: "aaaa",
                ),
                Text(
                    "Historico",
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.black
                  ),
                )
              ],
            )
        ),
      ),

      //BODY
      body: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          children: <Widget>[
            Expanded(
              //retorno do list view builder
              child: ListView.builder(
                //reverse: true,
                key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                itemCount: _listaDeItens.length,
                itemBuilder: (context, index){
                  _context = context;
                  _index = index;
                  return Slidable(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xff133571)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  _listaDeItens[index]["name"].toString().substring(0,1).toUpperCase() + _listaDeItens[index]["name"].toString().substring(1),
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                ),
                                subtitle: Row(
                                  children: <Widget>[

                                    Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: GestureDetector(
                                        onTap: (){
                                          _diminuirQuantidade(context, index);
                                        },
                                        child: Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Text(
                                        "Qntd: " +  _listaDeItens[index]["quantidade"].toString(),
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.lightBlueAccent
                                          //fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: (){
                                        _aumentarQuantidade(context, index);
                                        },
                                      child: Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text(
                                  "Unid R\$ " + formatter.format(_listaDeItens[index]["price"]),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightBlueAccent
                                  ),
                                ),
                                Text(
                                  "R\$ " + formatter.format(_listaDeItens[index]["total"]),
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightGreen
                                  ),
                                ),
                              ],
                            ),

                            Checkbox(
                              fillColor: MaterialStateProperty.all(Colors.blue),
                                value: _listaDeItens[index]["checkBox"],
                                onChanged: (valorAlterado){
                                  setState(() {
                                    _listaDeItens[index]["checkBox"] = valorAlterado;
                                  });
                                  _calcularPreco(index);
                                }
                            )
                          ],
                        ),
                      ),
                      actionPane: SlidableBehindActionPane(),
                    secondaryActions: <Widget>[

                      Padding(
                        padding: EdgeInsets.only(left: 3, right: 3),
                        child: ElevatedButton(
                          child: Column(
                            children: <Widget>[
                              Icon(
                                  Icons.mode_edit_outlined
                              ),
                              Text("Editar")
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                          onPressed: (){
                            _controllerName.text = _listaDeItens[index]["name"].toString();
                            _controllerPrice.text = _listaDeItens[index]["price"].toString();
                            _controllerQuantidade.text = _listaDeItens[index]["quantidade"].toString();
                            _caixaShowDialog(index, "alterar");
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    //side: BorderSide(color: Colors.red)
                                  )
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                              //backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlueAccent)
                          ),
                        ),
                      ),


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
                          _removerItemLista(context, index);
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
                } //final do item builder
              )
            ),


            Container(
              padding: EdgeInsets.all(8),
              //margin: EdgeInsets.only(bottom: 0),
              height: 72,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 3.0, color: Colors.blueAccent),
                    //bottom: BorderSide(width: 1.0, color: Colors.black)
                  )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                fontSize: 23,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            itensNoCarrinho.toString(),
                            style: TextStyle(
                                color: Color(0xff267A18),
                                fontSize: 23,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 35),
                        child: Text(
                          "Total",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Row(
                        children: <Widget>[
                          Text(
                            "R\$ ",
                            style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent
                            ),
                          ),
                          Text(
                            formatter.format(somaDosItens),
                            style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff267A18)
                            ),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[

                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 22),
                      child: Text(
                        "Finalizar",
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom: 10, right: 22),
                      child: GestureDetector(
                        child: Icon(
                          Icons.checklist_outlined,
                          color: Colors.black,
                          size: 34,
                        ),
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TelaSecundaria(somaDosItens, itensNoCarrinho, _listaTeste)
                            )
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      //BOTAOOOOOO FLUTUANTE
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          "Adicionar",
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold
          ),
        ),
        onPressed: (){
          _caixaShowDialog(_index, "adicionar");
        },
      ),
    );
  }
}
