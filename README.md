# Coreved

Aplicativo de Cadastro desenvolvido em Flutter, voltado para o gerenciamento de **usuários**, **clientes** e **produtos** com funcionalidades adicionais como **leitura de código de barras** e **preenchimento automático de endereço via CEP**.

---

## 📱 Funcionalidades

- 🔐 Tela de login e autenticação de usuários
- 👤 CRUD completo de **Usuários**
- 👥 CRUD completo de **Clientes** com preenchimento automático de endereço via [ViaCEP](https://viacep.com.br/)
- 📦 CRUD completo de **Produtos**, com suporte a:
  - Leitura de **código de barras** com a câmera
  - Controle de **estoque**
  - Informações de **preço de venda**, **custo**, **status**, entre outros

---

## 🛠️ Tecnologias e Pacotes Utilizados

- **Flutter**
- **Provider** – gerenciamento de estado
- **http** – requisições HTTP (usado para consultar o ViaCEP)
- **path_provider** – acesso ao sistema de arquivos
- **barcode_scan2** – leitura de código de barras
- **JSON** – persistência de dados local (sem banco de dados)

---

## 🚀 Como rodar o projeto

1. Clone o repositório:

```bash
echo "# Coreved" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/vinitorUcl/Coreved.git
git push -u origin main
```
---

## 📸 **GIF**

![teste](https://github.com/user-attachments/assets/701496f1-c2f5-4eef-bc10-5b3dbdba65ec)

