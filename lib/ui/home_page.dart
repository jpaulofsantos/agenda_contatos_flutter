import 'package:agenda_contatos_flutter/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget { //1 - criando o stful
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper(); //instanciando o ContactHelper; se criar mais de um objeto, serão a mesma referência, o mesmo objeto

  @override
  void initState() {
    super.initState();

    Contact contact = Contact();

    /*contact.name = "JP2";
    contact.email = "jpaulofsantos@gmail.com2";
    contact.phone = "11987403616-2";
    contact.picture = "pictureTest-2";*/

    helper.saveContact(contact);

    helper.getAllContacts().then((list) => print(list));

  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


