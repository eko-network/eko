import 'package:flutter/material.dart';
import '../utilities/constants.dart' as c;

LinearGradient getLinearGradient(BuildContext context) {
  return LinearGradient(
    colors: Theme.of(context).brightness == Brightness.dark
        ? c.darkModeGradient
        : c.lightModeGradient,
    stops: const [
      0.1,
      0.3,
      0.4,
    ],
    begin: const Alignment(-1.0, -0.3),
    end: const Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
  );
}

class FeedLoader extends StatelessWidget {
  const FeedLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return SizedBox(
      width: width,
      height: height,
      child: const _FeedLoadingAnimation(),
    );
  }
}

class PostLoader extends StatelessWidget {
  const PostLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return SizedBox(
        width: width,
        height: 100,
        child: _ShimmerLoading(child: _PostCardListItem()));
  }
}

class _FeedLoadingAnimation extends StatefulWidget {
  const _FeedLoadingAnimation();

  @override
  State<_FeedLoadingAnimation> createState() => _FeedLoadingAnimationState();
}

class _FeedLoadingAnimationState extends State<_FeedLoadingAnimation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Shimmer(
        linearGradient: getLinearGradient(context),
        child: ListView(
          //mainAxisSize: MainAxisSize.min,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildListItem(),
            Divider(
              color: Theme.of(context).colorScheme.outline,
              height: c.dividerWidth,
            ),
            _buildListItem(),
            Divider(
              color: Theme.of(context).colorScheme.outline,
              height: c.dividerWidth,
            ),
            _buildListItem(),
            Divider(
              color: Theme.of(context).colorScheme.outline,
              height: c.dividerWidth,
            ),
            //_buildListItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem() {
    return const _ShimmerLoading(
      child: _PostCardListItem(),
    );
  }
}

class SearchLoader extends StatelessWidget {
  const SearchLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return SizedBox(
      width: width,
      height: height,
      child: const _SearchLoaderAnimation(),
    );
  }
}

class _SearchLoaderAnimation extends StatefulWidget {
  const _SearchLoaderAnimation();

  @override
  State<_SearchLoaderAnimation> createState() => _SearchLoaderAnimationState();
}

class _SearchLoaderAnimationState extends State<_SearchLoaderAnimation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Shimmer(
        linearGradient: getLinearGradient(context),
        child: ListView.builder(
          //mainAxisSize: MainAxisSize.min,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => _buildListItem(),
          itemCount: 20,
          // children: [
          //   for(int i =0;i<15;i++)_buildListItem(),
          // ],
        ),
      ),
    );
  }

  Widget _buildListItem() {
    return const _ShimmerLoading(
      child: _UserCardListItem(),
    );
  }
}

class _PostCardListItem extends StatelessWidget {
  const _PostCardListItem();

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.115,
            height: width * 0.115,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                width: width * 0.55,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: width * 0.5,
                height: width * 0.4,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: width * 0.7,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: width * 0.6,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _UserCardListItem extends StatelessWidget {
  const _UserCardListItem();

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: width * 0.115,
            height: width * 0.115,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: width * 0.55,
                height: width * 0.043,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: width * 0.7,
                height: width * 0.043,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

//help

class _Shimmer extends StatefulWidget {
  static _ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ShimmerState>();
  }

  const _Shimmer({
    required this.linearGradient,
    this.child,
  });

  final LinearGradient linearGradient;
  final Widget? child;

  @override
  _ShimmerState createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
// code-excerpt-closing-bracket

  LinearGradient get gradient => LinearGradient(
        colors: widget.linearGradient.colors,
        stops: widget.linearGradient.stops,
        begin: widget.linearGradient.begin,
        end: widget.linearGradient.end,
        transform:
            _SlidingGradientTransform(slidePercent: _shimmerController.value),
      );

  bool get isSized => (context.findRenderObject() as RenderBox).hasSize;

  Size get size => (context.findRenderObject() as RenderBox).size;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  Listenable get shimmerChanges => _shimmerController;

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox();
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class _ShimmerLoading extends StatefulWidget {
  const _ShimmerLoading({
    required this.child,
  });

  final Widget child;

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shimmerChanges != null) {
      _shimmerChanges!.removeListener(_onShimmerChange);
    }
    _shimmerChanges = _Shimmer.of(context)?.shimmerChanges;
    if (_shimmerChanges != null) {
      _shimmerChanges!.addListener(_onShimmerChange);
    }
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange() {
    setState(() {
      // update the shimmer painting.
    });
  }
// code-excerpt-closing-bracket

  @override
  Widget build(BuildContext context) {
    final shimmer = _Shimmer.of(context)!;
    if (!shimmer.isSized) {
      // The ancestor Shimmer widget has not laid
      // itself out yet. Return an empty box.
      return const SizedBox();
    }
    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;
    final offsetWithinShimmer = shimmer.getDescendantOffset(
      descendant: context.findRenderObject() as RenderBox,
    );

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            -offsetWithinShimmer.dx,
            -offsetWithinShimmer.dy,
            shimmerSize.width,
            shimmerSize.height,
          ),
        );
      },
      child: widget.child,
    );
  }
}
