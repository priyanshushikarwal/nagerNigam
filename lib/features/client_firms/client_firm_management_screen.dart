import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/client_firm.dart';
import '../../state/client_firm_providers.dart';

class ClientFirmManagementScreen extends ConsumerStatefulWidget {
  const ClientFirmManagementScreen({super.key});

  @override
  ConsumerState<ClientFirmManagementScreen> createState() =>
      _ClientFirmManagementScreenState();
}

class _ClientFirmManagementScreenState
    extends ConsumerState<ClientFirmManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clientFirmsAsync = ref.watch(clientFirmsProvider);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Client/Contractor Firms Management'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('Add Client Firm'),
              onPressed: () => _showClientFirmDialog(context),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Box
            SizedBox(
              width: 400,
              child: TextBox(
                placeholder: 'Search by firm name...',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(FluentIcons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Client Firms List
            Expanded(
              child: clientFirmsAsync.when(
                data: (firms) {
                  final filteredFirms =
                      firms
                          .where(
                            (firm) => firm.firmName.toLowerCase().contains(
                              _searchQuery,
                            ),
                          )
                          .toList();

                  if (filteredFirms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FluentIcons.company_directory, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No client firms found'
                                : 'No firms match your search',
                            style: FluentTheme.of(context).typography.subtitle,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredFirms.length,
                    itemBuilder: (context, index) {
                      final firm = filteredFirms[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            firm.firmName,
                            style: FluentTheme.of(context).typography.bodyLarge,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (firm.address != null) ...[
                                const SizedBox(height: 4),
                                Text('Address: ${firm.address}'),
                              ],
                              if (firm.contactNo != null) ...[
                                const SizedBox(height: 2),
                                Text('Contact: ${firm.contactNo}'),
                              ],
                              if (firm.gstNo != null) ...[
                                const SizedBox(height: 2),
                                Text('GST: ${firm.gstNo}'),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(FluentIcons.edit),
                                onPressed:
                                    () => _showClientFirmDialog(
                                      context,
                                      firm: firm,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(FluentIcons.delete),
                                onPressed:
                                    () =>
                                        _confirmDeleteClientFirm(context, firm),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: ProgressRing()),
                error:
                    (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FluentIcons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: $error',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClientFirmDialog(BuildContext context, {ClientFirm? firm}) {
    final formKey = GlobalKey<FormState>();
    final firmNameController = TextEditingController(
      text: firm?.firmName ?? '',
    );
    final addressController = TextEditingController(text: firm?.address ?? '');
    final contactNoController = TextEditingController(
      text: firm?.contactNo ?? '',
    );
    final gstNoController = TextEditingController(text: firm?.gstNo ?? '');

    showDialog(
      context: context,
      builder:
          (context) => ContentDialog(
            title: Text(firm == null ? 'Add Client Firm' : 'Edit Client Firm'),
            content: SizedBox(
              width: 500,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoLabel(
                      label: 'Firm Name *',
                      child: TextBox(
                        controller: firmNameController,
                        placeholder: 'Enter firm name',
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InfoLabel(
                      label: 'Address',
                      child: TextBox(
                        controller: addressController,
                        placeholder: 'Enter address',
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InfoLabel(
                      label: 'Contact Number',
                      child: TextBox(
                        controller: contactNoController,
                        placeholder: 'Enter contact number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    InfoLabel(
                      label: 'GST Number',
                      child: TextBox(
                        controller: gstNoController,
                        placeholder: 'Enter GST number',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Button(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed:
                    () => _saveClientFirm(
                      context,
                      firm: firm,
                      firmName: firmNameController.text,
                      address: addressController.text,
                      contactNo: contactNoController.text,
                      gstNo: gstNoController.text,
                    ),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveClientFirm(
    BuildContext context, {
    ClientFirm? firm,
    required String firmName,
    required String address,
    required String contactNo,
    required String gstNo,
  }) async {
    // Validate
    if (firmName.trim().isEmpty) {
      await _showErrorDialog(context, 'Firm name is required');
      return;
    }

    try {
      final dao = ref.read(clientFirmsDaoProvider);
      final clientFirm = ClientFirm(
        id: firm?.id,
        firmName: firmName.trim(),
        address: address.trim().isEmpty ? null : address.trim(),
        contactNo: contactNo.trim().isEmpty ? null : contactNo.trim(),
        gstNo: gstNo.trim().isEmpty ? null : gstNo.trim(),
        createdAt: firm?.createdAt ?? DateTime.now(),
      );

      if (firm == null) {
        // Insert new firm
        await dao.insertClientFirm(clientFirm);
      } else {
        // Update existing firm
        final success = await dao.updateClientFirm(clientFirm);
        if (!success) {
          throw Exception('Failed to update client firm');
        }
      }

      // Refresh provider
      ref.invalidate(clientFirmsProvider);

      if (context.mounted) {
        Navigator.pop(context);
        await _showSuccessDialog(
          context,
          firm == null
              ? 'Client firm added successfully'
              : 'Client firm updated successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        await _showErrorDialog(context, 'Error saving client firm: $e');
      }
    }
  }

  Future<void> _confirmDeleteClientFirm(
    BuildContext context,
    ClientFirm firm,
  ) async {
    final dao = ref.read(clientFirmsDaoProvider);

    // Check if firm has associated data
    final hasData = await dao.clientFirmHasData(firm.id!);
    if (hasData) {
      if (context.mounted) {
        await _showErrorDialog(
          context,
          'Cannot delete this client firm because it has associated bills. '
          'Please delete or reassign all bills first.',
        );
      }
      return;
    }

    if (context.mounted) {
      final result = await showDialog<bool>(
        context: context,
        builder:
            (context) => ContentDialog(
              title: const Text('Confirm Delete'),
              content: Text(
                'Are you sure you want to delete "${firm.firmName}"?\n'
                'This action cannot be undone.',
              ),
              actions: [
                Button(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
      );

      if (result == true) {
        try {
          await dao.deleteClientFirm(firm.id!);
          ref.invalidate(clientFirmsProvider);

          if (context.mounted) {
            await _showSuccessDialog(
              context,
              'Client firm deleted successfully',
            );
          }
        } catch (e) {
          if (context.mounted) {
            await _showErrorDialog(context, 'Error deleting client firm: $e');
          }
        }
      }
    }
  }

  Future<void> _showErrorDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _showSuccessDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
