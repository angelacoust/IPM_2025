import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'friends_viewmodel.dart';
import 'models.dart';
import 'repositories.dart';
import 'expense_detail.dart';
import 'utils/result.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({
    super.key,
    required this.title,
    required this.viewModel,
  });

  final String title;
  final FriendViewModel viewModel;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();
  Friend? _selectedFriend; // solo se usa en tablet

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet =
        MediaQuery.of(context).size.shortestSide >= 600; // criterio simple

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          widget.viewModel,
          widget.viewModel.load,
        ]),
        builder: (context, child) {
          final query = _searchController.text.toLowerCase();
          final filteredFriends = widget.viewModel.friends.where((f) {
            final name = f.name.toLowerCase();
            final id = (f.id ?? 0).toString();
            return name.contains(query) || id.contains(query);
          }).toList();

            final bool isLoading = widget.viewModel.load.running;

            final bool hasError = widget.viewModel.load.error;

          // ---- LISTA (reutilizada para móvil y tablet) ----
          final scrollList = CustomScrollView(
            slivers: [
              // buscador
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search friends by name or id...',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),

              // barra de error
              if (hasError)
                SliverToBoxAdapter(
                  child: InfoBar(
                    message: widget.viewModel.errorMessage!,
                    onPressed: widget.viewModel.load.clearResult,
                    isError: true,
                  ),
                ),

              // contenido
              filteredFriends.isEmpty
                  ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No friends')),
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final f = filteredFriends[index];
                    return FriendRow(
                      friend: f,
                      onTap: () {
                        if (isTablet) {
                          // en tablet mostramos en el panel derecho
                          setState(() => _selectedFriend = f);
                        } else {
                          // en móvil navegamos como siempre
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FriendDetailsScreen(friend: f),
                            ),
                          );
                        }
                      },
                    );
                  },
                  childCount: filteredFriends.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 200)),
            ],
          );

          // ---- MÓVIL: solo la lista (como antes) ----
          if (!isTablet) {
            return Stack(
              children: [
                if (isLoading)
                  const Center(child: CircularProgressIndicator()),
                scrollList,
              ],
            );
          }

          // ---- TABLET: maestro-detalle ----
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    if (isLoading)
                      const Center(child: CircularProgressIndicator()),
                    scrollList,
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 3,
                child: _selectedFriend == null
                    ? const Center(
                  child: Text('Select a friend to see details'),
                )
                    : FriendDetailsPane(friend: _selectedFriend!),
              ),
            ],
          );
        },
      ),
      floatingActionButton: null,
    );
  }
}

// ----------------------------------------------------------------------
// ROW DE LA LISTA
// ----------------------------------------------------------------------

class FriendRow extends StatelessWidget {
  const FriendRow({
    super.key,
    required this.friend,
    required this.onTap,
  });

  final Friend friend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        key: ValueKey("friend-${friend.id}"),
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(child: Text(friend.name.substring(0, 1))),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${friend.id}  •  '
                        'Credit: ${friend.creditBalance?.toStringAsFixed(2) ?? "0.00"}€  •  '
                        'Debit: ${friend.debitBalance?.toStringAsFixed(2) ?? "0.00"}€',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Icono de borrado eliminado.
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// INFOBAR
// ----------------------------------------------------------------------

class InfoBar extends StatelessWidget {
  const InfoBar({
    super.key,
    required this.message,
    required this.onPressed,
    this.isError = false,
  });

  final String message;
  final Function onPressed;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isError
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isError
                    ? Theme.of(context).colorScheme.onErrorContainer
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            ElevatedButton(
              onPressed: () => onPressed(),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                  isError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: const Text("Dismiss"),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// DIALOGO PARA AÑADIR AMIGO
// ----------------------------------------------------------------------

// Diálogo de añadir amigo eliminado intencionalmente.

// ----------------------------------------------------------------------
// DETALLE: PANTALLA COMPLETA (MÓVIL)
// ----------------------------------------------------------------------

class FriendDetailsScreen extends StatelessWidget {
  const FriendDetailsScreen({super.key, required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(friend.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FriendDetailsPane(friend: friend),
    );
  }
}

// ----------------------------------------------------------------------
// DETALLE: PANEL REUTILIZABLE (MÓVIL y TABLET)
// ----------------------------------------------------------------------

class FriendDetailsPane extends StatelessWidget {
  const FriendDetailsPane({super.key, required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 10,
        color: Colors.white,
        shadowColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // cabecera azul con datos del amigo
              Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${friend.name} (ID: ${friend.id})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.credit_score, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Credit: ${friend.creditBalance?.toStringAsFixed(2) ?? "0.00"}€',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.credit_card, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Debit: ${friend.debitBalance?.toStringAsFixed(2) ?? "0.00"}€',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // lista de gastos del amigo
              Expanded(
                child: FutureBuilder<Result<List<Expense>>>(
                  future: context
                      .read<ExpenseRepository>()
                      .listFriendExpenses(friend.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: Text('No expenses'));
                    }

                    final result = snapshot.data as Result<List<Expense>>;

                    if (result is Ok<List<Expense>>) {
                      final exps = result.value;
                      if (exps.isEmpty) {
                        return const Center(
                            child: Text('No expenses for this friend'));
                      }
                      return ListView.builder(
                        itemCount: exps.length,
                        itemBuilder: (context, idx) {
                          final e = exps[idx];
                          final idLabel =
                          (e.id ?? 0).toString().padLeft(2, '0');
                          return ListTile(
                            leading:
                            const Icon(Icons.monetization_on),
                            title: Text('$idLabel - ${e.description}'),
                            subtitle: Text(
                                '${e.date}  ${e.amount.toStringAsFixed(2)}€'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExpenseDetailScreen(expense: e),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (result is Error<List<Expense>>) {
                      return InfoBar(
                        message: 'Cannot load expenses',
                        onPressed: () {},
                        isError: true,
                      );
                    } else {
                      return const Center(child: Text('No data'));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
