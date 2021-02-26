import 'dart:io';

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

      _textNameController.text = _editedContact.name;
      _textEmailController.text = _editedContact.email;
      _textPhoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) { //criando a pagina para novo contato
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
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
        backgroundColor: Colors.red,
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
    );
  }


}
