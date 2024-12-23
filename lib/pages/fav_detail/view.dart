import 'package:PiliPalaX/http/loading_state.dart';
import 'package:PiliPalaX/http/user.dart';
import 'package:PiliPalaX/models/user/fav_folder.dart';
import 'package:PiliPalaX/pages/fav_search/view.dart' show SearchType;
import 'package:PiliPalaX/utils/extension.dart';
import 'package:PiliPalaX/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/skeleton/video_card_h.dart';
import 'package:PiliPalaX/common/widgets/http_error.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/pages/fav_detail/index.dart';

import '../../common/constants.dart';
import '../../utils/grid.dart';
import 'widget/fav_video_card.dart';

class FavDetailPage extends StatefulWidget {
  const FavDetailPage({super.key});

  @override
  State<FavDetailPage> createState() => _FavDetailPageState();
}

class _FavDetailPageState extends State<FavDetailPage> {
  final FavDetailController _favDetailController =
      Get.put(FavDetailController());
  late String mediaId;

  @override
  void initState() {
    super.initState();
    mediaId = Get.parameters['mediaId']!;
    _favDetailController.scrollController.addListener(
      () {
        if (_favDetailController.scrollController.offset > 160) {
          _favDetailController.titleCtr.value = true;
        } else if (_favDetailController.scrollController.offset <= 160) {
          _favDetailController.titleCtr.value = false;
        }
      },
    );
  }

  @override
  void dispose() {
    _favDetailController.scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: _favDetailController.enableMultiSelect.value.not,
        onPopInvokedWithResult: (didPop, result) {
          if (_favDetailController.enableMultiSelect.value) {
            _favDetailController.handleSelect();
          }
        },
        child: Scaffold(
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _favDetailController.scrollController,
            slivers: [
              SliverAppBar(
                leading: _favDetailController.enableMultiSelect.value
                    ? IconButton(
                        tooltip: '取消',
                        onPressed: _favDetailController.handleSelect,
                        icon: const Icon(Icons.close_outlined),
                      )
                    : null,
                expandedHeight: 220 - MediaQuery.of(context).padding.top,
                pinned: true,
                title: _favDetailController.enableMultiSelect.value
                    ? Text(
                        '已选择${_favDetailController.checkedCount.value}项',
                      )
                    : Obx(
                        () => AnimatedOpacity(
                          opacity: _favDetailController.titleCtr.value ? 1 : 0,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 500),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _favDetailController.item.value.title ?? '',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '共${_favDetailController.item.value.mediaCount}条视频',
                                style: Theme.of(context).textTheme.labelMedium,
                              )
                            ],
                          ),
                        ),
                      ),
                actions: _favDetailController.enableMultiSelect.value
                    ? [
                        TextButton(
                          onPressed: () =>
                              _favDetailController.handleSelect(true),
                          child: const Text('全选'),
                        ),
                        TextButton(
                          onPressed: () =>
                              _favDetailController.onDelChecked(context),
                          child: Text(
                            '删除',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ]
                    : [
                        IconButton(
                          tooltip: '搜索',
                          onPressed: () =>
                              Get.toNamed('/favSearch', arguments: {
                            'type': 0,
                            'mediaId': int.parse(mediaId),
                            'searchType': SearchType.fav,
                          }),
                          icon: const Icon(Icons.search_outlined),
                        ),
                        //   IconButton(
                        //     onPressed: () {},
                        //     icon: const Icon(Icons.more_vert),
                        //   ),
                        Obx(
                          () => _favDetailController.isOwner.value
                              ? PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      onTap: () {
                                        Get.toNamed(
                                          '/createFav',
                                          parameters: {'mediaId': mediaId},
                                        )?.then((res) {
                                          if (res is FavFolderItemData) {
                                            _favDetailController.item.value =
                                                res;
                                          }
                                        });
                                      },
                                      child: Text('编辑信息'),
                                    ),
                                    if (!Utils.isDefault(
                                        _favDetailController.item.value.attr ??
                                            0))
                                      PopupMenuItem(
                                        onTap: () {
                                          UserHttp.deleteFolder(
                                              mediaIds: [mediaId]).then((data) {
                                            if (data['status']) {
                                              SmartDialog.showToast('删除成功');
                                              Get.back(result: true);
                                            } else {
                                              SmartDialog.showToast(
                                                  data['msg']);
                                            }
                                          });
                                        },
                                        child: Text('删除'),
                                      ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 6),
                      ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.only(
                        top: kTextTabBarHeight +
                            MediaQuery.of(context).padding.top +
                            10,
                        left: 14,
                        right: 20),
                    child: SizedBox(
                      height: 110,
                      child: Obx(
                        () => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: _favDetailController.heroTag,
                              child: NetworkImgLayer(
                                width: 180,
                                height: 110,
                                src: _favDetailController.item.value.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: SizedBox(
                                height: 110,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      _favDetailController.item.value.title ??
                                          '',
                                      style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .fontSize,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (_favDetailController
                                            .item.value.intro?.isNotEmpty ==
                                        true)
                                      Text(
                                        _favDetailController.item.value.intro ??
                                            '',
                                        style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .labelSmall!
                                                .fontSize,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _favDetailController
                                              .item.value.upper?.name ??
                                          '',
                                      style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .labelSmall!
                                              .fontSize,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                    ),
                                    const Spacer(),
                                    if (_favDetailController.item.value.attr !=
                                        null)
                                      Text(
                                        '共${_favDetailController.item.value.mediaCount}条视频 · ${Utils.isPublicText(_favDetailController.item.value.attr ?? 0)}',
                                        style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .labelSmall!
                                                .fontSize,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Obx(() => _buildBody(_favDetailController.loadingState.value)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => SliverGrid(
          gridDelegate: SliverGridDelegateWithExtentAndRatio(
            mainAxisSpacing: StyleString.cardSpace,
            crossAxisSpacing: StyleString.safeSpace,
            maxCrossAxisExtent: Grid.maxRowWidth * 2,
            childAspectRatio: StyleString.aspectRatio * 2.4,
            mainAxisExtent: 0,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return const VideoCardHSkeleton();
            },
            childCount: 10,
          ),
        ),
      Success() => (loadingState.response as List?)?.isNotEmpty == true
          ? SliverPadding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithExtentAndRatio(
                  mainAxisSpacing: StyleString.cardSpace,
                  crossAxisSpacing: StyleString.safeSpace,
                  maxCrossAxisExtent: Grid.maxRowWidth * 2,
                  childAspectRatio: StyleString.aspectRatio * 2.4,
                  mainAxisExtent: 0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == loadingState.response.length) {
                      _favDetailController.onLoadMore();
                      return Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(
                          _favDetailController.isEnd.not ? '加载中...' : '没有更多了',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        FavVideoCardH(
                          videoItem: loadingState.response[index],
                          callFn: () => _favDetailController.onCancelFav(
                            loadingState.response[index].id,
                            loadingState.response[index].type,
                          ),
                          onTap:
                              _favDetailController.enableMultiSelect.value.not
                                  ? null
                                  : () {
                                      _favDetailController.onSelect(index);
                                    },
                          onLongPress: () {
                            if (_favDetailController
                                .enableMultiSelect.value.not) {
                              _favDetailController.enableMultiSelect.value =
                                  true;
                              _favDetailController.onSelect(index);
                            }
                          },
                        ),
                        Positioned(
                          top: 0,
                          left: 12,
                          bottom: 0,
                          child: IgnorePointer(
                            child: LayoutBuilder(
                              builder: (context, constraints) =>
                                  AnimatedOpacity(
                                opacity: loadingState.response[index].checked
                                    ? 1
                                    : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: constraints.maxHeight,
                                  width: constraints.maxHeight *
                                      StyleString.aspectRatio,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                  child: SizedBox(
                                    width: 34,
                                    height: 34,
                                    child: AnimatedScale(
                                      scale:
                                          loadingState.response[index].checked
                                              ? 1
                                              : 0,
                                      duration:
                                          const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      child: IconButton(
                                        style: ButtonStyle(
                                          padding: WidgetStateProperty.all(
                                              EdgeInsets.zero),
                                          backgroundColor:
                                              WidgetStateProperty.resolveWith(
                                            (states) {
                                              return Theme.of(context)
                                                  .colorScheme
                                                  .surface
                                                  .withOpacity(0.8);
                                            },
                                          ),
                                        ),
                                        onPressed: null,
                                        icon: Icon(
                                          Icons.done_all_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: loadingState.response.length + 1,
                ),
              ),
            )
          : HttpError(
              callback: _favDetailController.onReload,
            ),
      Error() => HttpError(
          errMsg: loadingState.errMsg,
          callback: _favDetailController.onReload,
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }
}
