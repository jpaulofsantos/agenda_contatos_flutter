import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:agenda_contatos_flutter/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {

  final Contact contact; // instanciando um contato
  ContactPage({this.contact}); // construtor para abrir a pagina e editar um contato (opcional)

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final TextEditingController _textNameController = TextEditingController();
  final TextEditingController _textEmailController = TextEditingController();
  final TextEditingController _textPhoneController = TextEditingController();

  final _nameFocus = FocusNode(); //focus no campo nome

  Contact _editedContact;
  bool _userEdited = false;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      //criando os controllers dos textFields
      _textNameController.text = _editedContact.name;
      _textEmailController.text = _editedContact.email;
      _textPhoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) { //criando a pagina para novo contato
    return WillPopScope( //chama uma função antes de sair de tela (caso user tenha editado o contato e clicar na seta para voltar para tela anterior)
        onWillPop: _requestPop, //chama a função criada para gerenciar a seta "voltar"
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.indigo,
            title: Text(_editedContact.name ?? "Novo Contato"), //caso tenha nome, pega do _editContact, caso não, "Novo Contato"
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton( //botão salvar
            onPressed: () {
              if(_editedContact.name != null && _editedContact.name.isNotEmpty) {
                Navigator.pop(context, _editedContact); //remove a tela e volta para anterior (funciona como uma pilha)
              } else {
                FocusScope.of(context).requestFocus(_nameFocus); //aplicando focus no campo name
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.indigoAccent,
          ),
          body: SingleChildScrollView( // criando o body
            padding: EdgeInsets.all(10.0), // add padding
            child: Column( // column
              children: [
                GestureDetector( //clicar sobre a imagem
                  child: Container( //imagem
                    width: 120.0,
                    height: 120.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editedContact.picture != null ?
                            FileImage(File(_editedContact.picture)) :
                            AssetImage("images/Profile.png")
                        )
                    ),
                  ),
                  onTap: () { //add imagem ao contato atraves do import ImagePicker
                    ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                      if(file == null) return;
                      setState(() {
                        _editedContact.picture = file.path;
                      });
                    }
                    );

                  },
                ),
                TextField(
                  focusNode: _nameFocus,
                  controller: _textNameController,
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (text) {
                    _userEdited = true;
                    setState(() {
                      _editedContact.name = text;
                    });
                  },
                ),
                TextField(
                  controller: _textEmailController,
                  decoration: InputDecoration(labelText: "Email"),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _textPhoneController,
                  decoration: InputDecoration(labelText: "Phone"),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                )
              ],
            ),
          ),
        )
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair, as alterações serão perdidas!"),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancelar")),
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context); //sai da tela do alert
                      Navigator.pop(context); //sai da tela do contact page
                    },
                    child: Text("Sair"))
              ],
            );
          });

      return Future.value(false); //não sai automaticamente da tela

    } else {

      return Future.value(true); //sai automaticamente da tela

    }
  }
}
