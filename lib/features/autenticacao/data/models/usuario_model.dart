import 'package:hive/hive.dart';

part 'usuario_model.g.dart'; // Arquivo gerado automaticamente

@HiveType(typeId: 0) // IDs devem ser únicos por projeto
class UsuarioModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nome;

  UsuarioModel({required this.id, required this.nome});
}
