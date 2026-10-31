import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_loading.dart';
import 'package:visit_proof/features/clients/presentation/controller/clients_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_search.dart';
import '../../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../../../core/utils/general_widgets/g_widget_floating_btn.dart';
import '../../../../../core/utils/general_widgets/g_widget_search.dart';
import '../../../data/models/client_detail_model/client_detail_model.dart';
import '../../screens/add_client_scr.dart';
import 'clients_widget_card.dart';

class ClientsBody extends StatefulWidget {
  const ClientsBody({super.key, required this.clients, required this.loading});
  final List<ClientDetailModel> clients;
  final bool loading;

  @override
  State<ClientsBody> createState() => _ClientsBodyState();
}

class _ClientsBodyState extends State<ClientsBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClientDetailModel> get _visibleClients => widget.clients
      .where((client) => GFunSearch.matches(_query, [
            client.name,
            client.phone,
            client.email,
            client.site?.city?.name,
            client.site?.addressDetail,
          ]))
      .toList();

  Future<void> _addClient() async {
    final data = await Navigator.pushNamed(context, AddClientScr.route);
    if (data == true && mounted) {
      context.read<ClientsBloc>().add(GetClientsEvent(noParameters: NoParameters()));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final clients = _visibleClients;

    return Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: GWidgetAppbar(title: 'Clients', icon: Icons.people_alt_outlined)
            .appbar(),
        body: GWidgetLoading(
          isLoading: widget.loading,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 5),
                GWidgetSearch(
                  searchController: _searchController,
                  hint: 'Search name, phone, email, city...',
                  onChanged: (value) => setState(() => _query = value ?? ''),
                  onClear: _clearSearch,
                ),
                const SizedBox(height: 16),
                Expanded(
                    child: clients.isEmpty
                        ? (widget.loading
                            ? const SizedBox.shrink()
                            : SingleChildScrollView(child: _emptyState()))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: clients.length,
                            itemBuilder: (context, index) =>
                                ClientsWidgetCard(client: clients[index]),
                          )),
              ],
            ),
          ),
        ),
        floatingActionButton:
            GWidgetFloatingBtn(text: "Add new client", onPressed: _addClient));
  }

  Widget _emptyState() {
    if (widget.clients.isEmpty) {
      return GWidgetEmpty(
        icon: Icons.people_alt_rounded,
        title: 'No clients yet',
        subtitle: 'Add your first client to start booking visits.',
        actionText: 'Add first client',
        onAction: _addClient,
      );
    }
    return GWidgetEmpty(
      icon: Icons.search_off_rounded,
      title: 'No matching clients',
      subtitle: 'Try a different name, phone or city.',
      actionText: 'Clear search',
      onAction: _clearSearch,
    );
  }
}
