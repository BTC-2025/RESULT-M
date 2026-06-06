import 'package:flutter/material.dart';
import '../../models/feed_post_model.dart';
import '../../core/theme/app_theme.dart';

/// Horizontal scrollable row of live story circles at the top of the Home feed
class LiveStoryRow extends StatelessWidget {
  final List<LiveStory> stories;
  final ValueChanged<LiveStory> onTap;

  const LiveStoryRow({
    super.key,
    required this.stories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection:  Axis.horizontal,
        padding:          const EdgeInsets.symmetric(horizontal: 16),
        itemCount:        stories.length,
        separatorBuilder: (context, i) => const SizedBox(width: 14),
        itemBuilder: (context, i) => LiveStoryCircle(
          story: stories[i],
          onTap: () => onTap(stories[i]),
        ),
      ),
    );
  }
}

class LiveStoryCircle extends StatefulWidget {
  final LiveStory story;
  final VoidCallback onTap;

  const LiveStoryCircle({
    super.key,
    required this.story,
    required this.onTap,
  });

  @override
  State<LiveStoryCircle> createState() => _LiveStoryCircleState();
}

class _LiveStoryCircleState extends State<LiveStoryCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    if (widget.story.isLive) {
      _ctrl = AnimationController(
        vsync:    this,
        duration: const Duration(milliseconds: 1000),
      )..repeat(reverse: true);
      _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      );
    } else {
      _ctrl = AnimationController(vsync: this);
      _pulse = const AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _domainColor {
    switch (widget.story.domainType) {
      case 'SPORT':     return context.colors.green;
      case 'ELECTION':  return context.colors.blue;
      case 'ACADEMIC':  return context.colors.purple;
      case 'FINANCE':   return context.colors.amber;
      default:          return context.colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _domainColor;
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Ring + Circle ───
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) => Container(
                width:  58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.story.isLive
                      ? SweepGradient(colors: [
                          context.colors.liveRed.withValues(alpha: _pulse.value),
                          context.colors.orange.withValues(alpha: _pulse.value),
                          context.colors.liveRed.withValues(alpha: _pulse.value),
                        ])
                      : LinearGradient(colors: [
                          color.withValues(alpha: 0.5),
                          color.withValues(alpha: 0.3),
                        ]),
                ),
                padding: const EdgeInsets.all(2.5),
                child: child,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: widget.story.imageUrl != null
                    ? Image.network(
                        widget.story.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => Center(
                          child: Text(
                            widget.story.emoji ?? '📊',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          widget.story.emoji ?? '📊',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            // ─── Label ───
            Text(
              widget.story.label,
              style: TextStyle(
                color:     context.colors.inkMuted,
                fontSize:  10,
                fontWeight: FontWeight.w700,
              ),
              maxLines:  1,
              overflow:  TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (widget.story.isLive)
              Container(
                margin:  const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color:        context.colors.liveRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color:       Colors.white,
                    fontSize:    8,
                    fontWeight:  FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

