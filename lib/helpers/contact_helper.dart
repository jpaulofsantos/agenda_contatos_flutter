import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String pictureColumn = "pictureColumn";


class ContactHelper { // declarando a classse

  static final ContactHelper _instance = ContactHelper.internal(); //singleton - criando um objeto da propria classe (_instance) e chama um construtor interno (somente pode ser chamado de dentro da classe)

  factory ContactHelper() => _instance; // ContactHelper._instance para ter acesso

  ContactHelper.internal();

  Database _db; //apenas a classe ContactHelper terá acesso ao banco de dados

  Future<Database> get db async {

    if(_db != null) {
      return _db;
    } else {
      _db = await initDb(); // iniciando o banco
      return _db;
    }
  }

  Future<Database> initDb() async { // criando a função que inicia o banco de dados

    final dataBasePath = await getDatabasesPath(); //usar o await pois a informação não é retornada instantaneamente
    final path = join(dataBasePath, "contacts.db"); //pegando o caminho "dataBasePath", juntando com o nome do banco e retornando o caminho em "path"
    
    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async { //iniciando o banco com o path informado
      await db.execute( //criando a tabela
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
            "$phoneColumn TEXT, $pictureColumn TEXT)" //vai criar a tabela apenas na primeira vez, caso a tabela ainda não tenha sido criada
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async { // função para salvar um contato - recebe um Contact
    Database dbContact = await db; // obtendo o banco de dados
    contact.id = await dbContact.insert(contactTable, contact.toMap()); //inserindo o contato na tabela
    return contact;
  }

  Future<Contact> getContact(int id) async { // função para ler um contato
    Database dbContact = await db; // obtendo o banco de dados
    List<Map> maps = await dbContact.query(contactTable,
    columns: [idColumn, nameColumn, emailColumn, phoneColumn, pictureColumn],
    where: "$idColumn = ?",
    whereArgs: [id]); //fazendo a query, filtrando pelo ID e jogando o resultado em um map

    if (maps.length > 0) {
      return Contact.fromMap(maps.first); //caso encontre algum resultado, retorna o primeiro elemento do map
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async { //função para deletar um contato
    Database dbContact = await db; // obtendo o banco de dados
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]); //deletando o contato e retornando um int
  }

  Future<int> updateContact(Contact contact) async { // função para update do contato
    Database dbContact = await db; // obtendo o banco de dados
    return await dbContact.update(contactTable, contact.toMap(), where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {// função que retorna todos os contatos
    Database dbContact = await db; // obtendo o banco de dados
    List contactListMap = await dbContact.rawQuery("SELECT * FROM $contactTable"); //obtendo um mapa com todos os resultados
    List<Contact> contactList = List(); // criando uma lista de contatos
    for (Map map in contactListMap) { // iterando a lista de mapas "contactListaMap" e add na lista de contatos "contactList"
      contactList.add(Contact.fromMap(map));
    }
    return contactList;
  }

  Future<int> getNumber() async { // função para retornar a quantidade de itens da tabela
    Database dbContact = await db; // obtendo o banco de dados
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT count(*) FROM $contactTable"));
  }

  Future close() async { //fechando o banco
    Database dbContact = await db; // obtendo o banco de dados
    dbContact.close();
  }
}

class Contact {

  int id;
  String name;
  String email;
  String phone;
  String picture; //local onde a imagem está armazenada

  Contact();
  Contact.fromMap(Map map) { //informações dos contatos virão em forma de map

    id = map[idColumn]; //recebe o id do map e joga em "id"
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    picture = map[pictureColumn];

  }

  Map toMap() { // transformando os dados do contato em um map

    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      pictureColumn: picture
    };

    if(id!=null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() { //print no contato caso necessário
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, picture: $picture";
  }
}