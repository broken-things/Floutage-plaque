// lib/pages/history_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../storage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> _plates = [];

  @override
  void initState() {
    super.initState();
    _loadPlates();
  }

  Future<void> _loadPlates() async {
    final list = await Storage.getSavedPlates();
    setState(() => _plates = list);
  }

  Future<void> _deletePlate(int index) async {
    final p = _plates[index];
    await Storage.deletePlate(p);
    setState(() => _plates.removeAt(index));
  }

  Future<void> _usePlate(int index) async {
    final p = _plates[index];
    // On peut renvoyer la plaque à la page précédente via Navigator.pop
    // mais ici on la renverra avec pop pour la page appelante.
    Navigator.pop(context, p);
  }

  Widget _buildItem(BuildContext context, int index) {
    final p = _plates[index];
    final isLogo = p.startsWith('[LOGO]:');
    return ListTile(
      leading: isLogo ? const Icon(Icons.image) : const Icon(Icons.text_fields),
      title: Text(isLogo ? 'Logo #${index + 1}' : p),
      subtitle: isLogo ? Text(p.substring('[LOGO]:'.length)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'Utiliser',
            onPressed: () => _usePlate(index),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Supprimer',
            onPressed: () => _deleteConfirm(index),
          ),
        ],
      ),
      onTap: () => _usePlate(index),
    );
  }

  void _deleteConfirm(int index) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text('Supprimer cette plaque personnalisée ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlate(index);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des plaques')),
      body: RefreshIndicator(
        onRefresh: _loadPlates,
        child: _plates.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Aucune plaque sauvegardée.')),
                ],
              )
            : ListView.separated(
                itemCount: _plates.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: _buildItem,
              ),
      ),
    );
  }
}
