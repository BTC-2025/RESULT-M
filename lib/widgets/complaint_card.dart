import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'rich_text_content.dart';
import '../core/theme/app_theme.dart';

class ComplaintCard extends ConsumerWidget {
  final ComplaintModel complaint;
  final VoidCallback onTap;
  final Function(String voteType) onVote;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
    required this.onVote,
  });

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}m ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'RESOLVED':
        return context.colors.green;
      case 'UNDER_REVIEW':
        return context.colors.yellow;
      case 'OPEN':
      default:
        return context.colors.red;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need baseUrl to construct media URLs
    final baseUrl = ref.read(apiClientProvider).client.options.baseUrl;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 54,
                decoration: BoxDecoration(
                  color: context.colors.surfaceAlt,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(AppRadii.md),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        complaint.hasUserVoted == 'UP'
                            ? Icons.arrow_circle_up
                            : Icons.arrow_upward,
                        color: complaint.hasUserVoted == 'UP'
                            ? context.colors.orange
                            : context.colors.inkMuted,
                      ),
                      onPressed: () => onVote('UP'),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Upvote',
                    ),
                    Text(
                      '${complaint.netScore}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: context.colors.ink,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        complaint.hasUserVoted == 'DOWN'
                            ? Icons.arrow_circle_down
                            : Icons.arrow_downward,
                        color: complaint.hasUserVoted == 'DOWN'
                            ? context.colors.orange
                            : context.colors.inkMuted,
                      ),
                      onPressed: () => onVote('DOWN'),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Downvote',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                AppChip(
                                  label: complaint.category,
                                  color: context.colors.blue,
                                ),
                                AppChip(
                                  label: _formatStatus(complaint.status),
                                  color: _getStatusColor(context, complaint.status),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _getTimeAgo(complaint.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.inkMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        complaint.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: context.colors.ink,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (complaint.locationName != null &&
                          complaint.locationName!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: context.colors.inkMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                complaint.locationName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.inkMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      RichTextContent(
                        text: complaint.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.inkMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (complaint.mediaUrls.isNotEmpty) ...[
                        SizedBox(
                          height: 86,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: complaint.mediaUrls.length,
                            itemBuilder: (context, index) {
                              final urlPath = complaint.mediaUrls[index];
                              if (urlPath.isEmpty) return const SizedBox.shrink();
                              final isVideo =
                                  urlPath.toLowerCase().endsWith('.mp4');
                              final fullUrl =
                                  '$baseUrl/complaints/media/$urlPath';

                              return Container(
                                width: 104,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: context.colors.surfaceAlt,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.sm),
                                  border: Border.all(color: context.colors.line),
                                  image: isVideo
                                      ? null
                                      : DecorationImage(
                                          image: NetworkImage(fullUrl),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: isVideo
                                    ? Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          color: context.colors.ink,
                                          size: 34,
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: context.colors.inkMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${complaint.commentCount} comments',
                            style: TextStyle(
                              color: context.colors.inkMuted,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.more_horiz,
                            color: context.colors.inkMuted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

