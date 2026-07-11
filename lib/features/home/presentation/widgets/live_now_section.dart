import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/feed_post_model.dart';

class LiveNowHeader extends StatelessWidget {
  final VoidCallback onSeeAll;

  const LiveNowHeader({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const _PulsingDot(),
          const SizedBox(width: 8),
          Text(
            'Live Now',
            style: TextStyle(
              color: context.colors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: context.colors.purple,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'See all',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class StoriesStrip extends StatelessWidget {
  final List<LiveStory> stories;
  final ValueChanged<LiveStory> onTap;

  const StoriesStrip({
    super.key,
    required this.stories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final liveStories = stories.where((story) => story.isLive).toList();
    final displayStories = liveStories.isNotEmpty ? liveStories : stories;
    if (displayStories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemCount: displayStories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final story = displayStories[index];
          return _StoryItem(
            story: story,
            forceLive: liveStories.isEmpty,
            onTap: () => onTap(story),
          );
        },
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.75, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: context.colors.teal,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _StoryItem extends StatefulWidget {
  final LiveStory story;
  final bool forceLive;
  final VoidCallback onTap;

  const _StoryItem({
    required this.story,
    required this.onTap,
    this.forceLive = false,
  });

  @override
  State<_StoryItem> createState() => _StoryItemState();
}

class _StoryItemState extends State<_StoryItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    if (_isLive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _StoryItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isLive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!_isLive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLive = _isLive;
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                RotationTransition(
                  turns: isLive ? _controller : const AlwaysStoppedAnimation(0),
                  child: Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isLive
                          ? SweepGradient(colors: [
                              context.colors.purple,
                              context.colors.teal,
                              context.colors.purple,
                            ])
                          : LinearGradient(colors: [
                              context.colors.purple,
                              context.colors.purple,
                            ]),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colors.surfaceAlt,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: CircleAvatar(
                      backgroundColor: context.colors.surfaceAlt,
                      foregroundImage: widget.story.imageUrl == null || widget.story.imageUrl!.isEmpty
                          ? null
                          : NetworkImage(widget.story.imageUrl!),
                      child: Text(
                        _storyInitial(widget.story),
                        style: TextStyle(
                          color: context.colors.ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isLive)
                  Positioned.fill(
                    bottom: -2,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.teal,
                          borderRadius: BorderRadius.circular(AppRadii.full),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.story.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.inkMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _storyInitial(LiveStory story) {
    if (story.emoji != null && story.emoji!.length == 1) return story.emoji!;
    return story.label.isEmpty ? 'R' : story.label[0].toUpperCase();
  }

  bool get _isLive => widget.forceLive || widget.story.isLive;
}
