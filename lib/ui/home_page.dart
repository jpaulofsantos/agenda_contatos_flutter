import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:agenda_contatos_flutter/helpers/contact_helper.dart';
import 'package:agenda_contatos_flutter/ui/contact_page.dart';
import 'package:flutter/material.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget { //1 - criando o stful
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper(); // 2 - instanciando o ContactHelper; se criar mais de um objeto, serão a mesma referência, o mesmo objeto

  List<Contact> contacts = List(); // 7 - declarando uma lista vazia


  @override
  void initState() { // 8 - criando o initstate
    super.initState();

    _getAllContacts();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // 3 - criando scaffold
      appBar: AppBar( // 4 - appbar
        actions: [
          PopupMenuButton<OrderOptions>( //menu para ordenar os nomes dos contatos
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>> [
                const PopupMenuItem<OrderOptions>(
                    child: Text("Ordenar de A-Z"),
                    value: OrderOptions.orderaz,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de Z-A"),
                  value: OrderOptions.orderza,
                )
              ],
            onSelected: _orderList,

          )
        ],
        title: Text("Contatos"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton( // 5 - botão flutuante
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigoAccent,
      ),
      body: ListView.builder(// 6 - add ListView no body
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length, // 10 - buscando o tamanho da lista e atribuindo no itemCount
          // ignore: missing_return
          itemBuilder: (context, index) {// 11 - função do builder
            return _contactCard(context, index);
          }),
    );
  }

  Widget _contactCard (BuildContext context, int index) { // 12 - criando a função que monta o card dos contatos
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container( // 13 - construindo o image redondo
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: contacts[index].picture != null ?
                      FileImage(File(contacts[index].picture)) :
                        AssetImage("images/Profile.png")
                  )
                ),
              ),
              Padding( // 14 - criando a coluna com as infos do contato
                  padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 16 - alinhando o texto a esquerda
                  children: [
                    Text(contacts[index].name ?? "", //15 - caso nao tenha nome salvo, mostrar vazio no campo
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(contacts[index].email ?? "", //15 - caso nao tenha email salvo, mostrar vazio no campo
                      style: TextStyle(
                          fontSize: 18.0
                      ),
                    ),
                    Text(contacts[index].phone ?? "", //15 - caso nao tenha email salvo, mostrar vazio no campo
                      style: TextStyle(
                          fontSize: 18.0
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _orderList(OrderOptions result) { //ordenando a lista de contatos
    switch(result) {
      case OrderOptions.orderaz:

        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:

        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }

    setState(() {

    });

  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: (){},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, //ajusta os botões para ocupar o menor espaço  possivel ao mostra-los (parte inferior)
                  children: [
                    Padding(
                        padding: EdgeInsets.all(5.0),
                        child: FlatButton(
                            onPressed: () {
                              launch("tel: ${contacts[index].phone}");
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Ligar",
                              style: TextStyle(
                                  color: Colors.indigoAccent, fontSize: 15.0
                              ),
                            )
                        ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage(contact: contacts[index]);
                          },
                          child: Text(
                            "Editar",
                            style: TextStyle(
                                color: Colors.indigoAccent, fontSize: 15.0
                            ),
                          )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: FlatButton(
                          onPressed: () {
                            helper.deleteContact(contacts[index].id);
                            setState(() {
                              contacts.removeAt(index);
                              Navigator.pop(context);
                            });

                          },
                          child: Text(
                            "Excluir",
                            style: TextStyle(
                                color: Colors.indigoAccent, fontSize: 15.0
                            ),
                          )
                      ),
                    )


                  ],
                ),
              );

            },
          );

        });


  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact,))); //recebendo um contato da tela contact page
    if(recContact != null) {
      if(contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) { // 9 - lendo todos os contatos e add na lista criada "contacts"
      setState(() {
        contacts = list;
      });
    });
  }
}
