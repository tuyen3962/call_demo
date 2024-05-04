import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class ScrollViewPAge extends StatefulWidget {
  const ScrollViewPAge({super.key});

  @override
  State<ScrollViewPAge> createState() => _ScrollViewPAgeState();
}

class _ScrollViewPAgeState extends State<ScrollViewPAge> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HorizontalScrollView<String>(
              lengthInColumn: 2,
              items: List.generate(21, (index) => ''),
              itemBuilder: (index, item) => Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 100,
                  height: 100,
                  color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalScrollView<T> extends StatefulWidget {
  const HorizontalScrollView({
    super.key,
    this.items = const [],
    this.widthOfScrollableView = 150,
    required this.itemBuilder,
    this.lengthInColumn = 1,
  });

  final List<T> items;
  final double widthOfScrollableView;
  final Widget Function(int index, T item) itemBuilder;
  final int lengthInColumn;

  @override
  State<HorizontalScrollView<T>> createState() =>
      _HorizontalScrollViewState<T>();
}

class _HorizontalScrollViewState<T> extends State<HorizontalScrollView<T>> {
  final scrollCtrl = ScrollController();
  final positionNotifier = ValueNotifier<double>(0);
  final widthScrollNotifier = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(() {
      var newPosition =
          ((scrollCtrl.offset / scrollCtrl.position.maxScrollExtent) *
                  widget.widthOfScrollableView) -
              widthScrollNotifier.value;
      if (newPosition < 0) {
        newPosition = 0;
      } else if (newPosition >
          widget.widthOfScrollableView - widthScrollNotifier.value) {
        newPosition = widget.widthOfScrollableView - widthScrollNotifier.value;
      }
      positionNotifier.value = newPosition;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final maxScrollExtent = scrollCtrl.position.maxScrollExtent;
      final temp = math.pow(10, maxScrollExtent.toInt().toString().length - 1);
      widthScrollNotifier.value = widget.widthOfScrollableView /
          (scrollCtrl.position.maxScrollExtent / temp);
    });
  }

  @override
  void dispose() {
    widthScrollNotifier.dispose();
    positionNotifier.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListHorizontalItem<T>(
          items: widget.items,
          itemBuilder: widget.itemBuilder,
          lineItemCount: widget.lengthInColumn,
          scrollController: scrollCtrl,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 150,
          height: 10,
          child: Stack(
            children: [
              Container(
                width: 150,
                height: 10,
                color: Colors.grey,
              ),
              ValueListenableBuilder(
                valueListenable: positionNotifier,
                builder: (context, positionLeft, child) => Positioned(
                  left: positionLeft,
                  top: 0,
                  bottom: 0,
                  child: ValueListenableBuilder(
                    valueListenable: widthScrollNotifier,
                    builder: (context, width, child) => Container(
                      width: width,
                      height: 10,
                      color: Colors.pink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ListHorizontalItem<T> extends StatelessWidget {
  const ListHorizontalItem({
    required this.itemBuilder,
    Key? key,
    this.items = const [],
    this.lineItemCount = 2,
    this.paddingBetweenItem = 8,
    this.paddingBetweenLine = 4,
    this.physics,
    this.scrollController,
  }) : super(key: key);

  final List<T> items;
  final Widget Function(int index, T item) itemBuilder;
  final double paddingBetweenItem;
  final double paddingBetweenLine;
  final int lineItemCount;
  final ScrollPhysics? physics;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final itemRows = items.length ~/ lineItemCount + 1;
    return SingleChildScrollView(
      physics: physics,
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      child: Row(
          children: List.generate(
              itemRows,
              (index) => Padding(
                  padding: EdgeInsets.only(
                      right: index != itemRows - 1 ? paddingBetweenLine : 0),
                  child: buildColumnItem(index)))),
    );
  }

  Widget buildColumnItem(int index) {
    final currentIndex = index * lineItemCount;
    if (currentIndex >= items.length) return const SizedBox();
    return Column(
      children: List.generate(
        lineItemCount,
        (index) => Padding(
            padding: EdgeInsets.only(
                bottom: index == 0 ? paddingBetweenItem : 0,
                top: index == 0 ? paddingBetweenItem : 0),
            child: currentIndex + index >= items.length
                ? Opacity(
                    opacity: 0,
                    child:
                        itemBuilder(currentIndex + index, items[currentIndex]),
                  )
                : itemBuilder(
                    currentIndex + index, items[currentIndex + index])),
      ),
    );
  }
}

class ListVerticalItem<T> extends StatelessWidget {
  const ListVerticalItem({
    required this.itemBuilder,
    Key? key,
    this.items = const [],
    this.lineItemCount = 2,
    this.paddingBetweenItem = 8,
    this.paddingBetweenLine = 4,
    this.divider,
    this.physics,
  }) : super(key: key);

  final List<T> items;
  final Widget Function(int, T) itemBuilder;
  final double paddingBetweenItem;
  final double paddingBetweenLine;
  final int lineItemCount;
  final Widget? divider;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final itemColumn = items.length ~/ lineItemCount + 1;
    Widget widget;
    if (divider != null) {
      widget = ListView.separated(
          shrinkWrap: true,
          physics: physics,
          itemBuilder: (context, index) => buildLineItem(index),
          separatorBuilder: (context, index) => divider!,
          itemCount: itemColumn);
    } else {
      widget = SingleChildScrollView(
        physics: physics,
        child: Column(
            children: List.generate(
                itemColumn,
                (index) => Padding(
                    padding: EdgeInsets.only(
                        bottom:
                            index != itemColumn - 1 ? paddingBetweenLine : 0),
                    child: buildLineItem(index)))),
      );
    }
    return widget;
  }

  Widget buildLineItem(int index) {
    final currentIndex = index * lineItemCount;
    if (currentIndex >= items.length) return const SizedBox();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          lineItemCount,
          (index) => Expanded(
            child: Padding(
                padding: EdgeInsets.only(
                    left: index == 0 ? paddingBetweenItem : 0,
                    right: index == 0 ? paddingBetweenItem : 0),
                child: currentIndex + index >= items.length
                    ? Container()
                    : itemBuilder(
                        currentIndex + index, items[currentIndex + index])),
          ),
        ),
      ),
    );
  }
}
