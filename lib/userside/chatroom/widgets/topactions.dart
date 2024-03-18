import 'package:flutter/material.dart';

import '../../../global/variables/colors.dart';
import '../../profiles/widgets/getprofilecircle.dart';

class TopActions extends StatefulWidget {
  final VoidCallback onbackpressed;
  final String title;
  final String? photourl, status;
  final bool isitgroup;
  final String herotag;
  const TopActions({
    super.key,
    this.isitgroup = false,
    required this.herotag,
    required this.title,
    this.status,
    this.photourl,
    required this.onbackpressed,
  });

  @override
  State<TopActions> createState() => _TopActionsState();
}

class _TopActionsState extends State<TopActions>
    with SingleTickerProviderStateMixin {
  late Animation<double> size;
  late Animation<double> fadein;
  late AnimationController controller;
  late MediaQueryData md;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this)
      ..addListener(() {
        setState(() {});
      });
    size = Tween<double>(begin: 0, end: 30).animate(
        CurvedAnimation(parent: controller, curve: const Interval(0, 0.5)));
    fadein = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: const Interval(0.5, 1)));
  }

  @override
  Widget build(BuildContext context) {
    md = MediaQuery.of(context);
    if (widget.isitgroup) {
      if (widget.status == null && controller.value == 1) {
        controller.reverse();
      } else if (widget.status != null && controller.value == 0) {
        controller.forward();
      }
    } else {
      if (controller.value == 1 && widget.status == "offline") {
        controller.reverse();
      } else if (controller.value == 0 && widget.status != "offline") {
        controller.forward();
      }
    }
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: md.size.width,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: IconButton(
                onPressed: widget.onbackpressed,
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: MyColors.primarySwatch),
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              flex: 3,
              child: Hero(
                tag: widget.herotag,
                child: profilewidget(widget.photourl, 45, widget.isitgroup),
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              fit: FlexFit.tight,
              flex: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    width: md.size.width * 0.5,
                    height: size.value,
                    child: Opacity(
                      opacity: fadein.value,
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        widget.status ?? "offline",
                        style: TextStyle(
                          color:
                              widget.status == "typing..." || widget.isitgroup
                                  ? MyColors.primarySwatch
                                  : Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
