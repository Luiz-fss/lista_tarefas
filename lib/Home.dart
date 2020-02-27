import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Map<String,dynamic> _ultimaTarefaRemovida = Map();

  TextEditingController _controleTarefa = TextEditingController();

  List _listaTarefas = [

  ];

  Future<File>_getFile ()async{
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa(){

    String textDigitado = _controleTarefa.text;

    //Criando os dados

    Map<String,dynamic> tarefa = Map();
    tarefa["titulo"] = textDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });

    _salvarArquivo();
    _controleTarefa.text = "";

  }

  _salvarArquivo() async{

    var arquivo = await _getFile();

    //recuperando o local para salvar os arquivos
    //final diretorio = await getApplicationDocumentsDirectory();
    /*O File, vai receber o caminho, que está salvo em 'diretorio' / o
    * nome que é dado para o arquivo, nesse caso '/dados.json'*/
    //var arquivo = File("${diretorio.path}/dados.json");
    //transforma a lista em uma string
    String dados = json.encode(_listaTarefas);

    //Vai ler e salvar os dados como uma String
    arquivo.writeAsString(dados);

  }

  _lerArquivo() async{

    try{

      final arquivo = await _getFile();
      return arquivo.readAsString();

    }catch(e){

    return null;
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lerArquivo().then( (dados){
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    } );
  }

  Widget criarItemLista(contex, index){

    /*o item não pode ser ultilizado pois ao colocarmos novamente a tarefa
    * removida ela volta para com o mesmo valor no "item" e a "key"
    * deve ser um valor único, ou seja não pode ter repetições.
    * Portanto a estrutura usada, através do DateTime garante que sempre será
    * gerado um valor único*/
    final item = _listaTarefas[index]["titulo"];

    return Dismissible(
      /*toda vez que executa o "milisecondsSinceEpoch" vai ter um resultado
      * diferente. É diferente de gerar um número randomico pois
      * correria risco de em algum momento encontar um valor igual*/
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction){

        //Recuperando o ultimo item excluido
        _ultimaTarefaRemovida = _listaTarefas[index];

        _listaTarefas.removeAt(index);
        _salvarArquivo();

        //snackbar
        final snackbar = SnackBar(
            duration: Duration(
              seconds: 5
            ),
            content: Text("Tarefa removida"),
          action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                /*inserindo na lista de tarefas o ultimo item removido
                * e na mesma posição*/
                setState(() {
                  _listaTarefas.insert(index,_ultimaTarefaRemovida);
                });
                _salvarArquivo();

              }
              ),
        );

        Scaffold.of(contex).showSnackBar(snackbar);

      },
      background: Container(
        padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.delete,
            color: Colors.white,
          ),

        ],
      ),
      color: Colors.red,
      ),
      child: CheckboxListTile(
        title: Text(_listaTarefas[index]["titulo"]),
        value: _listaTarefas[index]["realizada"],
        onChanged: (valorAlterado){
          setState(() {
            _listaTarefas[index]["realizada"] = valorAlterado;
          });
          _salvarArquivo();

        },

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _salvarArquivo();
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Lista de tarefas"
        ),
        backgroundColor: Colors.purple,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: (){
          showDialog(
              context: context,
            builder: (context){
                return AlertDialog(
                  title: Text("Adicionar tarefa"),
                  content: TextField(
                    controller: _controleTarefa,
                    decoration: InputDecoration(
                      labelText: "Digite sua tarefa"
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Cancelar"),
                      onPressed: ()=> Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: (){
                        //salvar
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
            }
          );
        },

      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefas.length,
                /*
                * podemos passar métodos tbm para o itemBuild além de
                * funções anonimas*/
                itemBuilder: criarItemLista
            ),
          )
        ],
      )

    );
  }
}
