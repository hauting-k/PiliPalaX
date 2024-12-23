import 'package:PiliPalaX/common/widgets/loading_widget.dart';
import 'package:PiliPalaX/http/loading_state.dart';
import 'package:PiliPalaX/models/video/reply/emote.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/network_img_layer.dart';
import 'controller.dart';

class EmotePanel extends StatefulWidget {
  final Function onChoose;
  const EmotePanel({super.key, required this.onChoose});

  @override
  State<EmotePanel> createState() => _EmotePanelState();
}

class _EmotePanelState extends State<EmotePanel>
    with AutomaticKeepAliveClientMixin {
  final EmotePanelController _emotePanelController =
      Get.put(EmotePanelController());

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() => _buildBody(_emotePanelController.loadingState.value));
  }

  Widget _buildBody(LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => loadingWidget,
      Success() => (loadingState.response as List?)?.isNotEmpty == true
          ? Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _emotePanelController.tabController,
                    children: (loadingState.response as List<Packages>).map(
                      (e) {
                        int size = e.emote!.first.meta!.size!;
                        int type = e.type!;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent:
                                  type == 4 ? 100 : (size == 1 ? 40 : 60),
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              mainAxisExtent: size == 1 ? 40 : 60,
                            ),
                            itemCount: e.emote!.length,
                            itemBuilder: (context, index) {
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    widget.onChoose(e, e.emote![index]);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: type == 4
                                        ? Center(
                                            child: Text(
                                              e.emote![index].text!,
                                              overflow: TextOverflow.clip,
                                              maxLines: 1,
                                            ),
                                          )
                                        : NetworkImgLayer(
                                            src: e.emote![index].url!,
                                            width: size * 38,
                                            height: size * 38,
                                            semanticsLabel:
                                                e.emote![index].text!,
                                            type: 'emote',
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
                TabBar(
                  controller: _emotePanelController.tabController,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  tabs: (loadingState.response as List<Packages>)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: NetworkImgLayer(
                            width: 24,
                            height: 24,
                            type: 'emote',
                            src: e.url,
                          ),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            )
          : _errorWidget,
      Error() => _errorWidget,
      LoadingState() => throw UnimplementedError(),
    };
  }

  Widget get _errorWidget => Center(
        child: IconButton(
          onPressed: () {
            _emotePanelController.onReload();
          },
          icon: Icon(Icons.refresh),
        ),
      );
}
