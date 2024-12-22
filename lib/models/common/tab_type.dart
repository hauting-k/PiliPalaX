import 'package:PiliPalaX/pages/rank/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/pages/bangumi/index.dart';
import 'package:PiliPalaX/pages/hot/index.dart';
import 'package:PiliPalaX/pages/live/index.dart';
import 'package:PiliPalaX/pages/rcmd/index.dart';

enum TabType { live, rcmd, hot, rank, bangumi, blank }

extension TabTypeDesc on TabType {
  String get description =>
      ['直播', '推荐', '热门', '分区', '番剧', '空白'][index];
  String get id =>
      ['live', 'rcmd', 'hot', 'rank', 'bangumi', 'blank'][index];
}

List tabsConfig = [
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': '直播',
    'type': TabType.live,
    'ctr': Get.find<LiveController>,
    'page': const RcmdPage(tabType: TabType.live),
  },
  {
    'icon': const Icon(
      Icons.thumb_up_off_alt_outlined,
      size: 15,
    ),
    'label': '推荐',
    'type': TabType.rcmd,
    'ctr': Get.find<RcmdController>,
    'page': const RcmdPage(tabType: TabType.rcmd),
  },
  {
    'icon': const Icon(
      Icons.whatshot_outlined,
      size: 15,
    ),
    'label': '热门',
    'type': TabType.hot,
    'ctr': Get.find<HotController>,
    'page': const HotPage(),
  },
  {
    'icon': const Icon(
      Icons.category_outlined,
      size: 15,
    ),
    'label': '分区',
    'type': TabType.rank,
    'ctr': Get.find<RankController>,
    'page': const RankPage(),
  },
  {
    'icon': const Icon(
      Icons.play_circle_outlined,
      size: 15,
    ),
    'label': '番剧',
    'type': TabType.bangumi,
    'ctr': Get.find<BangumiController>,
    'page': const BangumiPage(),
  },
  {
    'icon': const Icon(
      Icons.space_bar,
      size: 15,
    ),
    'label': '空白',
    'type': TabType.blank,
    'page': const BlankPage(),
  },
];

/// 定义空白页面
class BlankPage extends StatelessWidget {
  const BlankPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(), // 完全空白
    );
  }
}
