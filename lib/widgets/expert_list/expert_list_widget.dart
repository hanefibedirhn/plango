import 'package:flutter/material.dart';

import '../../models/expert_profile_model.dart';

class ExpertListWidget extends StatelessWidget {
  const ExpertListWidget({
    super.key,
    required this.availableExperts,
    required this.unavailableExperts,
    required this.onRequestPressed,
  });

  final List<ExpertProfile> availableExperts;
  final List<ExpertProfile> unavailableExperts;

  final ValueChanged<ExpertProfile> onRequestPressed;

  @override
  Widget build(BuildContext context) {
    if (availableExperts.isEmpty &&
        unavailableExperts.isEmpty) {
      return const _EmptyExpertList();
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [

        if (availableExperts.isNotEmpty) ...[
          const _SectionTitle(
            title:
                "Danışma Talebi Oluşturabileceğiniz Uzmanlar",
          ),

          const SizedBox(height: 12),

          ...availableExperts.map(
            (expert) => _ExpertCard(
              expert: expert,
              canSendRequest: true,
              onPressed: () {
                onRequestPressed(expert);
              },
            ),
          ),

          const SizedBox(height: 24),
        ],

        if (unavailableExperts.isNotEmpty) ...[
          const _SectionTitle(
            title:
                "Şu Anda Talep Almayan Uzmanlar",
          ),

          const SizedBox(height: 12),

          ...unavailableExperts.map(
            (expert) => _ExpertCard(
              expert: expert,
              canSendRequest: false,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  const _ExpertCard({
    required this.expert,
    required this.canSendRequest,
    this.onPressed,
  });

  final ExpertProfile expert;

  final bool canSendRequest;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              expert.fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.business),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    expert.companyName,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    expert.branch,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.work),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    expert.position,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            if (canSendRequest)

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: const Text(
                    "Danışma Talebi Gönder",
                  ),
                ),
              )

            else

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Text(
                  "Bu uzman şu anda yeni danışma talebi almıyor.",
                  textAlign:
                      TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExpertList extends StatelessWidget {
  const _EmptyExpertList();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Text(
          "Bu şirkete ait doğrulanmış uzman bulunamadı.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}