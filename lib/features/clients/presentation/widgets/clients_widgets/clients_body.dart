import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_loading.dart';
import 'package:visit_proof/features/clients/presentation/controller/clients_bloc.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
import '../../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../../core/utils/general_widgets/g_widget_excel.dart';
import '../../../../../core/utils/general_widgets/g_widget_floating_btn.dart';
import '../../../../../core/utils/general_widgets/g_widget_search.dart';
import '../../../data/models/client_model.dart';
import '../../screens/add_client_scr.dart';
import 'clients_widget_card.dart';

class ClientsBody extends StatefulWidget {
  const ClientsBody({super.key, required this.clients, required this.loading});
  final List<ClientModel> clients;
  final bool loading;

  @override
  State<ClientsBody> createState() => _ClientsBodyState();
}

class _ClientsBodyState extends State<ClientsBody> {
  // final List<ClientModel> _allClients = [];
  // List<ClientModel> _filteredClients = [];
  final TextEditingController _searchController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   _filteredClients = _allClients;
  // }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: GWidgetAppbar(
            title: 'Clients',
            icon: Icons.people_alt_outlined,
            actions: [
              Center(
                child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GWidgetExcel()),
              ),
            ]).appbar(),
        body: GWidgetLoading(
          isLoading: widget.loading,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 5),
                GWidgetSearch(
                  searchController: TextEditingController(),
                  hint: 'Search clients...',
                  onChanged: (value) {},
                  onClear: () {},
                ),
                const SizedBox(height: 16),
                Expanded(
                    child: widget.clients.isEmpty && !widget.loading
                        ? Center(
                            child: Text(
                              'No clients yet!',
                              style: AppFonts(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: widget.clients.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: widget.clients.length - 1 == index
                                    ? EdgeInsets.only(bottom: 80)
                                    : EdgeInsets.zero,
                                child: ClientsWidgetCard(
                                    client: widget.clients[index]),
                              );
                            },
                          )),
              ],
            ),
          ),
        ),
        floatingActionButton: GWidgetFloatingBtn(
            text: "Add new client",
            onPressed: () async {
              final data =
                  await Navigator.pushNamed(context, AddClientScr.route);
              if (data is bool) {
                if (data) {
                  context
                      .read<ClientsBloc>()
                      .add(GetClientsEvent(noParameters: NoParameters()));
                }
              }
              // log('DATA: $data');
            }));
  }
}
