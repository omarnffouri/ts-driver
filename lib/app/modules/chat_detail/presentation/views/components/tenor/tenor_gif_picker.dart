import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'tenor_service.dart';

typedef GifSelected = void Function(TenorGif gif);

class TenorGifPicker extends StatefulWidget {
  final TenorService service;
  final GifSelected onSelected;
  final VoidCallback? onTap;
  const TenorGifPicker(
      {super.key, required this.service, required this.onSelected, this.onTap});

  @override
  State<TenorGifPicker> createState() => _TenorGifPickerState();
}

class _TenorGifPickerState extends State<TenorGifPicker> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  List<TenorGif> _items = [];
  String? _next;
  String _query = '';
  bool _loading = false;
  bool _firstLoad = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400 &&
        !_loading &&
        _next != null) {
      _load(pos: _next);
    }
  }

  Future<void> _load({String? pos, bool clear = false}) async {
    setState(() {
      _loading = true;
      if (clear) _error = null;
    });
    try {
      final page = await widget.service.fetch(query: _query, pos: pos);
      setState(() {
        _items = clear ? page.items : [..._items, ...page.items];
        _next = page.next;
        _firstLoad = false;
      });
    } catch (_) {
      setState(() => _error = 'Could not load GIFs');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String value) {
    _query = value.trim();
    _next = null;
    _firstLoad = true;
    _load(clear: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
          child: TextField(
            controller: _controller,
            onChanged: _onSearch,
            onSubmitted: _onSearch,
            onTap: widget.onTap,
            style: TextStyle(fontSize: 14.sp, color: context.primaryTextColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: context.cardColor,
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 4.w),
              hintText: 'Search Tenor',
              hintStyle: TextStyle(color: context.hintColor, fontSize: 14.sp),
              prefixIcon:
                  Icon(Icons.search, color: context.hintColor, size: 20.r),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide: BorderSide(color: context.dividerColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide: BorderSide(color: context.dividerColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
        ),
        Expanded(child: _body(context)),
      ],
    );
  }

  Widget _body(BuildContext context) {
    if (_firstLoad && _loading) {
      return MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4.r,
        crossAxisSpacing: 4.r,
        padding: EdgeInsets.all(8.r),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 12,
        itemBuilder: (_, i) => Shimmer.fromColors(
          baseColor: context.shimmerBaseColor,
          highlightColor: context.shimmerHighlightColor,
          child: AspectRatio(
            aspectRatio: const [1.0, 1.4, 0.8, 1.2][i % 4],
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      );
    }

    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: context.hintColor, size: 40.r),
            SizedBox(height: 8.h),
            Text(_error!,
                style: TextStyle(color: context.hintColor, fontSize: 13.sp)),
            TextButton(
              onPressed: () => _load(clear: true),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_loading && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.gif_box_outlined, color: context.hintColor, size: 40.r),
            SizedBox(height: 8.h),
            Text(
              'No results${_query.isNotEmpty ? ' for "$_query"' : ''}',
              style: TextStyle(color: context.hintColor, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: MasonryGridView.count(
            controller: _scroll,
            crossAxisCount: 2,
            mainAxisSpacing: 4.r,
            crossAxisSpacing: 4.r,
            padding: EdgeInsets.all(8.r),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final gif = _items[i];
              final thumb = gif.tinyGifUrl ?? gif.gifUrl ?? gif.mp4Url;
              return ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: AspectRatio(
                  aspectRatio: gif.aspectRatio,
                  child: thumb == null
                      ? ColoredBox(color: context.shimmerBaseColor)
                      : Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => widget.onSelected(gif),
                            child: CachedNetworkImage(
                              imageUrl: thumb,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Shimmer.fromColors(
                                baseColor: context.shimmerBaseColor,
                                highlightColor: context.shimmerHighlightColor,
                                child: const ColoredBox(color: Colors.white),
                              ),
                              errorWidget: (_, __, ___) => ColoredBox(
                                color: context.shimmerBaseColor,
                                child: Icon(Icons.broken_image_rounded,
                                    color: context.hintColor),
                              ),
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
        if (_loading && !_firstLoad)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: SizedBox(
              width: 22.r,
              height: 22.r,
              child: const CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
