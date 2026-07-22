import 'package:flutter/material.dart';

import '../../repositories/consultation_repository.dart';
import '../../models/consultation_request_model.dart';
import 'admin_consultation_request_detail_screen.dart';

class AdminConsultationManagementScreen
    extends StatelessWidget {
  const AdminConsultationManagementScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final repository =
        ConsultationRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danışma Yönetimi',
        ),
      ),
      body: StreamBuilder<
          List<ConsultationRequest>>(
        stream:
            repository.watchWaitingForAdminRequests(),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final requests =
              snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'Atama bekleyen danışma talebi bulunmuyor.',
              ),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder:
                (context, index) {
              final request =
                  requests[index];

              return ListTile(
                title: Text(
                  request.userFullName,
                ),
                subtitle: Text(
                  request.companyName,
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AdminConsultationRequestDetailScreen(
        request: request,
      ),
    ),
  );
},
              );
            },
          );
        },
      ),
    );
  }
}