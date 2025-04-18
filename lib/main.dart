import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart';
//Verificar pq o ç não está funcionando no Android Studio
/*
* Aplicativo de Cadastro
* Desenvolvido por Vinicius de Oliveira Rocha Pessanha
* FACULDADE DO CENTRO LESTE - UCL
* CURSO: ANÁLISE E DESENVOLVIMENTO DE SISTEMAS
*
* Sistema de leitor de código de barras:
* https://github.com/mono0926/barcode_scan2
* 
* Preenchimento de endereço a partir do CEP:
* https://medium.com/flutter-comunidade-br/consultando-ceps-com-flutter-a395b86ce34a
*/

// --- MODELOS DE ENTIDADE ---

// Classe Usuario - p/ gerenciar usuarios
class Usuario {
  final String id;
  final String nome;
  final String senha;

  Usuario({required this.id, required this.nome, required this.senha});
// Converte p/ JSON
  Map<String, dynamic> paraJson() => {'id': id, 'nome': nome, 'senha': senha};
  // Cria Usuario a partir de JSON
  factory Usuario.deJson(Map<String, dynamic> json) =>
      Usuario(id: json['id'], nome: json['nome'], senha: json['senha']);
}
// Classe Cliente - p/ gerenciar clientes
class Cliente {
  final String id;
  final String nome;
  final String tipo;
  final String cpfCnpj;
  final String? email;
  final String? telefone;
  final String? cep;
  final String? endereco;
  final String? bairro;
  final String? cidade;
  final String? estado;

  Cliente({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.cpfCnpj,
    this.email,
    this.telefone,
    this.cep,
    this.endereco,
    this.bairro,
    this.cidade,
    this.estado,
  });
// Converte p/ JSON
  Map<String, dynamic> paraJson() => {
    'id': id,
    'nome': nome,
    'tipo': tipo,
    'cpfCnpj': cpfCnpj,
    'email': email,
    'telefone': telefone,
    'cep': cep,
    'endereco': endereco,
    'bairro': bairro,
    'cidade': cidade,
    'estado': estado,
  };
// Cria Cliente a partir de JSON
  factory Cliente.deJson(Map<String, dynamic> json) => Cliente(
    id: json['id'],
    nome: json['nome'],
    tipo: json['tipo'],
    cpfCnpj: json['cpfCnpj'],
    email: json['email'],
    telefone: json['telefone'],
    cep: json['cep'],
    endereco: json['endereco'],
    bairro: json['bairro'],
    cidade: json['cidade'],
    estado: json['estado'],
  );
}
// Classe Produto - p/ gerenciar produtos

class Produto {
  final String id;
  final String nome;
  final String unidade;
  final double quantidadeEstoque;
  final double precoVenda;
  final int status;
  final double? custo;
  final String? codigoBarras;

  Produto({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.quantidadeEstoque,
    required this.precoVenda,
    required this.status,
    this.custo,
    this.codigoBarras,
  });
  // Converte p/ JSON
  Map<String, dynamic> paraJson() => {
    'id': id,
    'nome': nome,
    'unidade': unidade,
    'quantidadeEstoque': quantidadeEstoque,
    'precoVenda': precoVenda,
    'status': status,
    'custo': custo,
    'codigoBarras': codigoBarras,
  };
  // Cria Produto a partir de JSON

  factory Produto.deJson(Map<String, dynamic> json) => Produto(
    id: json['id'],
    nome: json['nome'],
    unidade: json['unidade'],
    quantidadeEstoque: json['quantidadeEstoque'],
    precoVenda: json['salePrice'],
    status: json['status'],
    custo: json['custo'],
    codigoBarras: json['barcode'],
  );
}

// --- CLASSES DE CONTROLE ---

// ControladorUsuario - regras p/ usuarios
class ControladorUsuario {
  List<Usuario> usuarios = [];
  final String nomeArquivo = 'usuarios.json';
  
  // Carrega usuarios do arquivo
  Future<void> carregarUsuarios() async {
    final arquivo = await _obterArquivo(nomeArquivo);
    if (await arquivo.exists()) {
      final conteudo = await arquivo.readAsString();
      final List<dynamic> json = jsonDecode(conteudo);
      usuarios = json.map((e) => Usuario.deJson(e)).toList();
    } else {
      usuarios = [Usuario(id: '1', nome: 'admin', senha: 'admin')];
      await salvarUsuarios();
    }
  }
// Salva usuarios no arquivo
  Future<void> salvarUsuarios() async {
    final arquivo = await _obterArquivo(nomeArquivo);
    await arquivo.writeAsString(
      jsonEncode(usuarios.map((e) => e.paraJson()).toList()),
    );
  }
// Valida usuario (login)
  bool validarUsuario(String nome, String senha) {
    return usuarios.any(
      (usuario) => usuario.nome == nome && usuario.senha == senha,
    );
  }
// Valida campos obrigatorios
  String? validarCampos(String nome, String senha) {
    if (nome.isEmpty || senha.isEmpty) {
      return 'Todos os campos são obrigatórios';
    }
    if (usuarios.any((usuario) => usuario.nome == nome)) {
      return 'Usuário já existe';
    }
    return null;
  }
// Cria novo usuario
  void criarUsuario(String nome, String senha) {
    final id = (usuarios.length + 1).toString();
    usuarios.add(Usuario(id: id, nome: nome, senha: senha));
    salvarUsuarios();
  }
// Atualiza usuario existente
  void atualizarUsuario(String id, String nome, String senha) {
    final indice = usuarios.indexWhere((usuario) => usuario.id == id);
    if (indice != -1) {
      usuarios[indice] = Usuario(id: id, nome: nome, senha: senha);
      salvarUsuarios();
    }
  }
// Exclui usuario
  void excluirUsuario(String id) {
    usuarios.removeWhere((usuario) => usuario.id == id);
    salvarUsuarios();
  }
}
// ControladorCliente e ControladorProduto seguem a mesma lógica
// com métodos p/ carregar, salvar, validar, criar, atualizar e excluir

class ControladorCliente {
  List<Cliente> clientes = [];
  final String nomeArquivo = 'clientes.json';

  Future<void> carregarClientes() async {
    final arquivo = await _obterArquivo(nomeArquivo);
    if (await arquivo.exists()) {
      final conteudo = await arquivo.readAsString();
      final List<dynamic> json = jsonDecode(conteudo);
      clientes = json.map((e) => Cliente.deJson(e)).toList();
    }
  }

  Future<void> salvarClientes() async {
    final arquivo = await _obterArquivo(nomeArquivo);
    await arquivo.writeAsString(
      jsonEncode(clientes.map((e) => e.paraJson()).toList()),
    );
  }

  String? validarCampos(String nome, String tipo, String cpfCnpj) {
    if (nome.isEmpty || tipo.isEmpty || cpfCnpj.isEmpty) {
      return 'Campos obrigatórios não podem estar vazios';
    }
    return null;
  }

  void criarCliente(Cliente cliente) {
    clientes.add(cliente);
    salvarClientes();
  }

  void atualizarCliente(String id, Cliente clienteAtualizado) {
    final indice = clientes.indexWhere((cliente) => cliente.id == id);
    if (indice != -1) {
      clientes[indice] = clienteAtualizado;
      salvarClientes();
    }
  }

  void excluirCliente(String id) {
    clientes.removeWhere((cliente) => cliente.id == id);
    salvarClientes();
  }
}

class ControladorProduto {
  List<Produto> produtos = [];
  final String nomeArquivo = 'produtos.json';

  Future<void> carregarProdutos() async {
    final arquivo = await _obterArquivo(nomeArquivo);
    if (await arquivo.exists()) {
      final conteudo = await arquivo.readAsString();
      final List<dynamic> json = jsonDecode(conteudo);
      produtos = json.map((e) => Produto.deJson(e)).toList();
    }
  }

  Future<void> salvarProdutos() async {
    final arquivo = await _obterArquivo(nomeArquivo);
    await arquivo.writeAsString(
      jsonEncode(produtos.map((e) => e.paraJson()).toList()),
    );
  }

  String? validarCampos(
    String nome,
    String unidade,
    String quantidadeEstoque,
    String precoVenda,
    String status,
  ) {
    if (nome.isEmpty ||
        unidade.isEmpty ||
        quantidadeEstoque.isEmpty ||
        precoVenda.isEmpty ||
        status.isEmpty) {
      return 'Campos obrigatórios não podem estar vazios';
    }
    if (double.tryParse(quantidadeEstoque) == null ||
        double.tryParse(precoVenda) == null) {
      return 'Formato numérico inválido';
    }
    return null;
  }

  void criarProduto(Produto produto) {
    produtos.add(produto);
    salvarProdutos();
  }

  void atualizarProduto(String id, Produto produtoAtualizado) {
    final indice = produtos.indexWhere((produto) => produto.id == id);
    if (indice != -1) {
      produtos[indice] = produtoAtualizado;
      salvarProdutos();
    }
  }

  void excluirProduto(String id) {
    produtos.removeWhere((produto) => produto.id == id);
    salvarProdutos();
  }
}

// Obtem arquivo no diretorio do app
Future<File> _obterArquivo(String nomeArquivo) async {
  final diretorio = await getApplicationDocumentsDirectory();
  return File('${diretorio.path}/$nomeArquivo');
}

// --- GERENCIAMENTO DE ESTADO ---

// EstadoAplicativo - gerencia os controladores
class EstadoAplicativo extends ChangeNotifier {
  final ControladorUsuario controladorUsuario = ControladorUsuario();
  final ControladorCliente controladorCliente = ControladorCliente();
  final ControladorProduto controladorProduto = ControladorProduto();
  bool inicializado = false;
  // Inicializa o estado

  Future<void> inicializar() async {
    await controladorUsuario.carregarUsuarios();
    await controladorCliente.carregarClientes();
    await controladorProduto.carregarProdutos();
    inicializado = true;
    notifyListeners();
  }
}

// --- MAIN ---

// Variavel global p/ nome do usuario logado
String? nomeUsuarioLogado;

// Ponto de entrada do app
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (contexto) => EstadoAplicativo()..inicializar(),
      child: const MeuAplicativo(),
    ),
  );
}

// MeuAplicativo - widget principal
class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext contexto) {
    return MaterialApp(
      title: 'Aplicativo de Cadastro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          labelLarge: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (contexto) => const TelaLogin(),
        '/menu': (contexto) => const TelaMenu(),
        '/usuario': (contexto) => const TelaUsuario(),
        '/cliente': (contexto) => const TelaCliente(),
        '/produto': (contexto) => const TelaProduto(),
      },
    );
  }
}

// Tela de Login
class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  _EstadoTelaLogin createState() => _EstadoTelaLogin();
}

class _EstadoTelaLogin extends State<TelaLogin> {
  final _controladorNome = TextEditingController();
  final _controladorSenha = TextEditingController();
  String? _mensagemErro;

  void _entrar() {
    final estadoAplicativo = Provider.of<EstadoAplicativo>(
      context,
      listen: false,
    );
    if (estadoAplicativo.controladorUsuario.validarUsuario(
      _controladorNome.text,
      _controladorSenha.text,
    )) {
      setState(() {
        nomeUsuarioLogado = _controladorNome.text; // Atualiza a variável global
      });
      Navigator.pushReplacementNamed(context, '/menu');
    } else {
      setState(() {
        _mensagemErro = 'Credenciais inválidas';
      });
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final estadoAplicativo = Provider.of<EstadoAplicativo>(contexto);
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body:
          estadoAplicativo.inicializado
              ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _controladorNome,
                      decoration: const InputDecoration(labelText: 'Usuário *'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controladorSenha,
                      decoration: const InputDecoration(labelText: 'Senha *'),
                      obscureText: true,
                    ),
                    if (_mensagemErro != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _mensagemErro!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _entrar,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

// Tela de Menu
class TelaMenu extends StatelessWidget {
  const TelaMenu({super.key});

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Principal - ${nomeUsuarioLogado ?? ''}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(contexto, '/usuario'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 70),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Gerenciar Usuários'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(contexto, '/cliente'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 70),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Gerenciar Clientes'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(contexto, '/produto'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 70),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Gerenciar Produtos'),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.pushReplacementNamed(contexto, '/login');
                  },
                  backgroundColor: Colors.teal,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de Usuários
class TelaUsuario extends StatelessWidget {
  const TelaUsuario({super.key});

  @override
  Widget build(BuildContext contexto) {
    final estadoAplicativo = Provider.of<EstadoAplicativo>(contexto);
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: estadoAplicativo.controladorUsuario.usuarios.length,
        itemBuilder: (contexto, indice) {
          final usuario = estadoAplicativo.controladorUsuario.usuarios[indice];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                usuario.nome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.teal),
                    onPressed:
                        () =>
                            _mostrarDialogoUsuario(contexto, usuario: usuario),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      estadoAplicativo.controladorUsuario.excluirUsuario(
                        usuario.id,
                      );
                      estadoAplicativo.notifyListeners();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoUsuario(contexto),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoUsuario(BuildContext contexto, {Usuario? usuario}) {
    final estadoAplicativo = Provider.of<EstadoAplicativo>(
      contexto,
      listen: false,
    );
    final controladorNome = TextEditingController(text: usuario?.nome ?? '');
    final controladorSenha = TextEditingController(text: usuario?.senha ?? '');
    String? mensagemErro;

    showDialog(
      context: contexto,
      builder:
          (contexto) => StatefulBuilder(
            builder:
                (contexto, setState) => AlertDialog(
                  title: Text(
                    usuario == null ? 'Adicionar Usuário' : 'Editar Usuário',
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controladorNome,
                        decoration: const InputDecoration(labelText: 'Nome *'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controladorSenha,
                        decoration: const InputDecoration(labelText: 'Senha *'),
                        obscureText: true,
                      ),
                      if (mensagemErro != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            mensagemErro!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(contexto),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        final erro = estadoAplicativo.controladorUsuario
                            .validarCampos(
                              controladorNome.text,
                              controladorSenha.text,
                            );
                        if (erro != null) {
                          setState(() => mensagemErro = erro);
                          return;
                        }
                        if (usuario == null) {
                          estadoAplicativo.controladorUsuario.criarUsuario(
                            controladorNome.text,
                            controladorSenha.text,
                          );
                        } else {
                          estadoAplicativo.controladorUsuario.atualizarUsuario(
                            usuario.id,
                            controladorNome.text,
                            controladorSenha.text,
                          );
                        }
                        estadoAplicativo.notifyListeners();
                        Navigator.pop(contexto);
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
          ),
    );
  }
}

// Tela de Clientes
class TelaCliente extends StatelessWidget {
  const TelaCliente({super.key});

  @override
  Widget build(BuildContext contexto) {
    final estadoAplicativo = Provider.of<EstadoAplicativo>(contexto);
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: estadoAplicativo.controladorCliente.clientes.length,
        itemBuilder: (contexto, indice) {
          final cliente = estadoAplicativo.controladorCliente.clientes[indice];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                cliente.nome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(cliente.cpfCnpj),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.teal),
                    onPressed:
                        () =>
                            _mostrarDialogoCliente(contexto, cliente: cliente),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      estadoAplicativo.controladorCliente.excluirCliente(
                        cliente.id,
                      );
                      estadoAplicativo.notifyListeners();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCliente(contexto),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoCliente(BuildContext contexto, {Cliente? cliente}) {
    final estadoAplicativo = Provider.of<EstadoAplicativo>(
      contexto,
      listen: false,
    );
    final controladorNome = TextEditingController(text: cliente?.nome ?? '');
    final controladorTipo = TextEditingController(text: cliente?.tipo ?? 'F');
    final controladorCpfCnpj = TextEditingController(
      text: cliente?.cpfCnpj ?? '',
    );
    final controladorEmail = TextEditingController(text: cliente?.email ?? '');
    final controladorTelefone = TextEditingController(
      text: cliente?.telefone ?? '',
    );
    final controladorCep = TextEditingController(text: cliente?.cep ?? '');
    final controladorEndereco = TextEditingController(
      text: cliente?.endereco ?? '',
    );
    final controladorBairro = TextEditingController(
      text: cliente?.bairro ?? '',
    );
    final controladorCidade = TextEditingController(
      text: cliente?.cidade ?? '',
    );
    final controladorEstado = TextEditingController(
      text: cliente?.estado ?? '',
    );
    String? mensagemErro;

    showDialog(
      context: contexto,
      builder:
          (contexto) => StatefulBuilder(
            builder:
                (contexto, setState) => AlertDialog(
                  title: Text(
                    cliente == null ? 'Adicionar Cliente' : 'Editar Cliente',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: controladorNome,
                          decoration: const InputDecoration(
                            labelText: 'Nome *',
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: controladorTipo.text,
                          decoration: const InputDecoration(
                            labelText: 'Tipo *',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'F', child: Text('Física')),
                            DropdownMenuItem(
                              value: 'J',
                              child: Text('Jurídica'),
                            ),
                          ],
                          onChanged: (valor) => controladorTipo.text = valor!,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorCpfCnpj,
                          decoration: const InputDecoration(
                            labelText: 'CPF/CNPJ *',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorEmail,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorTelefone,
                          decoration: const InputDecoration(
                            labelText: 'Telefone',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorCep,
                          decoration: const InputDecoration(labelText: 'CEP'),
                          keyboardType: TextInputType.number,
                          onChanged: (valor) async {
                            if (valor.length == 8) {
                              final url = Uri.parse(
                                'https://viacep.com.br/ws/$valor/json/',
                              );
                              final resposta = await http.get(url);

                              if (resposta.statusCode == 200) {
                                final dados = jsonDecode(resposta.body);

                                if (dados['erro'] == null) {
                                  controladorEndereco.text =
                                      dados['logradouro'] ?? '';
                                  controladorBairro.text =
                                      dados['bairro'] ?? '';
                                  controladorCidade.text =
                                      dados['localidade'] ?? '';
                                  controladorEstado.text = dados['uf'] ?? '';
                                } else {
                                  setState(() {
                                    mensagemErro = 'CEP inválido';
                                  });
                                }
                              } else {
                                setState(() {
                                  mensagemErro = 'Erro ao buscar o CEP';
                                });
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorEndereco,
                          decoration: const InputDecoration(
                            labelText: 'Endereço',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorBairro,
                          decoration: const InputDecoration(
                            labelText: 'Bairro',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorCidade,
                          decoration: const InputDecoration(
                            labelText: 'Cidade',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorEstado,
                          decoration: const InputDecoration(labelText: 'UF'),
                        ),
                        if (mensagemErro != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              mensagemErro!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(contexto),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        final erro = estadoAplicativo.controladorCliente
                            .validarCampos(
                              controladorNome.text,
                              controladorTipo.text,
                              controladorCpfCnpj.text,
                            );
                        if (erro != null) {
                          setState(() => mensagemErro = erro);
                          return;
                        }
                        final novoCliente = Cliente(
                          id:
                              cliente?.id ??
                              (estadoAplicativo
                                          .controladorCliente
                                          .clientes
                                          .length +
                                      1)
                                  .toString(),
                          nome: controladorNome.text,
                          tipo: controladorTipo.text,
                          cpfCnpj: controladorCpfCnpj.text,
                          email:
                              controladorEmail.text.isEmpty
                                  ? null
                                  : controladorEmail.text,
                          telefone:
                              controladorTelefone.text.isEmpty
                                  ? null
                                  : controladorTelefone.text,
                          cep:
                              controladorCep.text.isEmpty
                                  ? null
                                  : controladorCep.text,
                          endereco:
                              controladorEndereco.text.isEmpty
                                  ? null
                                  : controladorEndereco.text,
                          bairro:
                              controladorBairro.text.isEmpty
                                  ? null
                                  : controladorBairro.text,
                          cidade:
                              controladorCidade.text.isEmpty
                                  ? null
                                  : controladorCidade.text,
                          estado:
                              controladorEstado.text.isEmpty
                                  ? null
                                  : controladorEstado.text,
                        );
                        if (cliente == null) {
                          estadoAplicativo.controladorCliente.criarCliente(
                            novoCliente,
                          );
                        } else {
                          estadoAplicativo.controladorCliente.atualizarCliente(
                            cliente.id,
                            novoCliente,
                          );
                        }
                        estadoAplicativo.notifyListeners();
                        Navigator.pop(contexto);
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
          ),
    );
  }
}

// Tela de Produtos
class TelaProduto extends StatelessWidget {
  const TelaProduto({super.key});

  @override
  Widget build(BuildContext contexto) {
    final estadoAplicativo = Provider.of<EstadoAplicativo>(contexto);
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: estadoAplicativo.controladorProduto.produtos.length,
        itemBuilder: (contexto, indice) {
          final produto = estadoAplicativo.controladorProduto.produtos[indice];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                produto.nome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Preço: R\$${produto.precoVenda.toStringAsFixed(2)} | Estoque: ${produto.quantidadeEstoque}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.teal),
                    onPressed:
                        () =>
                            _mostrarDialogoProduto(contexto, produto: produto),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      estadoAplicativo.controladorProduto.excluirProduto(
                        produto.id,
                      );
                      estadoAplicativo.notifyListeners();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoProduto(contexto),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoProduto(BuildContext contexto, {Produto? produto}) {
    final estadoAplicativo = Provider.of<EstadoAplicativo>(
      contexto,
      listen: false,
    );
    final controladorNome = TextEditingController(text: produto?.nome ?? '');
    final controladorUnidade = TextEditingController(
      text: produto?.unidade ?? 'un',
    );
    final controladorQuantidadeEstoque = TextEditingController(
      text: produto?.quantidadeEstoque.toString() ?? '',
    );
    final controladorPrecoVenda = TextEditingController(
      text: produto?.precoVenda.toString() ?? '',
    );
    final controladorStatus = TextEditingController(
      text: produto?.status.toString() ?? '0',
    );
    final controladorCusto = TextEditingController(
      text: produto?.custo?.toString() ?? '',
    );
    final controladorCodigoBarras = TextEditingController(
      text: produto?.codigoBarras ?? '',
    );
    String? mensagemErro;

    showDialog(
      context: contexto,
      builder:
          (contexto) => StatefulBuilder(
            builder:
                (contexto, setState) => AlertDialog(
                  title: Text(
                    produto == null ? 'Adicionar Produto' : 'Editar Produto',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: controladorNome,
                          decoration: const InputDecoration(
                            labelText: 'Nome *',
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: controladorUnidade.text,
                          decoration: const InputDecoration(
                            labelText: 'Unidade *',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'un',
                              child: Text('Unidade'),
                            ),
                            DropdownMenuItem(value: 'cx', child: Text('Caixa')),
                            DropdownMenuItem(
                              value: 'kg',
                              child: Text('Quilograma'),
                            ),
                            DropdownMenuItem(value: 'lt', child: Text('Litro')),
                            DropdownMenuItem(
                              value: 'ml',
                              child: Text('Mililitro'),
                            ),
                          ],
                          onChanged:
                              (valor) => controladorUnidade.text = valor!,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorQuantidadeEstoque,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade em Estoque *',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorPrecoVenda,
                          decoration: const InputDecoration(
                            labelText: 'Preço de Venda *',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: controladorStatus.text,
                          decoration: const InputDecoration(
                            labelText: 'Status *',
                          ),
                          items: const [
                            DropdownMenuItem(value: '0', child: Text('Ativo')),
                            DropdownMenuItem(
                              value: '1',
                              child: Text('Inativo'),
                            ),
                          ],
                          onChanged: (valor) => controladorStatus.text = valor!,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorCusto,
                          decoration: const InputDecoration(labelText: 'Custo'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorCodigoBarras,
                          decoration: InputDecoration(
                            labelText: 'Código de Barras',
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.teal,
                              ),
                              onPressed: () async {
                                try {
                                  var resultado = await BarcodeScanner.scan();
                                  if (resultado.type == ResultType.Barcode) {
                                    controladorCodigoBarras.text =
                                        resultado.rawContent;
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(contexto).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro ao escanear: $e'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        if (mensagemErro != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              mensagemErro!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(contexto),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        final erro = estadoAplicativo.controladorProduto
                            .validarCampos(
                              controladorNome.text,
                              controladorUnidade.text,
                              controladorQuantidadeEstoque.text,
                              controladorPrecoVenda.text,
                              controladorStatus.text,
                            );
                        if (erro != null) {
                          setState(() => mensagemErro = erro);
                          return;
                        }
                        final novoProduto = Produto(
                          id:
                              produto?.id ??
                              (estadoAplicativo
                                          .controladorProduto
                                          .produtos
                                          .length +
                                      1)
                                  .toString(),
                          nome: controladorNome.text,
                          unidade: controladorUnidade.text,
                          quantidadeEstoque: double.parse(
                            controladorQuantidadeEstoque.text,
                          ),
                          precoVenda: double.parse(controladorPrecoVenda.text),
                          status: int.parse(controladorStatus.text),
                          custo:
                              controladorCusto.text.isEmpty
                                  ? null
                                  : double.parse(controladorCusto.text),
                          codigoBarras:
                              controladorCodigoBarras.text.isEmpty
                                  ? null
                                  : controladorCodigoBarras.text,
                        );
                        if (produto == null) {
                          estadoAplicativo.controladorProduto.criarProduto(
                            novoProduto,
                          );
                        } else {
                          estadoAplicativo.controladorProduto.atualizarProduto(
                            produto.id,
                            novoProduto,
                          );
                        }
                        estadoAplicativo.notifyListeners();
                        Navigator.pop(contexto);
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
          ),
    );
  }
}
